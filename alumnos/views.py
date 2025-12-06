from django.http import HttpResponseRedirect
from django.shortcuts import render, redirect
from django.urls import reverse
from django.contrib.auth.decorators import login_required, user_passes_test

from .models import Alumnos, Inscripciones
from .forms import AlumnoForm

# Create your views here.

def es_administrador(user):
    # Devuelve True si es superusuario O si pertenece al grupo "Administradores"
    return user.is_superuser or user.groups.filter(name='Administradores').exists()

@login_required(login_url='login') # Obliga a iniciar sesión
@user_passes_test(es_administrador, login_url='login') # Obliga a tener el rol
def index(request):
    return render(request, 'alumnos/index.html',{
        'alumnos': Alumnos.objects.all()
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