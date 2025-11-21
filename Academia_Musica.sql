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
	capacidad INT,
	cupo_ocupado INT,
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

use Academia_Musica
-- REQUISITOS TECNICOS

-- 1. TRIGGERS
--•	Validacion de disponibilidad de cupos antes de registrar una inscripcion.
CREATE TRIGGER trg_validar_cupos_inscripcion
ON Inscripciones
INSTEAD OF INSERT
AS
BEGIN   
    DECLARE @curso_id INT, @cupo_ocupado INT, @capacidad INT;
    
    SELECT @curso_id = curso_id FROM inserted;
    
    SELECT @cupo_ocupado = cupo_ocupado, @capacidad = capacidad 
    FROM Cursos 
    WHERE curso_id = @curso_id;
    
    IF (@cupo_ocupado >= @capacidad)
    BEGIN
        RAISERROR('No hay cupos disponibles para este curso', 16, 1);
        RETURN;
    END
    ELSE
    BEGIN
        -- Insertar la inscripción
        INSERT INTO Inscripciones (alumno_id, curso_id, instructor_id, fecha_inscripcion, metodo_pago, estado_inscripcion, total_pago)
        SELECT alumno_id, curso_id, instructor_id, fecha_inscripcion, 
               metodo_pago, estado_inscripcion, total_pago
        FROM inserted;
        
        -- Actualizar cupo ocupado
        UPDATE Cursos 
        SET cupo_ocupado = cupo_ocupado + 1 
        WHERE curso_id = @curso_id;
    END
END;

--•	Registro de auditorias automaticas al modificar, cancelar o eliminar inscripciones 
--(usando más de una tabla de auditoría).
--Trigger insercion inscripciones
CREATE TRIGGER trg_aud_inscrip_insert
ON Inscripciones
AFTER INSERT 
AS 
BEGIN
	INSERT INTO Aud_Log_Inscrip(tabla_afectada,tabla_afectada,accion,usuario,descripcion)
	SELECT 'Inscripciones','INSERT',SYSTEM_USER,'Nueva inscripción registrada';
END;
--Trigger eliminacion inscripciones
CREATE TRIGGER trg_aud_inscrip_delete
ON Inscripciones
AFTER DELETE
AS
BEGIN
	INSERT INTO Aud_Elim_Inscrip(tabla_afectada,tabla_afectada,accion,usuario,descripcion)
	SELECT 'Inscripciones','DELETE',SYSTEM_USER,'Inscripción eliminada'
END;
--Trigger actualizacion inscripciones
CREATE TRIGGER trg_aud_inscripciones_update
ON Inscripciones
AFTER UPDATE
AS
BEGIN
    INSERT INTO Aud_Act_Inscrip(tabla_afectada, accion, usuario, descripcion)
    SELECT 
        'Inscripciones' AS tabla_afectada,
        'UPDATE' AS accion,
        SYSTEM_USER AS usuario,
        CONCAT(
            'Se actualizó la inscripción ID=', i.inscripcion_id,
            '. Estado previo: ', d.estado_inscripcion,
            ', Estado nuevo: ', i.estado_inscripcion,
            '. Pago previo: ', d.total_pago,
            ', Pago nuevo: ', i.total_pago
        ) AS descripcion
    FROM inserted i
    INNER JOIN deleted d ON i.inscripcion_id = d.inscripcion_id;
END;


--•	Actualizacion automatica del estado del curso (Activo, Finalizado, Cancelado).
CREATE TRIGGER trg_actualizar_estado_curso
ON Cursos
AFTER UPDATE
AS 
BEGIN
	--Estado ACTIVO
	UPDATE Cursos
	SET estado_curso = 'Activo'
	FROM Cursos
	INNER JOIN inserted ON Cursos.curso_id = inserted.curso_id
	WHERE GETDATE() BETWEEN Cursos.fecha_inicio AND Cursos.fecha_fin
	AND Cursos.estado_curso = 'Activo';

	--ESTADO CANCELADO
	UPDATE Cursos
	SET estado_curso = 'Cancelado'
	FROM Cursos
	INNER JOIN inserted ON  Cursos.curso_id = inserted.curso_id
	WHERE inserted.estado_curso = 'Cancelado';

	--ESTADO FINALIZADO
	UPDATE Cursos
	SET estado_curso = 'Finalizado'
	FROM Cursos
	INNER JOIN  inserted ON Cursos.curso_id = inserted.curso_id
	WHERE GETDATE() > Cursos.fecha_fin
	AND Cursos.estado_curso = 'Finalizado'
	
	--REGISTRO EN TABLA AUDITORIA
	INSERT INTO Aud_Act_Cursos(tabla_afectada, accion, usuario, descripcion)
    SELECT 'Cursos' AS tabla_afectada,
        'UPDATE' AS accion,
        SYSTEM_USER AS usuario,
        CONCAT(
            'Curso ID=', i.curso_id,
            '. Estado previo: ', d.estado_curso,
            ', Estado nuevo: ', i.estado_curso,
            '. Costo previo: ', d.costo,
            ', Costo nuevo: ', i.costo
        ) AS descripcion
    FROM inserted i
    INNER JOIN deleted d ON i.curso_id = d.curso_id;
END;


--•	Generacion de alertas por baja demanda de cursos o exceso de cupos vacios.
CREATE TRIGGER trg_alerta_baja_demanda
ON Cursos
AFTER UPDATE
AS
BEGIN
    IF UPDATE(cupo_ocupado)
    BEGIN
        DECLARE @curso_id INT, @cupo_ocupado INT, @capacidad INT;
        
        SELECT @curso_id = curso_id, 
		@cupo_ocupado = cupo_ocupado, 
		@capacidad = capacidad

        FROM inserted;
                
        IF @cupo_ocupado < 05.0
        BEGIN
            PRINT 'ALERTA: Curso ID ' + CAST(@curso_id AS VARCHAR) + 
			' tiene solo ' + CAST(@cupo_ocupado AS VARCHAR) + 'cupos ocupados';
        END
    END
END;

--2. TRANSACCIONES
--Proceso completo de inscripcion (Inscripciones + Detalle_Inscripciones) dentro de una transaccion atomica.
--Cancelación de inscripción con reversión de cupo disponible en el curso.
--Uso de COMMIT y ROLLBACK para mantener la integridad de los datos.
--Manejo de errores con TRY/CATCH y registro en la auditoría.

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Inscripciones(alumno_id,curso_id,instructor_id,fecha_inscripcion,metodo_pago,estado_inscripcion,total_pago)
    VALUES (1,2,3,GETDATE(),'Tarjeta','Activa',1500);

    INSERT INTO Detalle_Inscripciones(inscripcion_id,concepto,cantidad,precio_unitario,subtotal)
    VALUES (SCOPE_IDENTITY(),'Mensualidad',1,1500,1500);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    INSERT INTO Auditoria(tabla_afectada,accion,usuario,descripcion)
    VALUES('Inscripciones','ERROR',SYSTEM_USER,ERROR_MESSAGE());
END CATCH;

--3. Procedimientos Almacenados (10%)
--Registrar una nueva inscripcion con validación de cupos e informacion del alumno.

CREATE PROCEDURE registrar_inscripcion
@alumno_id INT,
@curso_id INT,
@instructor_id INT,
@fecha_inscripcion DATE,
@metodo_pago VARCHAR(30),
@estado_inscripcion VARCHAR(20),
@total_pago DECIMAL(10,2),
@concepto VARCHAR(50),
@cantidad INT,
@precio_unitario DECIMAL(10,2),
@subtotal DECIMAL(10,2)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			
		--VALIDACION DE CUPO DISPONIBLE
		DECLARE @cupo_disponible INT;
        SELECT @cupo_disponible = capacidad - cupo_ocupado 
        FROM Cursos 
        WHERE curso_id = @curso_id;

		IF @cupo_disponible <= 0
		BEGIN
			RAISERROR('No hay cupos disponibles para este curso',16,1)
			ROLLBACK TRANSACTION
			RETURN;
		END;

		--Insertar inscripcion personal
		INSERT INTO Inscripciones(alumno_id,curso_id,instructor_id,
			fecha_inscripcion,metodo_pago,estado_inscripcion,total_pago)
		VALUES(@alumno_id,@curso_id,@instructor_id,@fecha_inscripcion,@metodo_pago,
			@estado_inscripcion,@total_pago)

		DECLARE @inscripcion_id INT = SCOPE_IDENTITY();

		-- Insertar detalles de inscripción
        INSERT INTO Detalle_Inscripciones (inscripcion_id, concepto, cantidad,
			precio_unitario, subtotal)
        VALUES(@inscripcion_id, @concepto, @cantidad, @precio_unitario, @subtotal)
        
        -- Actualizar cupo ocupado
        UPDATE Cursos 
        SET cupo_ocupado = cupo_ocupado + 1 
        WHERE curso_id = @curso_id;
		
		-- Registrar en auditoria
        INSERT INTO Aud_Log_Inscrip (tabla_afectada, accion, usuario, descripcion)
        VALUES ('Inscripciones', 'INSERT', SYSTEM_USER, 
                'Nueva inscripción ID: ' + CAST(@inscripcion_id AS VARCHAR(10)));
		
        COMMIT TRANSACTION;        
        PRINT 'Inscripción realizada exitosamente. ID: ' + CAST(@inscripcion_id AS VARCHAR);
		
	END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

        -- Registrar error
        INSERT INTO Errores(usuario_error, procedimiento_error, mensaje_error)
        VALUES (SYSTEM_USER, 'registrar_inscripcion', ERROR_MESSAGE());
        
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Error en el proceso de inscripción: %s', 16, 1, @ErrorMessage)
    END CATCH
END;

--•	Cancelacion de inscripcion con reversion de cupo disponible en el curso.
--•	Uso de COMMIT y ROLLBACK para mantener la integridad de los datos.
--•	Manejo de errores con TRY/CATCH y registro en la auditoria.
CREATE PROCEDURE cancelar_inscripcion
@inscripcion_id INT
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION

		DECLARE @curso_id INT, @estado_actual VARCHAR(20)

		SELECT @curso_id = curso_id, @estado_actual = estado_inscripcion
		FROM Inscripciones
		WHERE inscripcion_id = @inscripcion_id
		
		IF @estado_actual = 'Cancelada'
		BEGIN 
			RAISERROR('La inscripción ya esta cancelada',16,1)
			ROLLBACK;
			RETURN;
		END

		--Actualizar estado de inscripcion
		UPDATE Inscripciones
		SET estado_inscripcion = 'Cancelada'
		WHERE inscripcion_id = @inscripcion_id

		--Liberar cupo
		UPDATE Cursos
		SET cupo_ocupado = cupo_ocupado - 1 
        WHERE curso_id = @curso_id;
        
        COMMIT TRANSACTION;
        
        PRINT 'Inscripción cancelada exitosamente';
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        INSERT INTO Errores(usuario_error, procedimiento_error, mensaje_error)
        VALUES (SYSTEM_USER, 'SP_Cancelar_Inscripcion', ERROR_MESSAGE());
        
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        RAISERROR('Error al cancelar inscripción: %s', 16, 1, @ErrorMessage);
    END CATCH
END;


--•	Consultar el historial de cursos tomados por un alumno.
CREATE OR ALTER PROCEDURE historial_alumno
@alumno_id INT
AS
BEGIN
    SELECT i.inscripcion_id,
           c.nombre_curso,
           c.nivel,
           i.fecha_inscripcion,
           i.estado_inscripcion,
           i.total_pago
    FROM Inscripciones i
    JOIN Cursos c ON c.curso_id = i.curso_id
    WHERE i.alumno_id = @alumno_id
    ORDER BY i.fecha_inscripcion DESC;
END;

--•	Generar reportes de cursos más solicitados o instructores con más inscripciones.
CREATE PROCEDURE CursosMasSolicitados
AS
BEGIN
    SELECT TOP 5 C.curso_id, C.nombre_curso, COUNT(I.inscripcion_id) as total_inscripciones
    FROM Cursos C
    INNER JOIN Inscripciones I ON C.curso_id = I.curso_id
    GROUP BY C.curso_id, C.nombre_curso
    ORDER BY total_inscripciones DESC;
END;

--•	Actualizar la disponibilidad de cupos por curso.
CREATE PROCEDURE ActualizarCupoCurso
    @curso_id INT,
    @capacidad INT
AS
BEGIN
    UPDATE Cursos
    SET capacidad = @capacidad
    WHERE curso_id = @curso_id;
END;

SELECT * FROM Cursos
--•	Aplicar descuentos por promociones o alumno recurrente.
CREATE PROCEDURE SP_AplicarDescuento
    @inscripcion_id INT,
    @porcentaje_descuento DECIMAL(5,2)
AS
BEGIN
    BEGIN TRANSACTION;

    UPDATE Inscripciones
    SET total_pago = total_pago * (1 - @porcentaje_descuento/100)
    WHERE inscripcion_id = @inscripcion_id;

    UPDATE Detalle_Inscripciones
    SET precio_unitario = precio_unitario * (1 - @porcentaje_descuento/100),
        subtotal = cantidad * (precio_unitario * (1 - @porcentaje_descuento/100))
    WHERE inscripcion_id = @inscripcion_id;

    COMMIT TRANSACTION;
END;

--4. Tablas de Auditoria (10%)
--Registro automatico de cambios en Inscripciones, Cursos e Instructores.
--Registro de usuario, fecha y tipo de cambio (INSERT, UPDATE, DELETE).
--Conservacion de valores previos y nuevos en campos auditados.
--Uso de multiples tablas de auditoria, no una sola centralizada.
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
	tabla_afectada VARCHAR(50),
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

--5. Secuencias (10%)
--•	Generacion automatica de IDs unicos en alumnos, cursos e inscripciones.
--•	Uso de secuencias o campos IDENTITY según el motor SQL.
--•	Control de numeracion secuencial para trazabilidad de registros.

--SE USARON CAMPOS IDENTITY


-- 6. Técnicas Avanzadas (10%)
--•	PIVOT: Reporte de numero de inscripciones por mes y por curso.
CREATE PROCEDURE InscripcionesPorMes2025
AS
BEGIN
	SELECT *
	FROM
	(
		SELECT c.nombre_curso,
			   DATENAME(MONTH, i.fecha_inscripcion) + ' ' + CAST(YEAR(i.fecha_inscripcion) AS VARCHAR(4)) AS Mes,
			   1 AS Cantidad
		FROM Inscripciones i
		JOIN Cursos c ON i.curso_id = c.curso_id
		WHERE i.fecha_inscripcion >= DATEADD(MONTH, -11, GETDATE())
	) AS Fuente
	PIVOT
	(
		SUM(Cantidad)
		FOR Mes IN (
			[Enero 2025], [Febrero 2025], [Marzo 2025], [Abril 2025], [Mayo 2025],
			[Junio 2025],[Julio 2025], [Agosto 2025], [Septiembre 2025], [Octubre 2025], 
			[Noviembre 2025], [Diciembre 2025]
		)
	) AS Pvt
END;

--•	CASE: Clasificacion de alumnos según nivel o frecuencia de participacion.

--•	Subconsultas: Para identificar cursos activos o inscripciones vigentes.

--•	JOINs: Entre Alumnos, Cursos, Instructores e Inscripciones.

--•	RANKING: Para mostrar el Top 5 cursos más solicitados.


-- 7. Indices y Sequence (10%)
-- Indice unico en email de Alumnos
CREATE UNIQUE INDEX IX_Alumnos_Email ON Alumnos (email);

-- Indices en estado_curso, fecha_inscripcion y nombre_curso
CREATE NONCLUSTERED INDEX IX_Cursos_Estado ON Cursos (estado_curso);
CREATE NONCLUSTERED INDEX IX_Inscripciones_Fecha ON Inscripciones (fecha_inscripcion);
CREATE NONCLUSTERED INDEX IX_Cursos_Nombre ON Cursos (nombre_curso);

-- Indice compuesto en (curso_id, fecha_inicio) para reportes por periodo
CREATE INDEX IX_Cursos_Periodo ON Cursos (curso_id, fecha_inicio);

-- Indice unico en numero_documento (asumiendo que es unico por alumno)
CREATE UNIQUE INDEX UX_Alumnos_Doc ON Alumnos (numero_documento);

--8. Errores
CREATE TABLE Errores(
	error_id INT PRIMARY KEY IDENTITY(1,1),
	fecha_error DATETIME DEFAULT GETDATE(),
	usuario_error VARCHAR(50),
	procedimiento_error VARCHAR(50),
	mensaje_error VARCHAR(MAX)
);

