from django.urls import path
from . import views

urlpatterns = [
    path('', views.home_redirect, name='home'),

    # Solo se entra aquí si el home_redirect envía o si es admin.
    path('administracion/', views.index, name='index'),

    path('<int:id>', views.view_alumno, name='view_alumno'),
    path('agregar/', views.add, name='agregar'),
    path('editar/<int:id>/', views.editar, name='editar'),
    path('eliminar/<int:id>/', views.eliminar, name='eliminar'),

    path('reportes/', views.reportes_view, name='reportes'),
    path('inscripciones/nueva/', views.nueva_inscripcion, name='nueva_inscripcion'),
    path('inscripciones/', views.listar_inscripciones, name='listar_inscripciones'),
    path('auditoria/', views.auditoria_view, name='auditoria'),

    path('editar_instructor/<int:id>/', views.editar_instructor, name='editar_instructor'),
    path('eliminar_instructor/<int:id>/', views.eliminar_instructor, name='eliminar_instructor'),
    path('agregar_instructor/', views.agregar_instructor, name='agregar_instructor'),

    path('aplicar_descuento/<int:id>/', views.aplicar_descuento_view, name='aplicar_descuento'),

    path('inscripciones/cancelar/<int:id>/', views.cancelar_inscripcion, name='cancelar_inscripcion'),
    path('cursos/', views.listar_cursos, name='listar_cursos'),
    path('cursos/actualizar_cupo/<int:id>/', views.actualizar_cupo_view, name='actualizar_cupo'),
]