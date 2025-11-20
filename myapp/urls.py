from django.urls import path
from . import views

urlpatterns = [
    path('', views.index, name="index"),
    path('about/', views.about, name="about"),
    path('hello/<str:username>', views.hello, name="hello"),
    path('cursos/', views.cursos, name="cursos"),
    path('cursos/<int:id>', views.curso_detalles, name="curso_detalles"),
    path('inscripciones/', views.inscripciones, name="inscripciones"),
    path('crear_inscripcion/', views.crear_inscripcion, name="crear_inscripcion"),
    path('crear_curso/', views.crear_curso, name="crear_curso"),
]