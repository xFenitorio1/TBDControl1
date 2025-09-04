-- Creación de tabla base: Comuna
CREATE TABLE Comuna (
    id_comuna SERIAL PRIMARY KEY,
    nombre_comuna VARCHAR(100) NOT NULL
);

-- Edificio de estacionamiento
CREATE TABLE Edificio_estacionamiento (
    id_edificio SERIAL PRIMARY KEY,
    nombre_estacionamiento VARCHAR(100) NOT NULL,
    direccion VARCHAR(200),
    capacidad_total INTEGER,
    id_comuna BIGINT REFERENCES Comuna(id_comuna)
);

-- Cliente
CREATE TABLE Cliente (
    id_cliente SERIAL PRIMARY KEY,
    nombre_cliente VARCHAR(100) NOT NULL,
    rut VARCHAR(12) UNIQUE NOT NULL,
    direccion VARCHAR(200),
    telefono VARCHAR(20),
    correo VARCHAR(100),
    id_comuna BIGINT REFERENCES Comuna(id_comuna)
);

-- Modelo de vehículo
CREATE TABLE Modelo (
    id_modelo SERIAL PRIMARY KEY,
    marca VARCHAR(50),
    nombre_modelo VARCHAR(100),
    año_fabricacion INTEGER
);

-- Vehículo
CREATE TABLE Vehiculo (
    id_vehiculo SERIAL PRIMARY KEY,
    patente VARCHAR(10) UNIQUE NOT NULL,
    color VARCHAR(30),
    año INTEGER,
    id_modelo BIGINT REFERENCES Modelo(id_modelo),
    id_cliente BIGINT REFERENCES Cliente(id_cliente)
);

-- Relación Cliente-Vehículo
CREATE TABLE Cliente_vehiculo (
    id_cliveh SERIAL PRIMARY KEY,
    id_cliente BIGINT REFERENCES Cliente(id_cliente),
    id_vehiculo BIGINT REFERENCES Vehiculo(id_vehiculo)
);

-- Lugar de estacionamiento
CREATE TABLE Lugar (
    id_lugar SERIAL PRIMARY KEY,
    numero_lugar INTEGER NOT NULL,
    piso INTEGER,
    estado VARCHAR(20) CHECK (estado IN ('disponible', 'ocupado', 'mantención')),
    id_edificio BIGINT REFERENCES Edificio_estacionamiento(id_edificio)
);

-- Relación Lugar-ClienteVehículo
CREATE TABLE Lugar_cliveh (
    id_lugar BIGINT REFERENCES Lugar(id_lugar),
    id_cliveh BIGINT REFERENCES Cliente_vehiculo(id_cliveh),
    fecha_uso DATE,
    hora_inicio TIME,
    hora_fin TIME,
    PRIMARY KEY (id_lugar, id_cliveh)
);

-- Contrato
CREATE TABLE Contrato (
    id_contrato SERIAL PRIMARY KEY,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    id_cliveh BIGINT REFERENCES Cliente_vehiculo(id_cliveh),
    id_edificio BIGINT REFERENCES Edificio_estacionamiento(id_edificio)
);

-- Pago
CREATE TABLE Pago (
    id_pago SERIAL PRIMARY KEY,
    monto NUMERIC(10,2),
    fecha_pago DATE,
    metodo_pago VARCHAR(50),
    id_contrato BIGINT REFERENCES Contrato(id_contrato)
);

-- Empleado
CREATE TABLE Empleado (
    id_empleado SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    rut VARCHAR(12) UNIQUE NOT NULL,
    cargo VARCHAR(50),
    id_edificio BIGINT REFERENCES Edificio_estacionamiento(id_edificio),
    id_comuna BIGINT REFERENCES Comuna(id_comuna)
);

-- Sueldo
CREATE TABLE Sueldo (
    id_sueldo SERIAL PRIMARY KEY,
    monto NUMERIC(10,2),
    fecha_inicio DATE,
    fecha_fin DATE,
    id_empleado BIGINT REFERENCES Empleado(id_empleado)
);
