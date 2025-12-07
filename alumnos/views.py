from django.http import HttpResponseRedirect
from django.shortcuts import render, redirect
from django.urls import reverse
from django.contrib.auth.decorators import login_required, user_passes_test

from .models import Alumnos, Inscripciones, Instructores
from .forms import AlumnoForm, AltaInscripcionForm, InstructorForm
from django.db import connection
from django.contrib import messages
from decimal import Decimal #para el descuento

def dictfetchall(cursor):
    """
    Convierte todas las filas de un cursor de base de datos en una lista de diccionarios.
    """
    columns = [col[0] for col in cursor.description]
    return [
        dict(zip(columns, row))
        for row in cursor.fetchall()
    ]

# Create your views here.

def es_administrador(user):
    # Devuelve True si es superusuario O si pertenece al grupo "Administradores"
    return user.is_superuser or user.groups.filter(name='Administradores').exists()

@login_required(login_url='login') # Obliga a iniciar sesión
@user_passes_test(es_administrador, login_url='login') # Obliga a tener el rol
def index(request):
    return render(request, 'alumnos/index.html',{
        'alumnos': Alumnos.objects.all(),
        'instructores': Instructores.objects.all() # <--- AGREGADO NUEVO
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
            
            # Redirigir a la vista de índice para ver el nuevo alumno
            # Es mejor que renderizar el mismo formulario con 'success'
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
            # El ID es alumno_id
            alumno_id = id 
            
            # Obtener el alumno a eliminar
            alumno = Alumnos.objects.get(pk=alumno_id)
            
            # Eliminar registros dependientes
            # Borra filas en Inscripciones asociadas a este alumno.
            Inscripciones.objects.filter(alumno_id=alumno_id).delete()

            # Eliminar el alumno
            alumno.delete() 

            return redirect('index')
        
        except Alumnos.DoesNotExist:
            # Si el alumno ya fue eliminado se redirige
            return redirect('index')
            
    # Solo redirige
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
    
    # Sin Permiso (Si no tiene grupo, rol)
    else:
        return render(request, 'alumnos/sin_permiso.html')

@login_required
@user_passes_test(es_administrador)
def reportes_view(request):
    data_top_cursos = []
    data_mensual = []

    with connection.cursor() as cursor:
        # 1. Ejecutar SP de Top Cursos
        cursor.execute("EXEC top_cursos_mas_solicitados") 
        data_top_cursos = dictfetchall(cursor)

        # 2. Ejecutar SP de Pivote Mensual (Este es complejo porque devuelve columnas dinámicas)
        cursor.execute("EXEC InscripcionesPorMes2025")
        data_mensual = dictfetchall(cursor)

    return render(request, 'alumnos/reportes.html', {
        'top_cursos': data_top_cursos,
        'mensual': data_mensual
    })

@login_required
@user_passes_test(es_administrador)
def nueva_inscripcion(request):
    if request.method == 'POST':
        form = AltaInscripcionForm(request.POST)
        if form.is_valid():
            data = form.cleaned_data
            alumno_id = data['alumno'].alumno_id
            
            # 1. Precios originales
            precio_unitario = data['precio_unitario']
            total_pago = data['total_pago']
            
            # 2. Lógica Simplificada: ¿Ya se ha inscrito antes?
            es_recurrente = Inscripciones.objects.filter(alumno_id=alumno_id).exists()
            
            # ### DEBUG: ESTO IMPRIMIRÁ EN TU CONSOLA SI LO DETECTA O NO ###
            print(f"--- REVISANDO ALUMNO ID: {alumno_id} ---")
            print(f"--- ¿ES RECURRENTE?: {es_recurrente} ---")

            # 3. Si es recurrente, aplicamos 10% de descuento
            if es_recurrente:
                descuento = Decimal('0.10') # 10% (Ahora funcionará porque importaste Decimal)
                
                # Bajamos los precios
                precio_unitario = precio_unitario * (1 - descuento)
                total_pago = total_pago * (1 - descuento)
                
                # Avisamos al usuario
                messages.success(request, f"¡Alumno Recurrente! Se aplicó descuento automático. Nuevo total: ${total_pago:.2f}")
            else:
                # ### DEBUG: SI ENTRA AQUÍ, ES QUE NO ENCONTRÓ HISTORIAL ###
                print("--- NO SE APLICÓ DESCUENTO ---")

            # Calculamos subtotal nuevo
            subtotal = data['cantidad'] * precio_unitario

            # 4. Guardamos usando tu procedimiento almacenado
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
                        alumno_id, data['curso'].curso_id, data['instructor'].instructor_id,
                        data['metodo_pago'], total_pago, data['concepto'],
                        data['cantidad'], precio_unitario, subtotal
                    ]
                    cursor.execute(sql, params)
                
                return redirect('listar_inscripciones')

            except Exception as e:
                messages.error(request, f"Error: {e}")
    
    else:
        form = AltaInscripcionForm()

    return render(request, 'alumnos/nueva_inscripcion.html', {'form': form})

@login_required
@user_passes_test(es_administrador)
def auditoria_view(request):
    aud_alumnos = []
    aud_cursos = []
    aud_instructores = []
    aud_inscripciones = []

    with connection.cursor() as cursor:
        # 1. Traer logs de Alumnos
        cursor.execute("EXEC sp_audit_alumnos")
        aud_alumnos = dictfetchall(cursor)

        # 2. Traer logs de Cursos
        cursor.execute("EXEC sp_audit_cursos")
        aud_cursos = dictfetchall(cursor)

        # 3. Traer logs de Instructores
        cursor.execute("EXEC sp_audit_instructores")
        aud_instructores = dictfetchall(cursor)

        # 4. Traer logs de Inscripciones
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
        # Usamos tu SP 'resumen_gral_academia' para ver nombres en vez de IDs
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
    
    # Reutilizamos el template de editar, o puedes crear uno nuevo 'editar_instructor.html'
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
        # Obtenemos el porcentaje del formulario HTML
        porcentaje = request.POST.get('porcentaje')
        
        try:
            with connection.cursor() as cursor:
                # Ejecutamos tu Procedimiento Almacenado existente
                cursor.execute("EXEC AplicarDescuento %s, %s", [id, porcentaje])
                
            # Opcional: Podrías agregar mensajes flash aquí si tienes el framework configurado
            return redirect('listar_inscripciones')
            
        except Exception as e:
            print(f"Error al aplicar descuento: {e}")
            return redirect('listar_inscripciones')
            
    return redirect('listar_inscripciones')