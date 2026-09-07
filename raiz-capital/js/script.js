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
const WHATSAPP_NUMBER = '526634820588'; //
const whatsappBtn = document.getElementById('whatsappBtn');
whatsappBtn.href = `https://wa.me/${WHATSAPP_NUMBER}?text=${encodeURIComponent('Hola, vi su página web y me interesa una propiedad.')}`;

// --- Datos de ejemplo (mock) ---
const SAMPLE_PROPERTIES = [
  {
    titulo: 'Casa en privada Los Encinos',
    precio: 3450000,
    zona: 'Zona Este',
    tipo: 'casa',
    operacion: 'venta',
    recamaras: 3,
    banos: 2,
    m2: 180
  },
  {
    titulo: 'Departamento vista al mar',
    precio: 18500,
    zona: 'Playas de Tijuana',
    tipo: 'departamento',
    operacion: 'renta',
    recamaras: 2,
    banos: 2,
    m2: 95
  },
  {
    titulo: 'Casa remodelada Centro',
    precio: 2890000,
    zona: 'Zona Río / Centro',
    tipo: 'casa',
    operacion: 'venta',
    recamaras: 3,
    banos: 1,
    m2: 140
  },
  {
    titulo: 'Terreno esquina Zona Norte',
    precio: 1250000,
    zona: 'Zona Norte',
    tipo: 'terreno',
    operacion: 'venta',
    recamaras: 0,
    banos: 0,
    m2: 300
  },
  {
    titulo: 'Depto. amueblado Centro',
    precio: 12000,
    zona: 'Zona Río / Centro',
    tipo: 'departamento',
    operacion: 'renta',
    recamaras: 1,
    banos: 1,
    m2: 60
  },
  {
    titulo: 'Casa con alberca Playas',
    precio: 6200000,
    zona: 'Playas de Tijuana',
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
        <p class="property-loc">${p.zona}</p>
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

// --- Autocompletar de zona ---
const ZONAS = [
  'Zona Río / Centro', 'Zona Este', 'Otay', 'La Mesa', 'Agua Caliente',
  'Playas de Tijuana', 'Santa Fe', 'Zona Sur', 'Zona Oeste',
  'Zona Norte', 'Valle de las Palmas', 'Rosarito'
];

const zonaInput = document.getElementById('zona');
const zonaList = document.getElementById('zonaSuggestions');
let activeIndex = -1;

function highlightMatch(text, query) {
  const idx = text.toLowerCase().indexOf(query.toLowerCase());
  if (idx === -1) return text;
  return `${text.slice(0, idx)}<mark>${text.slice(idx, idx + query.length)}</mark>${text.slice(idx + query.length)}`;
}

function showSuggestions(query) {
  const matches = ZONAS.filter(z => z.toLowerCase().includes(query.toLowerCase()));
  activeIndex = -1;

  if (!query || matches.length === 0) {
    zonaList.classList.remove('open');
    zonaList.innerHTML = '';
    return;
  }

  zonaList.innerHTML = matches
    .map(z => `<li>${highlightMatch(z, query)}</li>`)
    .join('');
  zonaList.classList.add('open');
}

zonaInput.addEventListener('input', () => showSuggestions(zonaInput.value.trim()));

zonaInput.addEventListener('focus', () => {
  if (zonaInput.value.trim()) showSuggestions(zonaInput.value.trim());
});

zonaList.addEventListener('click', (e) => {
  const li = e.target.closest('li');
  if (!li) return;
  zonaInput.value = li.textContent;
  zonaList.classList.remove('open');
});

// Navegación con teclado (flechas + Enter)
zonaInput.addEventListener('keydown', (e) => {
  const items = [...zonaList.querySelectorAll('li')];
  if (!items.length) return;

  if (e.key === 'ArrowDown') {
    e.preventDefault();
    activeIndex = (activeIndex + 1) % items.length;
  } else if (e.key === 'ArrowUp') {
    e.preventDefault();
    activeIndex = (activeIndex - 1 + items.length) % items.length;
  } else if (e.key === 'Enter' && activeIndex >= 0) {
    e.preventDefault();
    zonaInput.value = items[activeIndex].textContent;
    zonaList.classList.remove('open');
    return;
  } else {
    return;
  }

  items.forEach(li => li.classList.remove('active'));
  items[activeIndex].classList.add('active');
});

// Cerrar dropdown al hacer click afuera
document.addEventListener('click', (e) => {
  if (!e.target.closest('.field-autocomplete')) {
    zonaList.classList.remove('open');
  }
});

// --- Rangos de precio según operación ---

const RANGOS_PRECIO = {
  venta: [
    { value: '2000000', label: 'Hasta $2,000,000' },
    { value: '4000000', label: 'Hasta $4,000,000' },
    { value: '6000000', label: 'Hasta $6,000,000' },
    { value: '8000000', label: 'Hasta $8,000,000' },
    { value: '10000000', label: 'Hasta $10,000,000' },
    { value: '15000000', label: 'Hasta $15,000,000' },
  ],
  renta: [
    { value: '10000', label: 'Hasta $10,000' },
    { value: '15000', label: 'Hasta $15,000' },
    { value: '20000', label: 'Hasta $20,000' },
    { value: '25000', label: 'Hasta $25,000' },
    { value: '30000', label: 'Hasta $30,000' },
    { value: '40000', label: 'Hasta $40,000' },
    { value: '50000', label: 'Hasta $50,000' },
  ]
};

const operacionSelect = document.getElementById('operacion');
const precioSelect = document.getElementById('precio');

function actualizarRangosPrecio() {
  const operacion = operacionSelect.value;
  const rangos = RANGOS_PRECIO[operacion] || [];

  precioSelect.innerHTML =
    '<option value="">Sin límite</option>' +
    rangos.map(r => `<option value="${r.value}">${r.label}</option>`).join('');
}

operacionSelect.addEventListener('change', actualizarRangosPrecio);
actualizarRangosPrecio(); // estado inicial al cargar la página

// --- Filtros ---
const searchForm = document.getElementById('searchForm');

searchForm.addEventListener('submit', (e) => {
  e.preventDefault();

  const tipo = document.getElementById('tipo').value;
  const operacion = document.getElementById('operacion').value;
  const zona = document.getElementById('zona').value.trim();
  const precioMax = document.getElementById('precio').value;

  const filtered = SAMPLE_PROPERTIES.filter(p => {
    if (tipo && p.tipo !== tipo) return false;
    if (operacion && p.operacion !== operacion) return false;
    if (zona && !p.zona.toLowerCase().includes(zona.toLowerCase())) return false;
    if (precioMax && p.precio > Number(precioMax)) return false;
    return true;
  });

  renderProperties(filtered);
  document.getElementById('venta').scrollIntoView({ behavior: 'smooth' });
});

// --- Carga inicial ---
renderProperties(SAMPLE_PROPERTIES);