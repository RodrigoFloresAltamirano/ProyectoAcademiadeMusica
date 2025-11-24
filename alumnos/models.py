from django.db import models

# Create your models here.
class Alumno(models.Model):
    numero_alumno = models.PositiveIntegerField()
    nombre = models.CharField(max_length=50)
    apellido = models.CharField(max_length=50)
    correo = models.EmailField(max_length=100)
    campo_estudio = models.CharField(max_length=50)
    promedio = models.FloatField()

def __str__(self):# Representacion en cadena del objeto Estudiante
    return f'Alumno: {self.nombre} {self.apellido}'