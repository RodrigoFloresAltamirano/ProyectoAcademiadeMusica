from django import forms
from .models import Alumno


class AlumnoForm(forms.ModelForm):
    class Meta:
        model = Alumno
        fields = ['numero_alumno', 'nombre', 'apellido', 'correo', 'campo_estudio', 'promedio']
        labels = {
            'numero_alumno': 'Número de Alumno',
            'nombre': 'Nombre',
            'apellido': 'Apellido',
            'correo': 'Correo Electrónico',
            'campo_estudio': 'Campo de Estudio',
            'promedio': 'Promedio',
        }

        widgets = {
            'numero_alumno': forms.NumberInput(attrs={'class': 'form-control'}),
            'nombre': forms.TextInput(attrs={'class': 'form-control'}),
            'apellido': forms.TextInput(attrs={'class': 'form-control'}),
            'correo': forms.EmailInput(attrs={'class': 'form-control'}),
            'campo_estudio': forms.TextInput(attrs={'class': 'form-control'}),
            'promedio': forms.NumberInput(attrs={'class': 'form-control'}),
        }