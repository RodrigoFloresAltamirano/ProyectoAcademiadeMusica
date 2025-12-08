from django.shortcuts import render, redirect
from django.db import connection
from django.contrib.auth.decorators import login_required
from alumnos.models import Alumnos, Inscripciones
from django.contrib import messages
from .forms import EditarDatosForm, InscripcionForm
import datetime
from decimal import Decimal

# Función para convertir resultados SQL a diccionarios
def dictfetchall(cursor):
    columns = [col[0] for col in cursor.description]
    return [dict(zip(columns, row)) for row in cursor.fetchall()]


@login_required
def home(request):
    try:
        # Se busca al alumno por su email de usuario
        alumno = Alumnos.objects.get(email=request.user.email)
    except Alumnos.DoesNotExist:
        return render(request, 'estudiantes/no_encontrado.html')

    # Para Actualizar Datos
    if request.method == 'POST':
        form = EditarDatosForm(request.POST, instance=alumno)
        if form.is_valid():
            form.save() # Esto ejecuta el UPDATE Alumnos SET
            messages.success(request, 'Datos actualizados correctamente')
            return redirect('estudiantes_home')
    else:
        form = EditarDatosForm(instance=alumno)

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
def inscribirse(request, curso_id=None): 
    if request.method == 'POST':
        form = InscripcionForm(request.POST)
        if form.is_valid():
            try:
                # 1. Obtener datos básicos
                alumno = Alumnos.objects.get(email=request.user.email)
                curso_obj = form.cleaned_data['curso']
                instructor_obj = form.cleaned_data['instructor']
                metodo_pago = form.cleaned_data['metodo_pago']
                
                # 2. Configurar Precios Base
                fecha_hoy = datetime.date.today()
                precio_base = curso_obj.costo
                total_final = precio_base
                mensaje_exito = f'¡Inscripción exitosa al curso {curso_obj.nombre_curso}!'
                
                # --- INICIO LÓGICA DE DESCUENTOS ---
                
                # A) ¿Es Navidad? (Prioridad 1: 20%)
                if fecha_hoy.month == 12:
                    descuento = Decimal('0.20')
                    total_final = precio_base * (1 - descuento)
                    mensaje_exito = f'Se aplico descuento 20% por Promocion Diciembre {curso_obj.nombre_curso}.'
                
                # B) ¿Es Recurrente? (Prioridad 2: 10% - Solo si no se aplicó Navidad)
                else:
                    es_recurrente = Inscripciones.objects.filter(alumno_id=alumno.alumno_id).exists()
                    if es_recurrente:
                        descuento = Decimal('0.10')
                        total_final = precio_base * (1 - descuento)
                        mensaje_exito = f'🌟 ¡Eres Alumno Recurrente! Tienes 10% de descuento en {curso_obj.nombre_curso}.'

                # --- FIN LÓGICA DE DESCUENTOS ---

                # 3. Ejecutar el procedimiento con el PRECIO CALCULADO
                with connection.cursor() as cursor:
                    sql = """
                        EXEC registrar_inscripcion 
                        @alumno_id=%s, @curso_id=%s, @instructor_id=%s, 
                        @fecha_inscripcion=%s, @metodo_pago=%s, @estado_inscripcion=%s, 
                        @total_pago=%s, -- Enviamos el total con descuento
                        @concepto=%s, @cantidad=%s, 
                        @precio_unitario=%s, -- Enviamos el precio unitario con descuento
                        @subtotal=%s
                    """
                    params = [
                        alumno.alumno_id, curso_obj.curso_id, instructor_obj.instructor_id,
                        fecha_hoy, metodo_pago, 'Activa', 
                        total_final, # <--- Variable calculada
                        f'Inscripción: {curso_obj.nombre_curso}', 1, 
                        total_final, # <--- Variable calculada
                        total_final  # <--- Subtotal (cantidad 1)
                    ]
                    cursor.execute(sql, params)
                
                messages.success(request, mensaje_exito)
                return redirect('estudiantes_historial')

            except Exception as e:
                messages.error(request, f"Error al inscribir: {e}")
    else:
        if curso_id:
            form = InscripcionForm(initial={'curso': curso_id})
        else:
            form = InscripcionForm()

    return render(request, 'estudiantes/inscripcion.html', {
        'form': form
    })