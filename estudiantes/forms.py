from django import forms
from alumnos.models import Cursos, Instructores, Alumnos

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

class EditarDatosForm(forms.ModelForm):
    class Meta:
        model = Alumnos
        # Aquí definimos SOLO los campos que permitimos editar.
        # Al no incluir 'tipo_documento' ni 'fecha_registro', desaparecen del formulario.
        fields = ['nombre_completo', 'email', 'telefono', 'direccion']
        
        # Etiquetas personalizadas (opcional)
        labels = {
            'nombre_completo': 'Nombre Completo',
            'email': 'Correo Electrónico',
            'telefono': 'Teléfono',
            'direccion': 'Dirección',
        }

        # Widgets para que se vean bonitos con Bootstrap (clase form-control)
        widgets = {
            'nombre_completo': forms.TextInput(attrs={'class': 'form-control'}),
            'email': forms.EmailInput(attrs={'class': 'form-control', 'readonly': 'readonly'}), # Opcional: readonly si no quieres que cambien su email
            'telefono': forms.TextInput(attrs={'class': 'form-control'}),
            'direccion': forms.TextInput(attrs={'class': 'form-control'}),
        }