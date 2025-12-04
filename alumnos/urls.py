from django.urls import path
from . import views

urlpatterns = [
    # La raíz '' ahora apunta a la redirección
    # Cuando entras a localhost:8000/, esta función decide a dónde te manda.
    path('', views.home_redirect, name='home'),

    # Se Mueve la vista principal de admin a 'administracion/'
    # Solo se entra aquí si el home_redirect te envía o si eres admin.
    path('administracion/', views.index, name='index'),

    # Las demás rutas se quedan igual (son acciones de admin)
    path('<int:id>', views.view_alumno, name='view_alumno'),
    path('agregar/', views.add, name='agregar'),
    path('editar/<int:id>/', views.editar, name='editar'),
    path('eliminar/<int:id>/', views.eliminar, name='eliminar'),
]