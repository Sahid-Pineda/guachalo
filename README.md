# Guáchalo 🛍️

**Guáchalo** es una plataforma de catálogo digital diseñada para emprendedores y microempresas que gestionan sus ventas a través de redes sociales como Instagram y Facebook Marketplace.

## 🎯 Problema que resuelve
Vender exclusivamente mediante publicaciones en redes sociales suele generar fricción tanto para el vendedor como para el cliente: productos desordenados, falta de claridad sobre si hay existencias, precios poco claros y búsquedas lentas. 

**Guáchalo** centraliza el inventario en una vitrina estructurada que ofrece:
* **Categorización clara** para navegar sin perderse en un feed infinito.
* **Control de disponibilidad (stock)** actualizado por producto.
* **Precios transparentes** y fichas técnicas directas.
* **Filtros de búsqueda** rápidos para encontrar artículos específicos.

## 🏗️ Arquitectura
El sistema está diseñado de forma **desacoplada** para separar la interfaz de usuario de la lógica de negocio y la persistencia de datos:
* **Frontend:** Interfaz web ligera para la visualización y filtrado del catálogo.
* **Backend:** API REST encargada de la gestión de inventario, categorías y reglas de negocio.
* **Base de datos:** Modelo relacional con validación de integridad para productos, precios y existencias.
