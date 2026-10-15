-- =====================================================
-- Raíz Capital  
-- =====================================================

DROP DATABASE IF EXISTS raiz_capital;
CREATE DATABASE raiz_capital CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE raiz_capital;

CREATE TABLE usuario (
  id_usuario  BIGINT AUTO_INCREMENT PRIMARY KEY,
  nombre      VARCHAR(150) NOT NULL,
  correo      VARCHAR(150) NOT NULL UNIQUE,
  contrasena  VARCHAR(255) NOT NULL,   -- hash BCrypt, nunca texto plano
  rol         ENUM('COMPRADOR','VENDEDOR','ADMINISTRADOR') NOT NULL,
  telefono    VARCHAR(20),
  creado_en   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE zona (
  id_zona      BIGINT AUTO_INCREMENT PRIMARY KEY,
  nombre_zona  VARCHAR(150) NOT NULL,
  ciudad       VARCHAR(100) NOT NULL,
  descripcion  TEXT
);

CREATE TABLE propiedad (
  id_propiedad    BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_vendedor     BIGINT NOT NULL,      -- relación Publica
  id_zona         BIGINT NOT NULL,      -- relación Pertenece
  titulo          VARCHAR(200) NOT NULL,
  descripcion     TEXT,
  precio          DECIMAL(12,2) NOT NULL,
  tipo            ENUM('DEPARTAMENTO','CASA') NOT NULL,
  operacion       ENUM('RENTA','VENTA') NOT NULL,
  recamaras       INT NOT NULL,
  banos           INT NOT NULL,
  superficie_m2   DECIMAL(8,2) NOT NULL,
  calle           VARCHAR(200),
  colonia         VARCHAR(150),
  ubicacion_maps  VARCHAR(500),
  estado          ENUM('DISPONIBLE','VENDIDA','RENTADA') NOT NULL DEFAULT 'DISPONIBLE',
  creado_en       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_propiedad_vendedor FOREIGN KEY (id_vendedor) REFERENCES usuario(id_usuario),
  CONSTRAINT fk_propiedad_zona     FOREIGN KEY (id_zona)     REFERENCES zona(id_zona)
);

-- Atributo multivalorado: características
CREATE TABLE propiedad_caracteristica (
  id_propiedad    BIGINT NOT NULL,
  caracteristica  VARCHAR(50) NOT NULL,
  PRIMARY KEY (id_propiedad, caracteristica),
  CONSTRAINT fk_caract_propiedad FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad) ON DELETE CASCADE
);

CREATE TABLE imagen (
  id_imagen     BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_propiedad  BIGINT NOT NULL,
  url           VARCHAR(500) NOT NULL,
  orden         INT NOT NULL DEFAULT 0,
  CONSTRAINT fk_imagen_propiedad FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad) ON DELETE CASCADE
);

CREATE TABLE resena (
  id_resena     BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_propiedad  BIGINT NOT NULL,
  id_usuario    BIGINT NOT NULL,
  comentario    TEXT,
  calificacion  INT NOT NULL CHECK (calificacion BETWEEN 1 AND 5),
  fecha         DATE NOT NULL,
  CONSTRAINT fk_resena_propiedad FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad) ON DELETE CASCADE,
  CONSTRAINT fk_resena_usuario   FOREIGN KEY (id_usuario)   REFERENCES usuario(id_usuario)
);

-- Recomienda (recursiva N:M)
CREATE TABLE propiedad_recomendacion (
  id_propiedad             BIGINT NOT NULL,
  id_propiedad_recomendada BIGINT NOT NULL,
  PRIMARY KEY (id_propiedad, id_propiedad_recomendada),
  CONSTRAINT fk_reco_origen  FOREIGN KEY (id_propiedad)             REFERENCES propiedad(id_propiedad) ON DELETE CASCADE,
  CONSTRAINT fk_reco_destino FOREIGN KEY (id_propiedad_recomendada) REFERENCES propiedad(id_propiedad) ON DELETE CASCADE,
  CHECK (id_propiedad <> id_propiedad_recomendada)
);

-- Solicita_Información (ternaria: comprador – propiedad – vendedor)
CREATE TABLE solicitud_informacion (
  id_solicitud     BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_comprador     BIGINT NOT NULL,
  id_propiedad     BIGINT NOT NULL,
  id_vendedor      BIGINT NOT NULL,
  fecha_solicitud  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  medio_contacto   ENUM('WHATSAPP','TELEFONO','CORREO') NOT NULL,
  CONSTRAINT fk_sol_comprador FOREIGN KEY (id_comprador) REFERENCES usuario(id_usuario),
  CONSTRAINT fk_sol_propiedad FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad),
  CONSTRAINT fk_sol_vendedor  FOREIGN KEY (id_vendedor)  REFERENCES usuario(id_usuario)
);
