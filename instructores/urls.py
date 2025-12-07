from django.urls import path
from . import views

urlpatterns = [
    # Esta ruta se llamará 'panel_instructores'
    # nombre que usamos en el redirect de alumnos/views.py
    path('', views.index, name='panel_instructores'),
    
    # Nuevas rutas
    path('cursos/', views.cursos_asignados, name='cursos_asignados'),
    path('curso/<int:curso_id>/actualizar/', views.actualizar_estado_curso, name='actualizar_estado'),
    path('historial/', views.historial_inscripciones, name='historial_inscripciones'),
]