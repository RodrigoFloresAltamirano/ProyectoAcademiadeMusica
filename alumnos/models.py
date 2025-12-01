from django.db import models

# Create your models here.

class Alumnos(models.Model):
    alumno_id = models.AutoField(primary_key=True)
    nombre_completo = models.CharField(max_length=100, db_collation='Modern_Spanish_CI_AI', blank=True, null=True)
    email = models.CharField(unique=True, max_length=100, db_collation='Modern_Spanish_CI_AI', blank=True, null=True)
    telefono = models.CharField(max_length=20, db_collation='Modern_Spanish_CI_AI', blank=True, null=True)        
    direccion = models.CharField(max_length=150, db_collation='Modern_Spanish_CI_AI', blank=True, null=True)      
    tipo_documento = models.CharField(max_length=20, db_collation='Modern_Spanish_CI_AI', blank=True, null=True)  
    numero_documento = models.CharField(unique=True, max_length=30, db_collation='Modern_Spanish_CI_AI', blank=True, null=True)
    fecha_registro = models.DateField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'Alumnos'

def __str__(self):# Representacion en cadena del objeto Estudiante
    return f'Alumno: {self.nombre_completo}'