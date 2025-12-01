from django import forms
from .models import Alumnos

class AlumnoForm(forms.ModelForm):
    class Meta:
        model = Alumnos
        fields = ['alumno_id', 'nombre_completo', 'email', 'telefono', 'direccion', 'tipo_documento', 'numero_documento', 'fecha_registro']
        labels = {
            'alumno_id': 'alumno id',
            'nombre_completo': 'nombre completo',
            'email': 'email',
            'telefono': 'telefono',
            'direccion': 'direccion',
            'tipo_documento': 'tipo documento',
            'numero_documento': 'numero documento',
            'fecha_registro': 'fecha registro',
        }

        widgets = {
            'alumno_id': forms.NumberInput(attrs={'class': 'form-control', 'readonly': 'readonly'}),
            'nombre_completo': forms.TextInput(attrs={'class': 'form-control'}),
            'email': forms.EmailInput(attrs={'class': 'form-control'}),
            'telefono': forms.TextInput(attrs={'class': 'form-control'}),
            'direccion': forms.TextInput(attrs={'class': 'form-control'}),
            'tipo_documento': forms.TextInput(attrs={'class': 'form-control'}),
            'numero_documento': forms.TextInput(attrs={'class': 'form-control'}),
            'fecha_registro': forms.DateInput(attrs={'class': 'form-control', 'type': 'date'}),
        }