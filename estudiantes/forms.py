from django import forms
from alumnos.models import Cursos, Instructores

class InscripcionForm(forms.Form):
    # Select de Cursos Activos
    curso = forms.ModelChoiceField(
        queryset=Cursos.objects.filter(estado_curso='Activo'),
        label="Selecciona el Curso",
        widget=forms.Select(attrs={'class': 'form-select'})
    )
    
    # Select de Instructores Activos
    instructor = forms.ModelChoiceField(
        queryset=Instructores.objects.filter(estado='Activo'),
        label="Selecciona el Instructor",
        widget=forms.Select(attrs={'class': 'form-select'})
    )
    
    METODOS_PAGO = [
        ('Efectivo', 'Efectivo'),
        ('Tarjeta', 'Tarjeta de Crédito/Débito'),
        ('Transferencia', 'Transferencia Bancaria'),
        ('Otro', 'Otro'),
    ]
    
    metodo_pago = forms.ChoiceField(
        choices=METODOS_PAGO,
        label="Método de Pago",
        widget=forms.Select(attrs={'class': 'form-select'})
    )