-- Creación de la base de datos ---
CREATE DATABASE ConsultorioMedico;
USE ConsultorioMedico;

-- Tabla: Especialidades ---
CREATE TABLE Especialidades (
    id_especialidad INT AUTO_INCREMENT PRIMARY KEY,
    nombre_especialidad VARCHAR(50) NOT NULL UNIQUE COMMENT 'Nombre único de la especialidad médica'
);

-- Tabla: Pacientes ---

CREATE TABLE Pacientes (
    id_paciente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    dni CHAR(8) UNIQUE NOT NULL COMMENT 'Documento Nacional de Identidad',
    email VARCHAR(100),
    telefono VARCHAR(15),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Fecha de alta del paciente'
);

-- Tabla: Consultorios ---
CREATE TABLE Consultorios (
    id_consultorio INT AUTO_INCREMENT PRIMARY KEY,
    nombre_consultorio VARCHAR(50) NOT NULL,
    piso INT CHECK (piso >= 0) COMMENT 'Número de piso donde se ubica'
);

-- Tabla: Medicos ---
CREATE TABLE Medicos (
    id_medico INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    matricula VARCHAR(20) UNIQUE NOT NULL COMMENT 'Número de matrícula profesional',
    id_especialidad INT NOT NULL,
    FOREIGN KEY (id_especialidad) REFERENCES Especialidades(id_especialidad)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Tabla: Turnos ---
CREATE TABLE Turnos (
    id_turno INT AUTO_INCREMENT PRIMARY KEY,
    fecha_turno DATE NOT NULL,
    hora_turno TIME NOT NULL,
    id_paciente INT NOT NULL,
    id_medico INT NOT NULL,
    id_consultorio INT NOT NULL,
    estado ENUM('Pendiente', 'Confirmado', 'Cancelado') DEFAULT 'Pendiente',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_paciente) REFERENCES Pacientes(id_paciente)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (id_medico) REFERENCES Medicos(id_medico)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (id_consultorio) REFERENCES Consultorios(id_consultorio)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Inserto datos de ejemplo ---

INSERT INTO Especialidades (nombre_especialidad)
VALUES 
('Cardiología'),
('Pediatría'),
('Dermatología');

INSERT INTO Pacientes (nombre, apellido, dni, email, telefono)
VALUES 
('Juan', 'Pérez', '30111222', 'juan@gmail.com', '1122334455'),
('Ana', 'López', '29222111', 'ana@gmail.com', '1198765432');

INSERT INTO Consultorios (nombre_consultorio, piso)
VALUES 
('Consultorio 1', 1),
('Consultorio 2', 2);

INSERT INTO Medicos (nombre, apellido, matricula, id_especialidad)
VALUES 
('Carlos', 'Gómez', 'MAT001', 1),
('Lucía', 'Martínez', 'MAT002', 2);

INSERT INTO Turnos (fecha_turno, hora_turno, id_paciente, id_medico, id_consultorio, estado)
VALUES 
('2025-08-20', '10:00:00', 1, 1, 1, 'Confirmado'),
('2025-08-21', '11:00:00', 2, 2, 2, 'Pendiente');

-- Turnos confirmados ---
SELECT t.id_turno, t.fecha_turno, t.hora_turno,
p.nombre AS paciente, p.apellido,
m.nombre AS medico, m.apellido,
e.nombre_especialidad,
c.nombre_consultorio, t.estado
FROM Turnos t
JOIN Pacientes p ON t.id_paciente = p.id_paciente
JOIN Medicos m ON t.id_medico = m.id_medico
JOIN Especialidades e ON m.id_especialidad = e.id_especialidad
JOIN Consultorios c ON t.id_consultorio = c.id_consultorio
WHERE t.estado = 'Confirmado';

--  Cantidad de turnos por especialidad ---
SELECT e.nombre_especialidad, COUNT(*) AS cantidad_turnos
FROM Turnos t
JOIN Medicos m ON t.id_medico = m.id_medico
JOIN Especialidades e ON m.id_especialidad = e.id_especialidad
GROUP BY e.nombre_especialidad;

--  Pacientes con más de un turno asignado
SELECT p.nombre, p.apellido, COUNT(*) AS total_turnos
FROM Turnos t
JOIN Pacientes p ON t.id_paciente = p.id_paciente
GROUP BY p.id_paciente
HAVING COUNT(*) > 1;