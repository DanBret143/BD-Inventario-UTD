CREATE TABLE IF NOT EXISTS roles (
  id_rol SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL UNIQUE,
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS departamentos (
  id_departamento SERIAL PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL,
  codigo VARCHAR(50),
  responsable_email VARCHAR(255),
  ubicacion VARCHAR(255),
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS usuarios (
  id_usuario SERIAL PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL,
  correo VARCHAR(255) NOT NULL UNIQUE,
  password_hash TEXT,
  id_rol INTEGER REFERENCES roles(id_rol) ON DELETE SET NULL,
  cargo VARCHAR(150),
  departamento_id INTEGER REFERENCES departamentos(id_departamento) ON DELETE SET NULL,
  activo INTEGER DEFAULT 1,
  invitacion_token TEXT,
  invitacion_expira TIMESTAMP,
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS bienes_muebles (
  id_bien SERIAL PRIMARY KEY,
  numero_inventario VARCHAR(100),
  descripcion TEXT,
  categoria VARCHAR(100),
  serie VARCHAR(150),
  marca VARCHAR(100),
  modelo VARCHAR(100),
  valor NUMERIC(12,2),
  estado VARCHAR(50) DEFAULT 'ACTIVO',
  fecha_adquisicion DATE,
  fecha_reparacion DATE,
  fecha_baja DATE,
  id_departamento INTEGER REFERENCES departamentos(id_departamento) ON DELETE SET NULL,
  ubicacion_especifica VARCHAR(255),
  responsable_email VARCHAR(255),
  responsable_nombre VARCHAR(150),
  observaciones TEXT,
  foto_url TEXT,
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS movimientos_bienes (
  id_movimiento SERIAL PRIMARY KEY,
  id_bien INTEGER REFERENCES bienes_muebles(id_bien) ON DELETE CASCADE,
  tipo VARCHAR(50) NOT NULL,
  motivo TEXT,
  archivo VARCHAR(255),
  id_usuario INTEGER REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
  fecha_movimiento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  departamento_origen_id INTEGER REFERENCES departamentos(id_departamento) ON DELETE SET NULL,
  departamento_destino_id INTEGER REFERENCES departamentos(id_departamento) ON DELETE SET NULL,
  responsable_nuevo_email VARCHAR(255),
  responsable_nuevo_nombre VARCHAR(150)
);

CREATE TABLE IF NOT EXISTS bitacora (
  id_bitacora SERIAL PRIMARY KEY,
  id_usuario INTEGER REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
  accion VARCHAR(100) NOT NULL,
  tabla_afectada VARCHAR(100) NOT NULL,
  id_registro INTEGER,
  created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO roles (id_rol, nombre)
VALUES (1, 'ADMINISTRADOR'), (2, 'INVENTARIOS'), (3, 'CONSULTA')
ON CONFLICT (id_rol) DO NOTHING;

INSERT INTO roles (nombre)
SELECT 'ADMINISTRADOR'
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE nombre = 'ADMINISTRADOR');

INSERT INTO roles (nombre)
SELECT 'INVENTARIOS'
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE nombre = 'INVENTARIOS');

INSERT INTO roles (nombre)
SELECT 'CONSULTA'
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE nombre = 'CONSULTA');

-- Usuario administrador por defecto para la primera ejecución del contenedor
INSERT INTO usuarios (nombre, correo, password_hash, id_rol, activo, cargo)
SELECT 'Administrador', 'admin@utd.com', '$2a$10$J0lM/e2x7Q3g4mK0Vqz1qO1KfY9l0S8s2QG1o2v4Jq6mR8t9dM6u', 1, 1, 'Administrador'
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE correo = 'admin@utd.com');
