# instructores/views.py
from django.shortcuts import render
from django.contrib.auth.decorators import login_required, user_passes_test

# Se importa el modelo 'Alumnos' desde la otra aplicación
from alumnos.models import Alumnos 

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