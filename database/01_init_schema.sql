CREATE DATABASE CatalogoDB;
GO

USE CatalogoDB;
GO

-- 1. Tiendas o emprendimientos
CREATE TABLE emprendimientos (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    slug_url VARCHAR(100) NOT NULL UNIQUE, -- Ej: "zapateria-luna" para enlaces limpios
    whatsapp VARCHAR(20) NOT NULL,
    descripcion VARCHAR(300) NULL,
    fecha_creacion DATETIME2 DEFAULT SYSDATETIME()
);

-- 2. Dueños de los emprendimientos (para la futura autenticación)
CREATE TABLE usuarios (
    id INT IDENTITY(1,1) PRIMARY KEY,
    emprendimiento_id INT NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    activo BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_usuarios_emprendimientos FOREIGN KEY (emprendimiento_id) 
        REFERENCES emprendimientos(id) ON DELETE CASCADE
);

-- 3. Categorías por tienda (elimina el desorden de publicaciones)
CREATE TABLE categorias (
    id INT IDENTITY(1,1) PRIMARY KEY,
    emprendimiento_id INT NOT NULL,
    nombre VARCHAR(60) NOT NULL,
    CONSTRAINT FK_categorias_emprendimientos FOREIGN KEY (emprendimiento_id) 
        REFERENCES emprendimientos(id) ON DELETE CASCADE,
    -- Evita que una misma tienda cree dos veces la categoría "Calzado"
    CONSTRAINT UQ_categoria_por_tienda UNIQUE (emprendimiento_id, nombre)
);

-- 4. Productos del catálogo
CREATE TABLE productos (
    id INT IDENTITY(1,1) PRIMARY KEY,
    emprendimiento_id INT NOT NULL,
    categoria_id INT NOT NULL,
    nombre VARCHAR(120) NOT NULL,
    descripcion VARCHAR(500) NULL,
    precio DECIMAL(10, 2) NOT NULL,
    stock_actual INT NOT NULL DEFAULT 0,
    disponible BIT NOT NULL DEFAULT 1,
    imagen_url VARCHAR(500) NULL,
    fecha_actualizacion DATETIME2 DEFAULT SYSDATETIME(),
    
    -- Reglas de negocio blindadas en la BD:
    CONSTRAINT CHK_precio_valido CHECK (precio >= 0),
    CONSTRAINT CHK_stock_valido CHECK (stock_actual >= 0),
    CONSTRAINT FK_productos_emprendimientos FOREIGN KEY (emprendimiento_id) 
        REFERENCES emprendimientos(id),
    CONSTRAINT FK_productos_categorias FOREIGN KEY (categoria_id) 
        REFERENCES categorias(id)
);
GO

-- VISTA: Une las 3 tablas principales para que la API consulte el catálogo sin repetir JOINs
CREATE VIEW vw_catalogo_publico AS
SELECT 
    p.id AS producto_id,
    p.nombre AS producto,
    p.descripcion,
    p.precio,
    p.stock_actual,
    p.disponible,
    p.imagen_url,
    c.id AS categoria_id,
    c.nombre AS categoria,
    e.id AS emprendimiento_id,
    e.nombre AS tienda,
    e.slug_url,
    e.whatsapp
FROM productos p
INNER JOIN categorias c ON p.categoria_id = c.id
INNER JOIN emprendimientos e ON p.emprendimiento_id = e.id;
GO

-- PROCEDIMIENTO ALMACENADO: Descuenta stock de forma segura y marca agotado si llega a 0
CREATE PROCEDURE sp_registrar_venta_stock
    @producto_id INT,
    @cantidad_vendida INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @cantidad_vendida <= 0
    BEGIN
        THROW 50001, 'La cantidad vendida debe ser mayor a cero.', 1;
    END

    UPDATE productos
    SET 
        stock_actual = stock_actual - @cantidad_vendida,
        disponible = CASE WHEN (stock_actual - @cantidad_vendida) = 0 THEN 0 ELSE disponible END,
        fecha_actualizacion = SYSDATETIME()
    WHERE id = @producto_id AND stock_actual >= @cantidad_vendida;

    IF @@ROWCOUNT = 0
    BEGIN
        THROW 50002, 'Stock insuficiente o producto no encontrado.', 1;
    END
END;
GO

-- Datos de prueba iniciales
INSERT INTO emprendimientos (nombre, slug_url, whatsapp, descripcion)
VALUES ('UrbanStyle HN', 'urbanstyle-hn', '50499887766', 'Ropa casual y accesorios importados');

INSERT INTO categorias (emprendimiento_id, nombre)
VALUES (1, 'Camisetas'), (1, 'Tenis'), (1, 'Accesorios');

INSERT INTO productos (emprendimiento_id, categoria_id, nombre, descripcion, precio, stock_actual, disponible, imagen_url)
VALUES 
(1, 1, 'Camiseta Oversize Negra', '100% algodón, tallas M y L', 450.00, 12, 1, 'https://placehold.co/400x400?text=Camiseta'),
(1, 2, 'Tenis Blancos Clásicos', 'Suela antideslizante, talla 41', 1250.00, 3, 1, 'https://placehold.co/400x400?text=Tenis'),
(1, 3, 'Gorra Minimalista Beige', 'Ajustable, tela transpirable', 320.00, 0, 0, 'https://placehold.co/400x400?text=Gorra');
GO
