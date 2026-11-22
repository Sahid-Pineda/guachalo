from pydantic import BaseModel, Field
from typing import Optional

class ProductoCreate(BaseModel):
    emprendimiento_id: int
    categoria_id: int
    nombre: str = Field(..., min_length=2, max_length=120)
    descripcion: Optional[str] = Field(None, max_length=500)
    precio: float = Field(..., ge=0)
    stock_actual: int = Field(..., ge=0)
    imagen_url: Optional[str] = None

class VentaStockRequest(BaseModel):
    cantidad_vendida: int = Field(..., gt=0)