from django.shortcuts import render
from .models import Alumno

# Create your views here.
def index(request):
    return render(request, 'alumnos/index.html',{
        'alumnos': Alumno.objects.all()
    })