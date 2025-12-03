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

# ----------------------------------------------------
# Modelo para acceder a la tabla Inscripciones
# ----------------------------------------------------
class Cursos(models.Model):
    # modelo para Inscripciones
    # Solo es necesario definir la PK y la FK.
    curso_id = models.AutoField(primary_key=True)
    nombre_curso = models.CharField(max_length=100, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'Cursos'
        
class Instructores(models.Model):
    instructor_id = models.AutoField(primary_key=True)
    
    class Meta:
        managed = False
        db_table = 'Instructores'
        
class Inscripciones(models.Model):
    inscripcion_id = models.AutoField(primary_key=True)
    # Relación con Alumnos
    alumno = models.ForeignKey(
        Alumnos, 
        models.DO_NOTHING, # DO_NOTHING porque la BD ya gestiona la FK
        db_column='alumno_id', 
        related_name='inscripciones'
    )
    # Relación con Cursos e Instructores
    curso = models.ForeignKey(Cursos, models.DO_NOTHING, db_column='curso_id')
    instructor = models.ForeignKey(Instructores, models.DO_NOTHING, db_column='instructor_id')
    
    fecha_inscripcion = models.DateField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'Inscripciones'