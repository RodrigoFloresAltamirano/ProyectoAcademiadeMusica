from django import forms
from .models import Alumnos, Cursos, Instructores

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

class AltaInscripcionForm(forms.Form):
    # Selectores para las llaves foráneas
    alumno = forms.ModelChoiceField(queryset=Alumnos.objects.all(), label="Alumno")
    curso = forms.ModelChoiceField(queryset=Cursos.objects.filter(estado_curso='Activo'), label="Curso")
    instructor = forms.ModelChoiceField(queryset=Instructores.objects.filter(estado='Activo'), label="Instructor")
    
    # Datos de pago y detalle
    metodo_pago = forms.ChoiceField(choices=[('Efectivo', 'Efectivo'), ('Tarjeta', 'Tarjeta'), ('Transferencia', 'Transferencia')])
    total_pago = forms.DecimalField(max_digits=10, decimal_places=2)
    concepto = forms.CharField(max_length=50, initial="Mensualidad")
    
    # Estos campos son para el Detalle_Inscripciones que pide tu SP
    cantidad = forms.IntegerField(initial=1)
    precio_unitario = forms.DecimalField(max_digits=10, decimal_places=2)

class InstructorForm(forms.ModelForm):
    class Meta:
        model = Instructores
        fields = ['instructor_id', 'nombre_completo', 'especialidad', 'estado', 'fecha_ingreso']
        widgets = {
            'instructor_id': forms.NumberInput(attrs={'class': 'form-control', 'readonly': 'readonly'}),
            'nombre_completo': forms.TextInput(attrs={'class': 'form-control'}),
            'especialidad': forms.TextInput(attrs={'class': 'form-control'}),
            'estado': forms.Select(choices=[('Activo', 'Activo'), ('Inactivo', 'Inactivo')], attrs={'class': 'form-control'}),
            'fecha_ingreso': forms.DateInput(attrs={'class': 'form-control', 'type': 'date'}),
        }