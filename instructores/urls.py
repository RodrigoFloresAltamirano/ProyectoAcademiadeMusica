from django.urls import path
from . import views

urlpatterns = [
    # Esta ruta se llamará 'panel_instructores'
    # nombre que usamos en el redirect de alumnos/views.py
    path('', views.index, name='panel_instructores'),
]