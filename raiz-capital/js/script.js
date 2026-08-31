// ============================================================
// RAÍZ CAPITAL — script.js
// Por ahora todo corre con datos de ejemplo (array "propiedades").
// Cuando el backend Java (API) esté listo, sustituye SAMPLE_PROPERTIES
// por un fetch() a tu endpoint, ej:
//   const res = await fetch('/api/propiedades');
//   const propiedades = await res.json();
// ============================================================

// --- Menú móvil ---
const navToggle = document.getElementById('navToggle');
const mainNav = document.getElementById('mainNav');

navToggle.addEventListener('click', () => {
  const isOpen = mainNav.classList.toggle('open');
  navToggle.setAttribute('aria-expanded', isOpen);
});

mainNav.querySelectorAll('a').forEach(link => {
  link.addEventListener('click', () => {
    mainNav.classList.remove('open');
    navToggle.setAttribute('aria-expanded', 'false');
  });
});

// --- Año en el footer ---
document.getElementById('year').textContent = new Date().getFullYear();

// --- Número de WhatsApp de la agencia (formato internacional, sin +) ---
const WHATSAPP_NUMBER = '663 4820588'; 
const whatsappBtn = document.getElementById('whatsappBtn');
whatsappBtn.href = `https://wa.me/${WHATSAPP_NUMBER}?text=${encodeURIComponent('Hola, vi su página web y me interesa una propiedad.')}`;

// --- Datos de ejemplo (mock) ---
const SAMPLE_PROPERTIES = [
  {
    titulo: 'Casa en privada Los Encinos',
    precio: 3450000,
    zona: 'norte',
    tipo: 'casa',
    operacion: 'venta',
    recamaras: 3,
    banos: 2,
    m2: 180
  },
  {
    titulo: 'Departamento vista al mar',
    precio: 18500,
    zona: 'playas',
    tipo: 'departamento',
    operacion: 'renta',
    recamaras: 2,
    banos: 2,
    m2: 95
  },
  {
    titulo: 'Casa remodelada Centro',
    precio: 2890000,
    zona: 'centro',
    tipo: 'casa',
    operacion: 'venta',
    recamaras: 3,
    banos: 1,
    m2: 140
  },
  {
    titulo: 'Terreno esquina Zona Norte',
    precio: 1250000,
    zona: 'norte',
    tipo: 'terreno',
    operacion: 'venta',
    recamaras: 0,
    banos: 0,
    m2: 300
  },
  {
    titulo: 'Depto. amueblado Centro',
    precio: 12000,
    zona: 'centro',
    tipo: 'departamento',
    operacion: 'renta',
    recamaras: 1,
    banos: 1,
    m2: 60
  },
  {
    titulo: 'Casa con alberca Playas',
    precio: 6200000,
    zona: 'playas',
    tipo: 'casa',
    operacion: 'venta',
    recamaras: 4,
    banos: 3,
    m2: 260
  }
];

const grid = document.getElementById('propertyGrid');
const resultsCount = document.getElementById('resultsCount');

function formatPrice(n, operacion) {
  const formatted = n.toLocaleString('es-MX', { style: 'currency', currency: 'MXN', maximumFractionDigits: 0 });
  return operacion === 'renta' ? `${formatted} / mes` : formatted;
}

function renderProperties(list) {
  grid.innerHTML = '';

  if (list.length === 0) {
    grid.innerHTML = '<p class="no-results">No encontramos propiedades con esos filtros. Prueba ajustando el precio o la zona.</p>';
    resultsCount.innerHTML = `Mostrando <strong>0</strong> propiedades`;
    return;
  }

  list.forEach(p => {
    const card = document.createElement('article');
    card.className = 'property-card';
    card.innerHTML = `
      <div class="property-media">
        <span class="property-badge">${p.operacion === 'venta' ? 'Venta' : 'Renta'}</span>
      </div>
      <div class="property-body">
        <p class="property-price">${formatPrice(p.precio, p.operacion)}</p>
        <p class="property-title">${p.titulo}</p>
        <p class="property-loc">Zona ${capitalize(p.zona)}</p>
        <div class="property-meta">
          ${p.recamaras ? `<span>${p.recamaras} rec.</span>` : ''}
          ${p.banos ? `<span>${p.banos} baños</span>` : ''}
          <span>${p.m2} m²</span>
        </div>
      </div>
    `;
    grid.appendChild(card);
  });

  resultsCount.innerHTML = `Mostrando <strong>${list.length}</strong> propiedades`;
}

function capitalize(str) {
  return str.charAt(0).toUpperCase() + str.slice(1);
}

// --- Filtros ---
const searchForm = document.getElementById('searchForm');

searchForm.addEventListener('submit', (e) => {
  e.preventDefault();

  const tipo = document.getElementById('tipo').value;
  const operacion = document.getElementById('operacion').value;
  const zona = document.getElementById('zona').value;
  const precioMax = document.getElementById('precio').value;

  const filtered = SAMPLE_PROPERTIES.filter(p => {
    if (tipo && p.tipo !== tipo) return false;
    if (operacion && p.operacion !== operacion) return false;
    if (zona && p.zona !== zona) return false;
    if (precioMax && p.precio > Number(precioMax)) return false;
    return true;
  });

  renderProperties(filtered);
  document.getElementById('venta').scrollIntoView({ behavior: 'smooth' });
});

// --- Carga inicial ---
renderProperties(SAMPLE_PROPERTIES);
