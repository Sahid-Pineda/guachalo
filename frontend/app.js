// Única línea que cambiará cuando migremos el backend de Python a C#
const API_BASE_URL = "http://localhost:8000/api";

const gridProductos = document.getElementById("grid-productos");
const contadorResultados = document.getElementById("contador-resultados");
const btnFiltrar = document.getElementById("btn-filtrar");

async function cargarProductos() {
    // 1. Leemos los valores actuales de los filtros
    const buscar = document.getElementById("input-buscar").value.trim();
    const categoriaId = document.getElementById("select-categoria").value;
    const precioMax = document.getElementById("input-precio").value;
    const soloDisponibles = document.getElementById("check-disponibles").checked;

    // 2. Construimos los parámetros de la URL (Query Params)
    const params = new URLSearchParams();
    if (buscar) params.append("buscar", buscar);
    if (categoriaId) params.append("categoria_id", categoriaId);
    if (precioMax) params.append("precio_max", precioMax);
    params.append("solo_disponibles", soloDisponibles);

    try {
        contadorResultados.textContent = "Consultando API...";
        
        // 3. Llamamos a tu API de Python
        const respuesta = await fetch(`${API_BASE_URL}/productos?${params.toString()}`);
        if (!respuesta.ok) throw new Error("Error al consultar la API");
        
        const data = await respuesta.json();
        renderizarTarjetas(data.productos, data.total);
    } catch (error) {
        console.error(error);
        contadorResultados.textContent = "Error: No se pudo conectar con el servidor backend.";
    }
}

function renderizarTarjetas(productos, total) {
    contadorResultados.textContent = `Mostrando ${total} producto(s)`;
    gridProductos.innerHTML = "";

    if (productos.length === 0) {
        gridProductos.innerHTML = "<p>No se encontraron artículos con esos filtros.</p>";
        return;
    }

    productos.forEach((prod) => {
        const hayStock = prod.disponible && prod.stock_actual > 0;
        const mensajeWA = encodeURIComponent(`Hola ${prod.tienda}, me interesa: ${prod.producto} (L. ${prod.precio})`);
        const urlWhatsapp = `https://wa.me/${prod.whatsapp}?text=${mensajeWA}`;

        const card = document.createElement("article");
        card.className = "card";
        card.innerHTML = `
            <img src="${prod.imagen_url || 'https://placehold.co/400x400?text=Sin+Foto'}" alt="${prod.producto}">
            <div class="card-body">
                <span class="badge-categoria">${prod.categoria} • ${prod.tienda}</span>
                <h2 class="card-titulo">${prod.producto}</h2>
                <p class="card-desc">${prod.descripcion || "Sin descripción adicional."}</p>
                <p class="card-precio">L. ${Number(prod.precio).toFixed(2)}</p>
                <p class="${hayStock ? "stock-ok" : "stock-agotado"}">
                    ${hayStock ? `En stock: ${prod.stock_actual} disponibles` : "Agotado"}
                </p>
                <div class="card-acciones">
                    <a href="${urlWhatsapp}" target="_blank" class="btn-whatsapp">Pedir por WhatsApp</a>
                    <button class="btn-vender" onclick="simularVenta(${prod.producto_id})" ${!hayStock ? "disabled" : ""}>
                        -1 Stock
                    </button>
                </div>
            </div>
        `;
        gridProductos.appendChild(card);
    });
}

// Ejecuta tu procedimiento almacenado de SQL Server desde un botón en la web
async function simularVenta(productoId) {
    try {
        const respuesta = await fetch(`${API_BASE_URL}/productos/${productoId}/vender`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ cantidad_vendida: 1 })
        });

        if (!respuesta.ok) {
            const err = await respuesta.json();
            alert(err.detail || "No se pudo descontar stock");
            return;
        }

        // Recargamos la lista para ver el stock actualizado en tiempo real
        cargarProductos();
    } catch (error) {
        alert("Error de red al registrar la venta.");
    }
}

// Eventos
btnFiltrar.addEventListener("click", cargarProductos);
document.getElementById("check-disponibles").addEventListener("change", cargarProductos);
document.getElementById("select-categoria").addEventListener("change", cargarProductos);

// Carga inicial al abrir la página
cargarProductos();