from django import forms
from alumnos.models import Cursos


class ActualizarEstadoCursoForm(forms.ModelForm):
    class Meta:
        model = Cursos
        fields = ['estado_curso']  # Solo este campo puede editar el instructor

        labels = {
            'estado_curso': 'Estado del Curso',
        }

        widgets = {
            'estado_curso': forms.Select(
                attrs={'class': 'form-select'},
                choices=[
                    ('Activo', 'Activo'),
                    ('Finalizado', 'Finalizado'),
                    ('Cancelado', 'Cancelado'),
                ]
            )
        }
