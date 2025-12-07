# instructores/views.py
from django.shortcuts import render, redirect
from django.contrib.auth.decorators import login_required, user_passes_test
from django.contrib import messages

# Se importa el modelo 'Alumnos' desde la otra aplicación
from alumnos.models import Alumnos,Cursos, Inscripciones

from .forms import ActualizarEstadoCursoForm

# 1. Filtro: ¿Es instructor?
def es_instructor(user):
    return user.groups.filter(name='Instructores').exists()

# 2. Vista del Panel de Instructores
@login_required
@user_passes_test(es_instructor)
def index(request):
    # Esta vista carga la plantilla que NO tiene botones de editar/borrar
    return render(request, 'instructores/index.html', {
        'alumnos': Alumnos.objects.all()
    })

# 3. Cursos Asiganados
@login_required
@user_passes_test(es_instructor)
def cursos_asignados(request):
    instructor_id = request.user.id

    cursos = Cursos.objects.all()

    return render(request, "instructores/cursos_asignados.html", {
        "cursos": cursos
    })

# 4. Actualizar estado de curso
@login_required
@user_passes_test(es_instructor)
def actualizar_estado_curso(request, curso_id):
    curso = Cursos.objects.get(curso_id=curso_id)
    
    if request.method == "POST":
        form = ActualizarEstadoCursoForm(request.POST, instance=curso)
        if form.is_valid():
            # Usar update para actualizar solo el campo estado_curso
            Cursos.objects.filter(curso_id=curso_id).update(estado_curso=form.cleaned_data['estado_curso'])
            messages.success(request, "Estado del curso actualizado correctamente.")
            return redirect("cursos_asignados")
    else:
        form = ActualizarEstadoCursoForm(instance=curso)

    return render(request, 'instructores/actualizar_estado.html', {
        'curso': curso,
        'form': form
    })


#5. Historial de Inscripciones
@login_required
@user_passes_test(es_instructor)
def historial_inscripciones(request):
    historial = Inscripciones.objects.all().select_related("alumno", "curso", "instructor")

    return render(request, 'instructores/historial.html', {
        'historial': historial
    })

