from fastapi import FastAPI, Depends, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from typing import Optional
import pyodbc

from database import get_db_connection
from schemas import ProductoCreate, VentaStockRequest

app = FastAPI(title="API Guáchalo", version="1.0.0")

# Permite que el futuro Frontend en otro puerto pueda consultar esta API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/api/productos")
def listar_productos(
    slug_tienda: Optional[str] = Query(None, description="Filtrar por URL de tienda"),
    categoria_id: Optional[int] = Query(None, description="Filtrar por ID de categoría"),
    solo_disponibles: bool = Query(False, description="Ocultar artículos agotados"),
    precio_max: Optional[float] = Query(None, description="Precio máximo"),
    buscar: Optional[str] = Query(None, description="Buscar por nombre"),
    conn: pyodbc.Connection = Depends(get_db_connection),
):
    query = "SELECT * FROM vw_catalogo_publico WHERE 1=1"
    params = []

    if slug_tienda:
        query += " AND slug_url = ?"
        params.append(slug_tienda)
    if categoria_id:
        query += " AND categoria_id = ?"
        params.append(categoria_id)
    if solo_disponibles:
        query += " AND disponible = 1 AND stock_actual > 0"
    if precio_max is not None:
        query += " AND precio <= ?"
        params.append(precio_max)
    if buscar:
        query += " AND producto LIKE ?"
        params.append(f"%{buscar}%")

    cursor = conn.cursor()
    cursor.execute(query, params)

    columnas = [col[0] for col in cursor.description]
    resultados = [dict(zip(columnas, fila)) for fila in cursor.fetchall()]

    return {"total": len(resultados), "productos": resultados}


@app.post("/api/productos", status_code=201)
def crear_producto(
    producto: ProductoCreate,
    conn: pyodbc.Connection = Depends(get_db_connection),
):
    cursor = conn.cursor()
    try:
        query = """
            INSERT INTO productos (emprendimiento_id, categoria_id, nombre, descripcion, precio, stock_actual, disponible, imagen_url)
            OUTPUT INSERTED.id
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """
        disponible = 1 if producto.stock_actual > 0 else 0
        cursor.execute(
            query,
            (
                producto.emprendimiento_id,
                producto.categoria_id,
                producto.nombre,
                producto.descripcion,
                producto.precio,
                producto.stock_actual,
                disponible,
                producto.imagen_url,
            ),
        )
        nuevo_id = cursor.fetchone()[0]
        conn.commit()
        return {"mensaje": "Producto creado correctamente", "id": nuevo_id}
    except pyodbc.IntegrityError:
        conn.rollback()
        raise HTTPException(status_code=400, detail="La tienda o categoría indicada no existe.")


@app.post("/api/productos/{producto_id}/vender")
def registrar_venta(
    producto_id: int,
    venta: VentaStockRequest,
    conn: pyodbc.Connection = Depends(get_db_connection),
):
    cursor = conn.cursor()
    try:
        cursor.execute(
            "EXEC sp_registrar_venta_stock @producto_id = ?, @cantidad_vendida = ?",
            (producto_id, venta.cantidad_vendida),
        )
        conn.commit()
        return {"mensaje": "Stock actualizado tras la venta"}
    except pyodbc.Error as e:
        conn.rollback()
        raise HTTPException(status_code=400, detail=str(e))