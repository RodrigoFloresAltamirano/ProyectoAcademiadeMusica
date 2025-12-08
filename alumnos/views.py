from django.http import HttpResponseRedirect
from django.shortcuts import render, redirect
from django.urls import reverse
from django.contrib.auth.decorators import login_required, user_passes_test
from django.db import connection
from django.contrib import messages

from .models import Alumnos, Inscripciones, Instructores, Cursos
from .forms import AlumnoForm, AltaInscripcionForm, InstructorForm
from decimal import Decimal
from datetime import datetime

import json

# Create your views here.

def dictfetchall(cursor):
    """
        lista de diccionarios.
    """
    columns = [col[0] for col in cursor.description]
    return [
        dict(zip(columns, row))
        for row in cursor.fetchall()
    ]

def es_administrador(user):
    # True si es superusuario o Administradores
    return user.is_superuser or user.groups.filter(name='Administradores').exists()

@login_required(login_url='login') # Obliga a iniciar sesión
@user_passes_test(es_administrador, login_url='login') # Obliga a tener el rol
def index(request):
    return render(request, 'alumnos/index.html',{
        'alumnos': Alumnos.objects.all(),
        'instructores': Instructores.objects.all()
    })

def view_alumno(request, id):
    alumno = Alumnos.objects.get(pk=id)
    return HttpResponseRedirect(reverse('index'))

@login_required
@user_passes_test(es_administrador)
def add(request):
    if request.method == 'POST':
        form = AlumnoForm(request.POST)
        if form.is_valid():
            
            form.save() 
            
            # Redirigir al index para ver el nuevo alumno
            return redirect('index') 
            
    else:
        form = AlumnoForm()
    
    return render(request, 'alumnos/agregar.html', {
        'form': form
    })
    pass


def editar(request, id):
    if request.method == 'POST':
        alumno = Alumnos.objects.get(pk=id)
        form = AlumnoForm(request.POST, instance=alumno)
        if form.is_valid():
            form.save()
            return render(request, 'alumnos/editar.html', {
                'form': form,
                'success': True
            })
    else:
        alumno = Alumnos.objects.get(pk=id)
        form = AlumnoForm(instance=alumno)
    return render(request, 'alumnos/editar.html', {
        'form': form
    })

@login_required
@user_passes_test(es_administrador)
def eliminar(request, id):
    # request.POST para asegurar que solo se ejecuta con el botón del modal
    if request.method == 'POST':
        try:
            alumno_id = id 
            
            # Obtener el alumno a eliminar
            alumno = Alumnos.objects.get(pk=alumno_id)
            
            # Borra filas en Inscripciones asociadas a este alumno.
            Inscripciones.objects.filter(alumno_id=alumno_id).delete()

            alumno.delete() 

            return redirect('index')
        
        except Alumnos.DoesNotExist:
            # Si el alumno ya fue eliminado se redirige
            return redirect('index')
            
    return redirect('index')
    pass

@login_required
def home_redirect(request):
    usuario = request.user
    
    # Administradores
    if usuario.is_superuser or usuario.groups.filter(name='Administradores').exists():
        return redirect('index') 
    
    # Instructores
    elif usuario.groups.filter(name='Instructores').exists():
        return redirect('panel_instructores') 
    
    # Alumnos
    elif usuario.groups.filter(name='Alumnos').exists():
        return redirect('estudiantes_home') 
    
    # Sin grupo - rol
    else:
        return render(request, 'alumnos/sin_permiso.html')

@login_required
@user_passes_test(es_administrador)
def reportes_view(request):
    top_cursos = []
    top_instructores = []

    with connection.cursor() as cursor:
        # Reporte de Cursos más solicitados
        cursor.execute("EXEC top_cursos_mas_solicitados") 
        top_cursos = dictfetchall(cursor)

        # Reporte de Instructores con más alumnos
        cursor.execute("EXEC TopInstructores")
        top_instructores = dictfetchall(cursor)

    return render(request, 'alumnos/reportes.html', {
        'top_cursos': top_cursos,
        'top_instructores': top_instructores
    })

@login_required
@user_passes_test(es_administrador)
def nueva_inscripcion(request):
    if request.method == 'POST':
        form = AltaInscripcionForm(request.POST)
        if form.is_valid():
            data = form.cleaned_data
            alumno_id = data['alumno'].alumno_id
            curso_seleccionado = data['curso']
            
            # Obtener precio de sql
            precio_real = curso_seleccionado.costo
            
            # Variables
            precio_final = precio_real
            total_final = precio_real
            
            # Descuento Diciembre
            mes_actual = datetime.now().month
            
            if mes_actual == 12: # Diciembre
                descuento = Decimal('0.20')
                precio_final = precio_real * (1 - descuento)
                total_final = precio_real * (1 - descuento)
                
                # Mensaje Descuento
                messages.success(request, f"Se aplicó un 20% de descuento. Precio final: ${total_final:.2f}")
            
            subtotal = data['cantidad'] * precio_final

            try:
                with connection.cursor() as cursor:
                    sql = """
                        EXEC registrar_inscripcion 
                        @alumno_id=%s, @curso_id=%s, @instructor_id=%s, 
                        @fecha_inscripcion=GETDATE(), 
                        @metodo_pago=%s, @estado_inscripcion='Activa', 
                        @total_pago=%s, 
                        @concepto=%s, @cantidad=%s, 
                        @precio_unitario=%s, 
                        @subtotal=%s
                    """
                    params = [
                        alumno_id, curso_seleccionado.curso_id, data['instructor'].instructor_id,
                        data['metodo_pago'], total_final, data['concepto'],
                        data['cantidad'], precio_final, subtotal
                    ]
                    cursor.execute(sql, params)
                
                return redirect('listar_inscripciones')

            except Exception as e:
                messages.error(request, f"Error: {e}")
    else:
        form = AltaInscripcionForm()

    # Se envian los precios
    cursos_activos = Cursos.objects.filter(estado_curso='Activo')
    precios_dict = {curso.curso_id: str(curso.costo) for curso in cursos_activos}

    return render(request, 'alumnos/nueva_inscripcion.html', {
        'form': form,
        'precios_json': json.dumps(precios_dict)
    })

@login_required
@user_passes_test(es_administrador)
def auditoria_view(request):
    aud_alumnos = []
    aud_cursos = []
    aud_instructores = []
    aud_inscripciones = []

    with connection.cursor() as cursor:
        # logs de Alumnos
        cursor.execute("EXEC sp_audit_alumnos")
        aud_alumnos = dictfetchall(cursor)

        # logs de Cursos
        cursor.execute("EXEC sp_audit_cursos")
        aud_cursos = dictfetchall(cursor)

        # logs de Instructores
        cursor.execute("EXEC sp_audit_instructores")
        aud_instructores = dictfetchall(cursor)

        # logs de Inscripciones
        cursor.execute("EXEC sp_audit_inscripciones")
        aud_inscripciones = dictfetchall(cursor)
    
    return render(request, 'alumnos/auditoria.html', {
        'aud_alumnos': aud_alumnos,
        'aud_cursos': aud_cursos,
        'aud_instructores': aud_instructores,
        'aud_inscripciones': aud_inscripciones
    })

@login_required
@user_passes_test(es_administrador)
def listar_inscripciones(request):
    inscripciones = []
    with connection.cursor() as cursor:
        # Se usa 'resumen_gral_academia' para los nombres(ID)
        cursor.execute("EXEC resumen_gral_academia")
        inscripciones = dictfetchall(cursor)
    
    return render(request, 'alumnos/inscripciones_list.html', {
        'inscripciones': inscripciones
    })

def editar_instructor(request, id):
    instructor = Instructores.objects.get(pk=id)
    if request.method == 'POST':
        form = InstructorForm(request.POST, instance=instructor)
        if form.is_valid():
            form.save()
            return redirect('index')
    else:
        form = InstructorForm(instance=instructor)
    
    return render(request, 'alumnos/editar.html', { 
        'form': form 
    })

@login_required
@user_passes_test(es_administrador)
def eliminar_instructor(request, id):
    if request.method == 'POST':
        try:
            instructor = Instructores.objects.get(pk=id)
            instructor.delete()
            return redirect('index')
        except Instructores.DoesNotExist:
            return redirect('index')
    return redirect('index')

@login_required
@user_passes_test(es_administrador)
def agregar_instructor(request):
    if request.method == 'POST':
        form = InstructorForm(request.POST)
        if form.is_valid():
            form.save()
            return redirect('index')
    else:
        form = InstructorForm()
    
    return render(request, 'alumnos/agregar_instructor.html', {
        'form': form
    })

@login_required
@user_passes_test(es_administrador)
def aplicar_descuento_view(request, id):
    if request.method == 'POST':
        porcentaje = request.POST.get('porcentaje')
        
        try:
            with connection.cursor() as cursor:
                # Se ejecuta el procedure
                cursor.execute("EXEC AplicarDescuento %s, %s", [id, porcentaje])
                
            return redirect('listar_inscripciones')
            
        except Exception as e:
            print(f"Error al aplicar descuento: {e}")
            return redirect('listar_inscripciones')
            
    return redirect('listar_inscripciones')

@login_required
@user_passes_test(es_administrador)
def cancelar_inscripcion(request, id):
    if request.method == 'POST':
        try:
            with connection.cursor() as cursor:
                # Se ejecuta cambio estado a 'Cancelada' y liberar cupo
                cursor.execute("EXEC cancelar_inscripcion %s", [id])
                
            messages.success(request, "Inscripción cancelada y cupo liberado correctamente.")
        except Exception as e:
            messages.error(request, f"No se pudo cancelar: {e}")
            
    return redirect('listar_inscripciones')

@login_required
def listar_cursos(request):
    cursos = []
    with connection.cursor() as cursor:
        # Cursos por ID
        cursor.execute("SELECT * FROM Cursos ORDER BY curso_id DESC")
        cursos = dictfetchall(cursor)
    
    return render(request, 'alumnos/cursos_list.html', {
        'cursos': cursos
    })

@login_required
def actualizar_cupo_view(request, id):
    if request.method == 'POST':
        nueva_capacidad = request.POST.get('capacidad')
        try:
            with connection.cursor() as cursor:
                # Se ejecuta actualizarcupocurso
                cursor.execute("EXEC ActualizarCupoCurso %s, %s", [id, nueva_capacidad])
                
            messages.success(request, "Capacidad del curso actualizada correctamente.")
        except Exception as e:
            messages.error(request, f"Error al actualizar: {e}")
            
    return redirect('listar_cursos')