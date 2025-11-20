from django.http import HttpResponse
#from .models import Curso, Task
from django.shortcuts import render, redirect, get_object_or_404
#from .forms import CreateNewTask, CreateNewProject

# Cuando no se esta utilizando ninguna funcion se muestra en gris


# Create your views here.
def index(request):#Pagina Principal o Home
    title = "Academia de Musica!!"
    return render(request, "Index.html", {"title": title})

def about(request):#Sobre nosotros(Academia de Musica)
    return HttpResponse("<h1>About Us</h1><p>This is the about page.</p>")

def hello(request):#(Saludo Inicial)
    return HttpResponse("<h1>Hello, World!</h1>")

def cursos(request):
    # cursos = lista(Cursos.objects.values())
    cursos = Curso.objects.all()
    return render(request, "cursos/Cursos.html", {"cursos": cursos})

def curso_detalles(request, id):
    curso = get_object_or_404(Curso, id=id)
    #tasks = Task.objects.filter(curso_id=id)
    return render(request, 'cursos/detalles.html', {
        'curso': curso,
        #'tasks': tasks
    })