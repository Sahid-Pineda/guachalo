# Guáchalo 🛍️

**Guáchalo** es una aplicación web de catálogo digital diseñada para emprendedores y microempresas que necesitan presentar y gestionar su inventario de forma profesional.

## 🎯 Problema que resuelve
Gestionar ventas a través de publicaciones dispersas o canales informales suele generar desorden, pérdida de tiempo y fricción para los compradores. **Guáchalo** centraliza la oferta comercial en una vitrina estructurada que garantiza:

* **Categorización clara:** Organización intuitiva para explorar los productos sin depender de historiales desordenados.
* **Disponibilidad real:** Control de existencias (*stock*) actualizado por artículo.
* **Precios transparentes:** Información directa y sin ambigüedades en cada ficha de producto.
* **Búsqueda y filtrado:** Localización rápida de artículos por nombre, categoría o disponibilidad.

## 🏗️ Arquitectura
El sistema está diseñado de forma **desacoplada** para separar la interfaz de usuario de la lógica de negocio y la persistencia de datos:
* **Frontend:** Interfaz web ligera para la visualización y filtrado del catálogo.
* **Backend:** API REST encargada de la gestión de inventario, categorías y reglas de negocio.
* **Base de datos:** Modelo relacional con validación de integridad para productos, precios y existencias.
