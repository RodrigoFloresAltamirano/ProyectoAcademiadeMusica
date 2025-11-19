use Academia_Musica
-- REQUISITOS TÉCNICOS

--1. TRIGGERS
---	Validación de disponibilidad de cupos antes de registrar una inscripción.
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

---	Registro de auditorías automáticas al modificar, cancelar o eliminar inscripciones 
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


---	Actualización automática del estado del curso (Activo, Finalizado, Cancelado).
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


---	Generación de alertas por baja demanda de cursos o exceso de cupos vacíos.
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

-- 7. Índices y Sequence (10%)

-- índice único en email de Alumnos
CREATE UNIQUE INDEX IX_Alumnos_Email ON Alumnos (email);

-- Índices en estado_curso, fecha_inscripcion y nombre_curso
CREATE NONCLUSTERED INDEX IX_Cursos_Estado ON Cursos (estado_curso);
CREATE NONCLUSTERED INDEX IX_Inscripciones_Fecha ON Inscripciones (fecha_inscripcion);
CREATE NONCLUSTERED INDEX IX_Cursos_Nombre ON Cursos (nombre_curso);

-- Índice compuesto en (curso_id, fecha_inicio) para reportes por periodo
CREATE INDEX IX_Cursos_Periodo ON Cursos (curso_id, fecha_inicio);

-- Índice único en numero_documento (asumiendo que es único por alumno)
CREATE UNIQUE INDEX UX_Alumnos_Doc ON Alumnos (numero_documento);

--8. Errores
CREATE TABLE Errores(
	error_id INT PRIMARY KEY IDENTITY(1,1),
	fecha_error DATETIME DEFAULT GETDATE(),
	usuario_error VARCHAR(50),
	procedimiento_error VARCHAR(50),
	mensaje_error VARCHAR(MAX)
);