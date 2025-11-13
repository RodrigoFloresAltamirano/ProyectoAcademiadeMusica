CREATE DATABASE Academia_Musica;
USE Academia_Musica;

CREATE TABLE Alumnos(
	alumno_id INT PRIMARY KEY IDENTITY(1,1),
	nombre_completo VARCHAR(100),
	email VARCHAR(100),
	telefono VARCHAR(20),
	direccion VARCHAR(150),
	tipo_documento VARCHAR(20)
	CHECK (tipo_documento IN ('INE','Pasaporte','Cartilla Militar','Otro')),
	numero_documento VARCHAR(30),
	fecha_registro DATE
);

CREATE TABLE Cursos(
	curso_id INT PRIMARY KEY IDENTITY(1,1),
	nombre_curso VARCHAR(100),
	nivel VARCHAR(50)
		CHECK(nivel IN ('Básico','Intermedio','Avanzado')),
	duracion_semanas INT,
	costo DECIMAL(10,2),
	estado_curso VARCHAR(20)
		CHECK (estado_curso IN ('Activo','Finalizado','Cancelado')),
	fecha_inicio DATE,
	fecha_fin DATE
);


CREATE TABLE Instructores(
	instructor_id INT PRIMARY KEY IDENTITY(1,1),
	nombre_completo VARCHAR(100),
	especialidad VARCHAR(50),
	usuario VARCHAR(50),
	contrasena VARCHAR(100),
	fecha_ingreso DATE,
	estado VARCHAR(20)
		CHECK(estado IN ('Activo','Inactivo'))
);

CREATE TABLE Inscripciones(
	inscripcion_id INT PRIMARY KEY IDENTITY(1,1),
	alumno_id INT,
	curso_id INT,
	instructor_id INT,
	fecha_inscripcion DATE,
	metodo_pago VARCHAR(30)
		CHECK(metodo_pago IN ('Efectivo','Tarjeta','Transferencia')),
	estado_inscripcion VARCHAR(20)
		CHECK(estado_inscripcion IN ('Activa','Cancelada','Finalizada')),
	total_pago DECIMAL(10,2),
	FOREIGN KEY(alumno_id) REFERENCES Alumnos(alumno_id),
	FOREIGN KEY(curso_id) REFERENCES Cursos(curso_id),
	FOREIGN KEY(instructor_id) REFERENCES Instructores(instructor_id)
);


CREATE TABLE Detalle_Inscripciones(
	detalle_id INT PRIMARY KEY IDENTITY(1,1),
	inscripcion_id INT,
	concepto VARCHAR(50),
	cantidad INT,
	precio_unitario DECIMAL(10,2),
	subtotal DECIMAL(10,2),
	FOREIGN KEY(inscripcion_id) REFERENCES Inscripciones(inscripcion_id)
);


CREATE TABLE Aud_Log_Inscrip(
	auditoria_id INT PRIMARY KEY IDENTITY(1,1),
	tabla_afectada VARCHAR(50)
		CHECK (tabla_afectada IN ('Inscripciones')),
	accion VARCHAR(50)
		CHECK (accion IN ('INSERT')),
	usuario VARCHAR(50),
	fecha_cambio DATETIME DEFAULT GETDATE(),
	descripcion TEXT
);

CREATE TABLE Aud_Elim_Inscrip(
	auditoria_id INT PRIMARY KEY IDENTITY(1,1),
	tabla_afectada VARCHAR(50)
		CHECK (tabla_afectada IN ('Inscripciones')),
	accion VARCHAR(50)
		CHECK (accion IN ('DELETE')),
	usuario VARCHAR(50),
	fecha_cambio DATETIME DEFAULT GETDATE(),
	descripcion TEXT
);

CREATE TABLE Aud_Act_Inscrip(
	auditoria_id INT PRIMARY KEY IDENTITY(1,1),
	tabla_afectada VARCHAR(50)
		CHECK (tabla_afectada IN ('Inscripciones')),
	accion VARCHAR(50)
		CHECK (accion IN ('UPDATE')),
	usuario VARCHAR(50),
	fecha_cambio DATETIME DEFAULT GETDATE(),
	descripcion TEXT
);

CREATE TABLE Aud_Log_Cursos(
	auditoria_id INT PRIMARY KEY IDENTITY(1,1),
	tabla_afectada VARCHAR(50)
		CHECK (tabla_afectada IN ('Cursos')),
	accion VARCHAR(50)
		CHECK (accion IN ('INSERT')),
	usuario VARCHAR(50),
	fecha_cambio DATETIME DEFAULT GETDATE(),
	descripcion TEXT
);

CREATE TABLE Aud_Elim_Cursos(
	auditoria_id INT PRIMARY KEY IDENTITY(1,1),
	tabla_afectada VARCHAR(50)
		CHECK (tabla_afectada IN ('Cursos')),
	accion VARCHAR(50)
		CHECK (accion IN ('DELETE')),
	usuario VARCHAR(50),
	fecha_cambio DATETIME DEFAULT GETDATE(),
	descripcion TEXT
);

CREATE TABLE Aud_Act_Cursos(
	auditoria_id INT PRIMARY KEY IDENTITY(1,1),
	tabla_afectada VARCHAR(50)
		CHECK (tabla_afectada IN ('Cursos')),
	accion VARCHAR(50)
		CHECK (accion IN ('UPDATE')),
	usuario VARCHAR(50),
	fecha_cambio DATETIME DEFAULT GETDATE(),
	descripcion TEXT
);

CREATE TABLE Aud_Log_Instruc(
	auditoria_id INT PRIMARY KEY IDENTITY(1,1),
	tabla_afectada VARCHAR(50)
		CHECK (tabla_afectada IN ('Instructores')),
	accion VARCHAR(50)
		CHECK (accion IN ('INSERT')),
	usuario VARCHAR(50),
	fecha_cambio DATETIME DEFAULT GETDATE(),
	descripcion TEXT
);

CREATE TABLE Aud_Elim_Instruc(
	auditoria_id INT PRIMARY KEY IDENTITY(1,1),
	tabla_afectada VARCHAR(50)
		CHECK (tabla_afectada IN ('Instructores')),
	accion VARCHAR(50)
		CHECK (accion IN ('DELETE')),
	usuario VARCHAR(50),
	fecha_cambio DATETIME DEFAULT GETDATE(),
	descripcion TEXT
);

CREATE TABLE Aud_Act_Instruc(
	auditoria_id INT PRIMARY KEY IDENTITY(1,1),
	tabla_afectada VARCHAR(50)
		CHECK (tabla_afectada IN ('Instructores')),
	accion VARCHAR(50)
		CHECK (accion IN ('UPDATE')),
	usuario VARCHAR(50),
	fecha_cambio DATETIME DEFAULT GETDATE(),
	descripcion TEXT

);
