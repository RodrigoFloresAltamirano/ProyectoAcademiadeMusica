from django.shortcuts import render, redirect
from django.db import connection
from django.contrib.auth.decorators import login_required
from alumnos.models import Alumnos
from django.contrib import messages
from .forms import InscripcionForm
import datetime

# Función para convertir resultados SQL a diccionarios
def dictfetchall(cursor):
    columns = [col[0] for col in cursor.description]
    return [dict(zip(columns, row)) for row in cursor.fetchall()]

# Actualizar datos personales
from alumnos.forms import AlumnoForm 

@login_required
def home(request):
    try:
        # Se busca al alumno por su email de usuario
        alumno = Alumnos.objects.get(email=request.user.email)
    except Alumnos.DoesNotExist:
        return render(request, 'estudiantes/no_encontrado.html')

    # Para Actualizar Datos
    if request.method == 'POST':
        form = AlumnoForm(request.POST, instance=alumno)
        if form.is_valid():
            form.save() # Esto ejecuta el UPDATE Alumnos SET
            messages.success(request, 'Datos actualizados correctamente')
            return redirect('estudiantes_home')
    else:
        form = AlumnoForm(instance=alumno)

    return render(request, 'estudiantes/home.html', {
        'form': form,
        'alumno': alumno
    })

# Consultar historial
@login_required
def historial(request):
    try:
        alumno = Alumnos.objects.get(email=request.user.email)
        
        # ejecuta procedimiento
        with connection.cursor() as cursor:
            cursor.execute("EXEC historial_alumno %s", [alumno.alumno_id])
            resultado_historial = dictfetchall(cursor)
            
        return render(request, 'estudiantes/historial.html', {
            'historial': resultado_historial
        })
    except Exception as e:
        print(e)
        return render(request, 'estudiantes/error.html')

# Consultar cursos disponibles
@login_required
def cursos_disponibles(request):
    with connection.cursor() as cursor:
        # Consulta a tabla de Cursos
        cursor.execute("SELECT * FROM Cursos WHERE estado_curso = 'Activo'")
        cursos = dictfetchall(cursor)
        
    return render(request, 'estudiantes/cursos.html', {
        'cursos': cursos
    })

@login_required
def inscribirse(request):
    if request.method == 'POST':
        form = InscripcionForm(request.POST)
        if form.is_valid():
            try:
                # Obtener datos del formulario y del usuario
                alumno = Alumnos.objects.get(email=request.user.email)
                curso_obj = form.cleaned_data['curso']
                instructor_obj = form.cleaned_data['instructor']
                metodo_pago = form.cleaned_data['metodo_pago']
                
                # Cantidad 1 y costo del curso es el total
                fecha_hoy = datetime.date.today()
                costo = curso_obj.costo # Costo de la tabla cursos
                
                # Se ejecuta el procedimiento
                with connection.cursor() as cursor:
                    sql = """
                        EXEC registrar_inscripcion 
                        @alumno_id=%s, @curso_id=%s, @instructor_id=%s, 
                        @fecha_inscripcion=%s, @metodo_pago=%s, @estado_inscripcion=%s, 
                        @total_pago=%s, @concepto=%s, @cantidad=%s, 
                        @precio_unitario=%s, @subtotal=%s
                    """
                    # Parametros
                    params = [
                        alumno.alumno_id,
                        curso_obj.curso_id,
                        instructor_obj.instructor_id,
                        fecha_hoy,              # fecha_inscripcion
                        metodo_pago,
                        'Activa',               # estado_inscripcion
                        costo,                  # total_pago
                        f'Inscripción: {curso_obj.nombre_curso}', # concepto
                        1,
                        costo,                  # precio_unitario
                        costo                   # subtotal
                    ]
                    
                    cursor.execute(sql, params)
                
                # Mensaje de que se realizo correctamente
                messages.success(request, f'¡Inscripción exitosa al curso {curso_obj.nombre_curso}!')
                return redirect('estudiantes_historial')

            except Exception as e:
                # Si no hay cupos se captura
                messages.error(request, f"Error al inscribir: {e}")
    else:
        form = InscripcionForm()

    return render(request, 'estudiantes/inscripcion.html', {
        'form': form
    })