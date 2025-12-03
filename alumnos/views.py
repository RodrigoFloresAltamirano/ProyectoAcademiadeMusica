from django.http import HttpResponseRedirect
from django.shortcuts import render, redirect
from django.urls import reverse

from .models import Alumnos, Inscripciones
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
            
            # **CÓDIGO CORREGIDO:** Usar form.save()
            form.save() 
            
            # Redirigir a la vista de índice para ver el nuevo alumno
            # Es mejor que renderizar el mismo formulario con 'success'
            return redirect('index') 
            
    else:
        form = AlumnoForm()
    
    return render(request, 'alumnos/agregar.html', {
        'form': form
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
    # request.POST para asegurar que solo se ejecuta con el botón del modal
    if request.method == 'POST':
        try:
            # El ID es alumno_id
            alumno_id = id 
            
            # 1. Obtener el alumno a eliminar
            alumno = Alumnos.objects.get(pk=alumno_id)
            
            # 2. Eliminar registros dependientes
            #    Esto borra todas las filas en Inscripciones asociadas a este alumno.
            Inscripciones.objects.filter(alumno_id=alumno_id).delete()

            # 3. Eliminar el alumno (el padre)
            alumno.delete() 

            return redirect('index')
        
        except Alumnos.DoesNotExist:
            # Si el alumno ya fue eliminado, simplemente redirige.
            return redirect('index')
            
    # Si alguien intenta acceder a eliminar por GET, solo redirige
    return redirect('index')