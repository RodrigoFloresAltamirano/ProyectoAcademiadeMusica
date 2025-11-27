from django.http import HttpResponseRedirect
from django.shortcuts import render
from django.urls import reverse

from .models import Alumno
from .forms import AlumnoForm

# Create your views here.
def index(request):
    return render(request, 'alumnos/index.html',{
        'alumnos': Alumno.objects.all()
    })

def view_alumno(request, id):
    alumno = Alumno.objects.get(pk=id)
    return HttpResponseRedirect(reverse('index'))

def add(request):
    if request.method == 'POST':
        form = AlumnoForm(request.POST)
        if form.is_valid():
            nuevo_numero_alumno = form.cleaned_data['numero_alumno']
            nuevo_nombre = form.cleaned_data['nombre']
            nuevo_apellido = form.cleaned_data['apellido']
            nuevo_correo = form.cleaned_data['correo']
            nuevo_campo_estudio = form.cleaned_data['campo_estudio']
            nuevo_promedio = form.cleaned_data['promedio']

            nuevo_alumno = Alumno(
                numero_alumno=nuevo_numero_alumno,
                nombre=nuevo_nombre,
                apellido=nuevo_apellido,
                correo=nuevo_correo,
                campo_estudio=nuevo_campo_estudio,
                promedio=nuevo_promedio
            )
            nuevo_alumno.save()
            return render(request, 'alumnos/agregar.html', {
                'form': AlumnoForm(),
                'success': True
            })
    else:
        form = AlumnoForm()
    return render(request, 'alumnos/agregar.html', {
        'form': AlumnoForm()
    })

def editar(request, id):
    if request.method == 'POST':
        alumno = Alumno.objects.get(pk=id)
        form = AlumnoForm(request.POST, instance=alumno)
        if form.is_valid():
            form.save()
            return render(request, 'alumnos/editar.html', {
                'form': form,
                'success': True
            })
    else:
        alumno = Alumno.objects.get(pk=id)
        form = AlumnoForm(instance=alumno)
    return render(request, 'alumnos/editar.html', {
        'form': form
    })

def eliminar(request, id):
    if request.method == 'POST':
        alumno = Alumno.objects.get(pk=id)
        alumno.eliminar()
    return HttpResponseRedirect(reverse('index'))