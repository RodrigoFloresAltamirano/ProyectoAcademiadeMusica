CREATE DATABASE Academia_Musica;
USE Academia_Musica;

DROP TABLE Alumnos
DROP TABLE Cursos
DROP TABLE Instructores
DROP TABLE Inscripciones
DROP TABLE Detalle_Inscripciones

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
		CHECK(estado IN ('Activo','Inactivo')));

CREATE TABLE Inscripciones(
	inscripcion_id INT PRIMARY KEY IDENTITY(1,1),
	alumno_id INT,
	curso_id INT,
	instructor_id INT,
	fecha_inscripcion DATE,
	metodo_pago VARCHAR(30)
		CHECK(metodo_pago IN ('Efectivo','Tarjeta','Transferencia','Otro')),
	estado_inscripcion VARCHAR(20)
		CHECK(estado_inscripcion IN ('Activa','Cancelada','Finalizada')),
	total_pago DECIMAL(10,2),
	FOREIGN KEY(alumno_id) REFERENCES Alumnos(alumno_id),
	FOREIGN KEY(curso_id) REFERENCES Cursos(curso_id),
	FOREIGN KEY(instructor_id) REFERENCES Instructores(instructor_id));


CREATE TABLE Detalle_Inscripciones(
	detalle_id INT PRIMARY KEY IDENTITY(1,1),
	inscripcion_id INT,
	concepto VARCHAR(50),
	cantidad INT,
	precio_unitario DECIMAL(10,2),
	subtotal DECIMAL(10,2),
	FOREIGN KEY(inscripcion_id) REFERENCES Inscripciones(inscripcion_id));


--4. Tablas de Auditoría (10%)
--Registro automático de cambios en Inscripciones, Cursos e Instructores.
--Registro de usuario, fecha y tipo de cambio (INSERT, UPDATE, DELETE).
--Conservación de valores previos y nuevos en campos auditados.
--Uso de múltiples tablas de auditoría, no una sola centralizada.
CREATE TABLE Aud_Log_Alumnos(
	auditoria_id INT PRIMARY KEY IDENTITY(1,1),
	tabla_afectada VARCHAR(50)
		CHECK (tabla_afectada IN ('Alumnos')),
	accion VARCHAR(50)
		CHECK (accion IN ('INSERT')),
	usuario VARCHAR(50),
	fecha_cambio DATETIME DEFAULT GETDATE(),
	descripcion TEXT);

CREATE TABLE Aud_Elim_Alumnos(
	auditoria_id INT PRIMARY KEY IDENTITY(1,1),
	tabla_afectada VARCHAR(50)
		CHECK (tabla_afectada IN ('Alumnos')),
	accion VARCHAR(50)
		CHECK (accion IN ('DELETE')),
	usuario VARCHAR(50),
	fecha_cambio DATETIME DEFAULT GETDATE(),
	descripcion TEXT);

CREATE TABLE Aud_Act_Alumnos(
	auditoria_id INT PRIMARY KEY IDENTITY(1,1),
	tabla_afectada VARCHAR(50)
		CHECK (tabla_afectada IN ('Alumnos')),
	accion VARCHAR(50)
		CHECK (accion IN ('UPDATE')),
	usuario VARCHAR(50),
	fecha_cambio DATETIME DEFAULT GETDATE(),
	descripcion TEXT);

CREATE TABLE Aud_Log_Inscrip(
	auditoria_id INT PRIMARY KEY IDENTITY(1,1),
	tabla_afectada VARCHAR(50)
		CHECK (tabla_afectada IN ('Inscripciones')),
	accion VARCHAR(50)
		CHECK (accion IN ('INSERT')),
	usuario VARCHAR(50),
	fecha_cambio DATETIME DEFAULT GETDATE(),
	descripcion TEXT);


CREATE TABLE Aud_Elim_Inscrip(
	auditoria_id INT PRIMARY KEY IDENTITY(1,1),
	tabla_afectada VARCHAR(50)
		CHECK (tabla_afectada IN ('Inscripciones')),
	accion VARCHAR(50)
		CHECK (accion IN ('DELETE')),
	usuario VARCHAR(50),
	fecha_cambio DATETIME DEFAULT GETDATE(),
	descripcion TEXT);

CREATE TABLE Aud_Act_Inscrip(
	auditoria_id INT PRIMARY KEY IDENTITY(1,1),
	tabla_afectada VARCHAR(50)
		CHECK (tabla_afectada IN ('Inscripciones')),
	accion VARCHAR(50)
		CHECK (accion IN ('UPDATE')),
	usuario VARCHAR(50),
	fecha_cambio DATETIME DEFAULT GETDATE(),
	descripcion TEXT);

CREATE TABLE Aud_Log_Cursos(
	auditoria_id INT PRIMARY KEY IDENTITY(1,1),
	tabla_afectada VARCHAR(50)
		CHECK (tabla_afectada IN ('Cursos')),
	accion VARCHAR(50)
		CHECK (accion IN ('INSERT')),
	usuario VARCHAR(50),
	fecha_cambio DATETIME DEFAULT GETDATE(),
	descripcion TEXT);


CREATE TABLE Aud_Elim_Cursos(
	auditoria_id INT PRIMARY KEY IDENTITY(1,1),
	tabla_afectada VARCHAR(50),
		CHECK (tabla_afectada IN ('Cursos')),
	accion VARCHAR(50)
		CHECK (accion IN ('DELETE')),
	usuario VARCHAR(50),
	fecha_cambio DATETIME DEFAULT GETDATE(),
	descripcion TEXT);

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
	descripcion TEXT);

CREATE TABLE Aud_Elim_Instruc(
	auditoria_id INT PRIMARY KEY IDENTITY(1,1),
	tabla_afectada VARCHAR(50)
		CHECK (tabla_afectada IN ('Instructores')),
	accion VARCHAR(50)
		CHECK (accion IN ('DELETE')),
	usuario VARCHAR(50),
	fecha_cambio DATETIME DEFAULT GETDATE(),
	descripcion TEXT);

CREATE TABLE Aud_Act_Instruc(
	auditoria_id INT PRIMARY KEY IDENTITY(1,1),
	tabla_afectada VARCHAR(50)
		CHECK (tabla_afectada IN ('Instructores')),
	accion VARCHAR(50)
		CHECK (accion IN ('UPDATE')),
	usuario VARCHAR(50),
	fecha_cambio DATETIME DEFAULT GETDATE(),
	descripcion TEXT);


--8. Errores
CREATE TABLE Errores(
	error_id INT PRIMARY KEY IDENTITY(1,1),
	fecha_error DATETIME DEFAULT GETDATE(),
	usuario_error VARCHAR(50),
	procedimiento_error VARCHAR(50),
	mensaje_error VARCHAR(MAX)
);	


-- REQUISITOS TÉCNICOS

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

	--•	Registro de auditorías automáticas al modificar, cancelar o eliminar inscripciones 
	--(usando más de una tabla de auditoría).
--Trigger insercion inscripciones
CREATE TRIGGER trg_aud_inscrip_insert
ON Inscripciones
AFTER INSERT 
AS 
BEGIN
	INSERT INTO Aud_Log_Inscrip(tabla_afectada,accion,usuario,descripcion)
	SELECT 'Inscripciones','INSERT',SYSTEM_USER,'Nueva inscripción registrada'
	FROM inserted
END;

--Trigger eliminacion inscripciones
CREATE TRIGGER trg_aud_inscrip_delete
ON Inscripciones
AFTER DELETE
AS
BEGIN
	INSERT INTO Aud_Elim_Inscrip(tabla_afectada,accion,usuario,descripcion)
	SELECT 'Inscripciones','DELETE',SYSTEM_USER,'Inscripción eliminada'
	FROM deleted
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
    FROM deleted d
    INNER JOIN inserted i ON d.inscripcion_id = i.inscripcion_id;
END;

	--TRIGGER PARA AUD_ALUMNOS
--Trigger para insercion de alumnos
CREATE TRIGGER trg_insercion_alumnos
ON Alumnos
AFTER INSERT 
AS 
BEGIN
	INSERT INTO Aud_Log_Alumnos(tabla_afectada,accion,usuario,descripcion)
	SELECT 'Alumnos','INSERT',SYSTEM_USER,'Nuevo estudiante registado'
	FROM inserted
END;

--TRIGGER PARA ELIMINACIÓN DE ALUMNOS
CREATE TRIGGER trg_eliminacion_alumnos
ON Alumnos
AFTER DELETE
AS
BEGIN
	INSERT INTO Aud_Elim_Alumnos(tabla_afectada,accion,usuario,descripcion)
	SELECT 'Alumnos','DELETE',SYSTEM_USER,'Alumno elimnado'
	FROM deleted
END;


--TRIGGER PARA ACTUALIZACIÓN DE ALUMNOS
CREATE TRIGGER trg_actualizacion_alumnos
ON Alumnos
AFTER UPDATE
AS
BEGIN
	INSERT INTO Aud_Act_Alumnos(tabla_afectada, accion, usuario, descripcion)
    SELECT 
        'Alumnos' AS tabla_afectada,
        'UPDATE' AS accion,
        SYSTEM_USER AS usuario,
        CONCAT(
            'Se actualizó el ID del alumno=', i.alumno_id,
            '. Nombre completo previo: ', d.nombre_completo,
            ', Nombre completo nuevo: ', i.nombre_completo,
            '. Email previo: ', d.email,
            ', Email nuevo: ', i.email,
			'. Telefono previo',d.telefono,
			', Telefono nuevo: ', i.telefono,
			'. Direccion previa',d.direccion,
			', Direccion nueva',i.direccion,
			'. Tipo de documento previo',d.tipo_documento,
			', Tipo de documento nuevo',i.tipo_documento,
			'. No. de documento previo',d.numero_documento,
			', No. de documento nuevo',i.numero_documento,
			', Fecha de registro previa',d.fecha_registro,
			', Fecha de registro nueva',i.fecha_registro
        ) AS descripcion
    FROM deleted d
    INNER JOIN inserted i ON d.alumno_id = i.alumno_id;
END;
	
	--TRIGGER PARA AUDITORIA INSTRUCTORES
	--Trigger para insertar instructores
CREATE TRIGGER trg_insercion_instructores
ON Instructores
AFTER INSERT 
AS 
BEGIN
	INSERT INTO Aud_Log_Instruc(tabla_afectada,accion,usuario,descripcion)
	SELECT 'Instructores','INSERT',SYSTEM_USER,'Nuevo instructor registado'
	FROM inserted
END;

	--Trigger para eliminar instructores
CREATE TRIGGER trg_eliminacion_instructores
ON Instructores
AFTER DELETE
AS
BEGIN
	INSERT INTO Aud_Elim_Instruc(tabla_afectada,accion,usuario,descripcion)
	SELECT 'Instructores','DELETE',SYSTEM_USER,'Instructor elimnado'
	FROM deleted
END;


	--Trigger para actualizacion de instructores
CREATE TRIGGER trg_actualizacion_instructores
ON Instructores
AFTER UPDATE
AS
BEGIN
	INSERT INTO Aud_Act_Instruc(tabla_afectada, accion, usuario, descripcion)
    SELECT 
        'Instructores' AS tabla_afectada,
        'UPDATE' AS accion,
        SYSTEM_USER AS usuario,
        CONCAT(
            'Se actualizó el ID del alumno=', i.instructor_id,
            '. Nombre completo previo: ', d.nombre_completo,
            ', Nombre completo nuevo: ', i.nombre_completo,
            '. Especialidad previo: ', d.especialidad,
            ', Especialidad nuevo: ', i.especialidad,
			'. Usuario previo',d.usuario,
			', Usuario nuevo: ', i.usuario,
			'. Contraseña previa',d.contrasena,
			', Contraseña nueva',i.contrasena,
			'. Fecha de ingreso previo',d.fecha_ingreso,
			', Fecha de ingreso nuevo',i.fecha_ingreso,
			'. Estado previo',d.estado,
			', Estado nuevo',i.estado
        ) AS descripcion
    FROM inserted i
    INNER JOIN deleted d ON i.instructor_id = d.instructor_id;
END;

--TRIGGERS AUDITORIA CURSOS
	--Trigger para insertar cursos
CREATE TRIGGER trg_insercion_cursos
ON Cursos
AFTER INSERT 
AS 
BEGIN
	INSERT INTO Aud_Log_Cursos(tabla_afectada,accion,usuario,descripcion)
	SELECT 'Cursos','INSERT',SYSTEM_USER,'Nuevo curso registrado'
	FROM inserted
END;

	--Trigger para eliminar cursos
CREATE TRIGGER trg_eliminacion_cursos
ON Cursos
AFTER DELETE
AS
BEGIN
	INSERT INTO Aud_Elim_Cursos(tabla_afectada,accion,usuario,descripcion)
	SELECT 'Cursos','DELETE',SYSTEM_USER,'Curso eliminado'
	FROM deleted
END;


	--•	Actualización automática del estado del curso (Activo, Finalizado, Cancelado).
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


	--•	Generación de alertas por baja demanda de cursos o exceso de cupos vacíos.
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
	--Proceso completo de inscripción (Inscripciones + Detalle_Inscripciones) dentro de una transacción atómica.
	--Cancelación de inscripción con reversión de cupo disponible en el curso.
	--Uso de COMMIT y ROLLBACK para mantener la integridad de los datos.
	--Manejo de errores con TRY/CATCH y registro en la auditoría.
SELECT * FROM Inscripciones
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
    INSERT INTO Aud_Log_Inscrip(tabla_afectada,accion,usuario,descripcion)
    VALUES('Inscripciones','ERROR',SYSTEM_USER,ERROR_MESSAGE());
END CATCH;

--3. Procedimientos Almacenados (10%)
	--Registrar una nueva inscripción con validación de cupos e información del alumno.
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
			
		--VALIDACIÓN DE CUPO DISPONIBLE
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
		
		-- Registrar en auditoría
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


--•	Cancelación de inscripción con reversión de cupo disponible en el curso.
--•	Uso de COMMIT y ROLLBACK para mantener la integridad de los datos.
--•	Manejo de errores con TRY/CATCH y registro en la auditoría.
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


--•	Aplicar descuentos por promociones o alumno recurrente.
CREATE PROCEDURE AplicarDescuento
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


--5. Secuencias (10%)
--•	Generación automática de IDs únicos en alumnos, cursos e inscripciones.
--•	Uso de secuencias o campos IDENTITY según el motor SQL.
--•	Control de numeración secuencial para trazabilidad de registros.

--SE USARON CAMPOS IDENTITY


-- 6. Técnicas Avanzadas (10%)
--•	PIVOT: Reporte de número de inscripciones por mes y por curso.
CREATE PROCEDURE InscripcionesPorMes2025
AS
BEGIN
	SELECT CURSO,[1] AS Enero,[2] AS Febrero,[3] AS Marzo,[4] AS Abril,[5] AS Mayo,[6] AS Junio,
		[7] AS Julio,[8] AS Agosto,[9] AS Septiembre,[10] AS Octubre,[11] AS Noviembre,[12] AS Diciembre
	FROM (
		SELECT 
			C.nombre_curso AS CURSO,
			MONTH(I.fecha_inscripcion) AS Mes,
			COUNT(I.inscripcion_id) AS Cantidad_Inscripciones
			FROM Inscripciones I
			INNER JOIN Cursos C ON I.curso_id = C.curso_id
			WHERE YEAR(I.fecha_inscripcion) = 2025
			GROUP BY C.nombre_curso, MONTH(I.fecha_inscripcion)
		) AS Fuente
	PIVOT (
		SUM(Cantidad_Inscripciones)
		FOR Mes IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
	) AS PivotInscripciones
	ORDER BY CURSO;
END;

EXEC InscripcionesPorMes2025


--•	CASE: Clasificación de alumnos según nivel o frecuencia de participación.

CREATE PROCEDURE clasificacion_nivel_alumnos
AS
BEGIN
	SELECT 
		a.nombre_completo,
		c.nombre_curso,
		c.nivel,
		CASE
			WHEN c.nivel = 'Básico' THEN 'Nivel Básico - Principiante'
			WHEN c.nivel = 'Intermedio' THEN 'Nivel Intermedio - En desarrollo'
			WHEN c.nivel = 'Avanzado' THEN 'Nivel Avanzado - Experimentado'
			ELSE 'Sin asignar'
		END AS clasificacion_nivel
	FROM Alumnos a
	INNER JOIN Inscripciones i ON a.alumno_id = i.alumno_id
	INNER JOIN Cursos c ON i.curso_id = c.curso_id
	WHERE i.estado_inscripcion = 'Activa' 
	ORDER BY c.nivel, a.nombre_completo;
END;

EXEC clasificacion_nivel_alumnos

--•	Subconsultas: Para identificar cursos activos o inscripciones vigentes.
CREATE PROCEDURE Inscripciones_y_cursos_vigentes
AS
BEGIN	
	SELECT c.curso_id, c.nombre_curso, c.nivel, c.estado_curso,
		   (SELECT COUNT(*) FROM Inscripciones i 
		   WHERE i.curso_id = c.curso_id AND i.estado_inscripcion = 'Activa') AS inscripciones_activas
	FROM Cursos c
	WHERE c.estado_curso = 'Activo';
END;

EXEC Inscripciones_y_cursos_vigentes

--•	JOINs: Entre Alumnos, Cursos, Instructores e Inscripciones.
CREATE PROCEDURE resumen_gral_academia
AS
BEGIN
	SELECT i.inscripcion_id, a.nombre_completo AS alumno, c.nombre_curso, ins.nombre_completo AS instructor, i.fecha_inscripcion, i.total_pago
	FROM Inscripciones i
	JOIN Alumnos a ON i.alumno_id = a.alumno_id
	JOIN Cursos c ON i.curso_id = c.curso_id
	LEFT JOIN Instructores ins ON i.instructor_id = ins.instructor_id;
END;

EXEC resumen_gral_academia;

--•	RANKING: Para mostrar el Top 5 cursos más solicitados.
CREATE PROCEDURE top_cursos_mas_solicitados
AS
BEGIN
	SELECT TOP 5 c.curso_id,
		   c.nombre_curso,
		   COUNT(*) AS inscripciones,
		   DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking
	FROM Inscripciones i
	JOIN Cursos c ON c.curso_id = i.curso_id
	GROUP BY c.curso_id, c.nombre_curso
	ORDER BY inscripciones DESC
END;

EXEC top_cursos_mas_solicitados
-- 7. Índices y Sequence (10%)
-- Índice único en email de Alumnos
CREATE NONCLUSTERED INDEX IX_Alumnos_Email ON Alumnos (email);

-- Índices en estado_curso, fecha_inscripcion y nombre_curso
CREATE NONCLUSTERED INDEX IX_Cursos_Estado ON Cursos (estado_curso);
CREATE NONCLUSTERED INDEX IX_Inscripciones_Fecha ON Inscripciones (fecha_inscripcion);
CREATE NONCLUSTERED INDEX IX_Cursos_Nombre ON Cursos (nombre_curso);

-- Índice compuesto en (curso_id, fecha_inicio) para reportes por periodo
CREATE INDEX IX_Cursos_Periodo ON Cursos (curso_id, fecha_inicio);

-- Índice único en numero_documento (asumiendo que es único por alumno)
CREATE UNIQUE INDEX UX_Alumnos_Doc ON Alumnos (numero_documento);
	
SELECT * FROM Alumnos
-- Insercion de Alumnos (12 alumnos, uno por cada mes)
SELECT * FROM Alumnos
SELECT * FROM Aud_Log_Alumnos
INSERT INTO Alumnos (nombre_completo, email, telefono, direccion, tipo_documento, numero_documento, fecha_registro)
VALUES
('Ana Enero', 'ana.enero@example.com', '5511111111', 'Calle 1', 'INE', 'DOC001', '2025-01-10'),
('Bruno Febrero', 'bruno.febrero@example.com', '5522222222', 'Calle 2', 'Pasaporte', 'DOC002', '2025-02-12'),
('Carla Marzo', 'carla.marzo@example.com', '5533333333', 'Calle 3', 'INE', 'DOC003', '2025-03-05'),
('Daniel Abril', 'daniel.abril@example.com', '5544444444', 'Calle 4', 'INE', 'DOC004', '2025-04-08'),
('Elena Mayo', 'elena.mayo@example.com', '5555555555', 'Calle 5', 'Pasaporte', 'DOC005', '2025-05-15'),
('Fernando Junio', 'fernando.junio@example.com', '5566666666', 'Calle 6', 'INE', 'DOC006', '2025-06-20'),
('Gabriela Julio', 'gabriela.julio@example.com', '5577777777', 'Calle 7', 'INE', 'DOC007', '2025-07-25'),
('Hugo Agosto', 'hugo.agosto@example.com', '5588888888', 'Calle 8', 'Pasaporte', 'DOC008', '2025-08-18'),
('Isabel Septiembre', 'isabel.septiembre@example.com', '5599999999', 'Calle 9', 'INE', 'DOC009', '2025-09-09'),
('Jorge Octubre', 'jorge.octubre@example.com', '5510101010', 'Calle 10', 'INE', 'DOC010', '2025-10-11'),
('Karen Noviembre', 'karen.noviembre@example.com', '5512121212', 'Calle 11', 'Pasaporte', 'DOC011', '2025-11-13'),
('Luis Diciembre', 'luis.diciembre@example.com', '5513131313', 'Calle 12', 'INE', 'DOC012', '2025-12-21');

SELECT * FROM Instructores
SELECT * FROM Aud_Log_Instruc
SELECT * FROM Aud_Elim_Instruc

--RESETEA EL IDENTITY ID A PARTIR DEL NUMERO INDICADO DESPUES DE "RESEED"
--MALA PRACTICA (NO UTILZAR!)
DBCC CHECKIDENT (Instructores,Reseed,0);
DBCC CHECKIDENT (Aud_Log_Instruc,Reseed,0);
DBCC CHECKIDENT (Aud_Elim_Instruc,Reseed,0);

-- Insercion de Instructores (3 instructores)
INSERT INTO Instructores (nombre_completo, especialidad, usuario, contrasena, fecha_ingreso, estado)
VALUES
('María López', 'Piano', 'mlopez', 'clave1', '2025-01-01', 'Activo'),
('Carlos Ruiz', 'Guitarra', 'cruiz', 'clave2', '2025-02-01', 'Activo'),
('Sofía Torres', 'Canto', 'storres', 'clave3', '2025-03-01', 'Activo');

--Insercion de Cursos (3 cursos con fechas distintas)
SELECT * FROM Cursos;
SELECT * FROM Aud_Log_Cursos;
INSERT INTO Cursos (nombre_curso, nivel, duracion_semanas, costo, estado_curso, capacidad, cupo_ocupado, fecha_inicio, fecha_fin)
VALUES
('Curso Piano Básico', 'Básico', 12, 3000.00, 'Activo', 15, 0, '2025-01-15', '2025-04-15'),
('Curso Guitarra Intermedio', 'Intermedio', 10, 2500.00, 'Activo', 12, 0, '2025-05-01', '2025-07-10'),
('Curso Canto Avanzado', 'Avanzado', 8, 2000.00, 'Activo', 10, 0, '2025-09-01', '2025-10-30');

-- Insercion de Inscripciones (12 inscripciones, una por cada mes)
INSERT INTO Inscripciones (alumno_id, curso_id, instructor_id, fecha_inscripcion, metodo_pago, estado_inscripcion, total_pago)
VALUES
(1, 1, 1, '2025-01-10', 'Tarjeta', 'Activa', 3000.00),
(2, 1, 1, '2025-02-12', 'Efectivo', 'Activa', 3000.00),
(3, 1, 1, '2025-03-05', 'Transferencia', 'Activa', 3000.00),
(4, 1, 1, '2025-04-08', 'Tarjeta', 'Activa', 3000.00),
(5, 2, 2, '2025-05-15', 'Efectivo', 'Activa', 2500.00),
(6, 2, 2, '2025-06-20', 'Tarjeta', 'Activa', 2500.00),
(7, 2, 2, '2025-07-25', 'Transferencia', 'Activa', 2500.00),
(8, 2, 2, '2025-08-18', 'Tarjeta', 'Activa', 2500.00),
(9, 3, 3, '2025-09-09', 'Efectivo', 'Activa', 2000.00),
(10, 3, 3, '2025-10-11', 'Tarjeta', 'Activa', 2000.00),
(11, 3, 3, '2025-11-13', 'Transferencia', 'Activa', 2000.00),
(12, 3, 3, '2025-12-21', 'Efectivo', 'Activa', 2000.00);

SELECT * FROM Inscripciones
SELECT * FROM Aud_Log_Inscrip

