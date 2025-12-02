from django.http import HttpResponseRedirect
from django.shortcuts import render
from django.urls import reverse

from .models import Alumnos
from .forms import AlumnoForm

# Create your views here.

def index(request):
    return render(request, 'alumnos/index.html',{
        'alumnos': Alumnos.objects.all()
    })

def view_alumno(request, id):
    alumno = Alumnos.objects.get(pk=id)
    return HttpResponseRedirect(reverse('index'))

def add(request):
    if request.method == 'POST':
        form = AlumnoForm(request.POST)
        if form.is_valid():
            nuevo_alumno_id = form.cleaned_data['alumno_id']
            nuevo_nombre_completo = form.cleaned_data['nombre_completo']
            nuevo_email = form.cleaned_data['email']
            nuevo_telefono = form.cleaned_data['telefono']
            nuevo_direccion = form.cleaned_data['direccion']
            nuevo_tipo_documento = form.cleaned_data['tipo_documento']
            nuevo_numero_documento = form.cleaned_data['numero_documento']
            nuevo_fecha_registro = form.cleaned_data['fecha_registro']

            nuevo_alumno = Alumnos(
                alumno_id=nuevo_alumno_id,
                nombre_completo=nuevo_nombre_completo,
                email=nuevo_email,
                telefono=nuevo_telefono,
                direccion=nuevo_direccion,
                tipo_documento=nuevo_tipo_documento,
                numero_documento=nuevo_numero_documento,
                fecha_registro=nuevo_fecha_registro
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

def eliminar(request, id):
    if request.method == 'POST':
        alumno = Alumnos.objects.get(pk=id)
        alumno.eliminar()
    return HttpResponseRedirect(reverse('index'))