from django.urls import path
from . import views

urlpatterns = [
    path('', views.home, name='estudiantes_home'),
    path('historial/', views.historial, name='estudiantes_historial'),
    path('cursos/', views.cursos_disponibles, name='estudiantes_cursos'),
    path('inscribirse/', views.inscribirse, name='estudiantes_inscripcion'),
]