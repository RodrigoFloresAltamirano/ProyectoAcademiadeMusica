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

    # Nuevas rutas
    path('reportes/', views.reportes_view, name='reportes'),
    path('inscripciones/nueva/', views.nueva_inscripcion, name='nueva_inscripcion'),
    path('inscripciones/', views.listar_inscripciones, name='listar_inscripciones'), # Necesitarás crear esta vista simple
    path('auditoria/', views.auditoria_view, name='auditoria'),

    path('editar_instructor/<int:id>/', views.editar_instructor, name='editar_instructor'),
    path('eliminar_instructor/<int:id>/', views.eliminar_instructor, name='eliminar_instructor'),
    path('agregar_instructor/', views.agregar_instructor, name='agregar_instructor'),

    path('aplicar_descuento/<int:id>/', views.aplicar_descuento_view, name='aplicar_descuento'),
]