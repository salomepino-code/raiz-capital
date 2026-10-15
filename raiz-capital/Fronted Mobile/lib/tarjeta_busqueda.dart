import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tema_app.dart';

// Estas tres constantes antes vivían en pantalla_catalogo.dart. Si quieres
// cambiar los tipos, las operaciones o los rangos de precio, ahora se
// editan aquí.
const List<String> _tiposDisponibles = ['Todos', 'Casa', 'Departamento', 'Terreno', 'Local'];
const List<String> _operacionesDisponibles = ['Todas', 'Venta', 'Renta'];

// Mismos rangos que RANGOS_PRECIO en script.js (la web)
const Map<String, List<Map<String, String>>> _rangosPrecio = {
  'VENTA': [
    {'value': '2000000', 'label': 'Hasta \$2,000,000'},
    {'value': '4000000', 'label': 'Hasta \$4,000,000'},
    {'value': '6000000', 'label': 'Hasta \$6,000,000'},
    {'value': '8000000', 'label': 'Hasta \$8,000,000'},
    {'value': '10000000', 'label': 'Hasta \$10,000,000'},
    {'value': '15000000', 'label': 'Hasta \$15,000,000'},
  ],
  'RENTA': [
    {'value': '10000', 'label': 'Hasta \$10,000'},
    {'value': '15000', 'label': 'Hasta \$15,000'},
    {'value': '20000', 'label': 'Hasta \$20,000'},
    {'value': '25000', 'label': 'Hasta \$25,000'},
    {'value': '30000', 'label': 'Hasta \$30,000'},
    {'value': '40000', 'label': 'Hasta \$40,000'},
    {'value': '50000', 'label': 'Hasta \$50,000'},
  ],
};

/// Tarjeta de búsqueda con filtros (RF04), igual que la de la web: tipo y
/// operación son dropdowns, zona tiene autocompletar, y el precio máximo
/// es un dropdown cuyos rangos cambian según elijas venta o renta.
///
/// No guarda estado propio: lo que está seleccionado vive en
/// pantalla_catalogo.dart y aquí solo se muestra y se avisa de los
/// cambios (por eso recibe tantos parámetros).
class TarjetaBusqueda extends StatelessWidget {
  const TarjetaBusqueda({
    super.key,
    required this.tipoSeleccionado,
    required this.operacionSeleccionada,
    required this.controladorZona,
    required this.precioMaxSeleccionado,
    required this.onTipoChanged,
    required this.onOperacionChanged,
    required this.onPrecioMaxChanged,
    required this.onBuscar,
  });

  final String tipoSeleccionado;
  final String operacionSeleccionada;
  final TextEditingController controladorZona;

  /// Guarda el 'value' del rango (ej. '2000000'), no el texto de la etiqueta.
  /// null = "Sin límite".
  final String? precioMaxSeleccionado;

  final ValueChanged<String> onTipoChanged;
  final ValueChanged<String> onOperacionChanged;
  final ValueChanged<String?> onPrecioMaxChanged;
  final VoidCallback onBuscar;

  /// Igual que actualizarRangosPrecio() en la web: el rango disponible
  /// depende de si eliges Venta o Renta. Si no eliges operación ("Todas"),
  /// solo queda "Sin límite".
  List<Map<String, String>> get _rangosActuales =>
      _rangosPrecio[operacionSeleccionada.toUpperCase()] ?? const [];

  @override
  Widget build(BuildContext context) {
    final Map<String?, String> opcionesPrecio = {
      null: 'Sin límite',
      for (final r in _rangosActuales) r['value']: r['label']!,
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColoresApp.tarjeta,
        borderRadius: BorderRadius.circular(TemaApp.radio),
        border: Border.all(color: ColoresApp.borde),
        boxShadow: [
          BoxShadow(
            color: ColoresApp.azulNoche.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _CampoFiltroDropdown(
                  etiqueta: 'TIPO',
                  valor: tipoSeleccionado,
                  opciones: {for (final t in _tiposDisponibles) t: t},
                  onChanged: (v) {
                    if (v != null) onTipoChanged(v);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CampoFiltroDropdown(
                  etiqueta: 'OPERACIÓN',
                  valor: operacionSeleccionada,
                  opciones: {for (final o in _operacionesDisponibles) o: o},
                  onChanged: (v) {
                    if (v != null) onOperacionChanged(v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // El precio lleva más ancho porque sus etiquetas
              // ("Hasta $15,000,000") son más largas que las zonas.
              Expanded(
                flex: 2,
                child: _CampoFiltroZona(controlador: controladorZona),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _CampoFiltroDropdown(
                  etiqueta: 'PRECIO MÁX.',
                  valor: precioMaxSeleccionado,
                  opciones: opcionesPrecio,
                  onChanged: onPrecioMaxChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: onBuscar,
            child: const Text('Buscar propiedades'),
          ),
        ],
      ),
    );
  }
}

/// Estilo de la etiqueta chiquita arriba de cada campo (TIPO, ZONA, ...).
TextStyle _estiloEtiqueta() => GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: ColoresApp.textoApagado,
      letterSpacing: 0.6,
    );

/// Caja con un dropdown real adentro. Las claves del mapa son el valor
/// que se guarda y los textos son lo que se muestra.
class _CampoFiltroDropdown extends StatelessWidget {
  const _CampoFiltroDropdown({
    required this.etiqueta,
    required this.valor,
    required this.opciones,
    required this.onChanged,
  });

  final String etiqueta;
  final String? valor;
  final Map<String?, String> opciones;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final temaDeTexto = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta, style: _estiloEtiqueta()),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: ColoresApp.crema,
            borderRadius: BorderRadius.circular(TemaApp.radio),
            border: Border.all(color: ColoresApp.borde),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: valor,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: ColoresApp.textoApagado,
              ),
              style: temaDeTexto.bodyMedium,
              dropdownColor: ColoresApp.tarjeta,
              items: opciones.entries
                  .map(
                    (e) => DropdownMenuItem<String?>(
                      value: e.key,
                      child: Text(e.value, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

/// Campo de Zona con autocompletar, como el de la web: al escribir aparece
/// debajo una lista de coincidencias parciales (sin importar mayúsculas),
/// con lo que escribiste resaltado; tocar una la selecciona.
///
/// Si el usuario escribe algo y no toca ninguna sugerencia, igual se usa
/// el texto tal cual como filtro.
class _CampoFiltroZona extends StatefulWidget {
  const _CampoFiltroZona({required this.controlador});

  final TextEditingController controlador;

  @override
  State<_CampoFiltroZona> createState() => _EstadoCampoFiltroZona();
}

class _EstadoCampoFiltroZona extends State<_CampoFiltroZona> {
  // Misma lista de zonas que ZONAS en js/data.js de la web.
  static const List<String> _zonas = [
    'Zona Río / Centro',
    'Zona Este',
    'Otay',
    'La Mesa',
    'Agua Caliente',
    'Playas de Tijuana',
    'Santa Fe',
    'Zona Sur',
    'Zona Oeste',
    'Zona Norte',
    'Valle de las Palmas',
    'Rosarito',
  ];

  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final temaDeTexto = Theme.of(context).textTheme;

    // LayoutBuilder para que la lista de sugerencias mida lo mismo que el
    // campo (si no, se estiraría al ancho de toda la pantalla).
    return LayoutBuilder(
      builder: (context, restricciones) {
        final double anchoCampo = restricciones.maxWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ZONA', style: _estiloEtiqueta()),
            const SizedBox(height: 6),
            RawAutocomplete<String>(
              textEditingController: widget.controlador,
              focusNode: _focusNode,
              optionsBuilder: (TextEditingValue valor) {
                final consulta = valor.text.trim().toLowerCase();
                if (consulta.isEmpty) return const Iterable<String>.empty();
                return _zonas.where((z) => z.toLowerCase().contains(consulta));
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: ColoresApp.crema,
                    borderRadius: BorderRadius.circular(TemaApp.radio),
                    border: Border.all(color: ColoresApp.borde),
                  ),
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    style: temaDeTexto.bodyMedium,
                    decoration: const InputDecoration(
                      isDense: true,
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: 'Buscar zona...',
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                );
              },
              optionsViewBuilder: (context, onSelected, opciones) {
                final lista = opciones.toList();
                final consulta = widget.controlador.text.trim();

                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    color: ColoresApp.tarjeta,
                    borderRadius: BorderRadius.circular(TemaApp.radio),
                    child: SizedBox(
                      width: anchoCampo,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 220),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(4),
                          shrinkWrap: true,
                          itemCount: lista.length,
                          itemBuilder: (context, indice) {
                            final opcion = lista[indice];
                            return InkWell(
                              onTap: () => onSelected(opcion),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 9,
                                ),
                                child: _textoConCoincidenciaResaltada(
                                  opcion,
                                  consulta,
                                  temaDeTexto,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  /// Resalta en vino y negritas la parte de [opcion] que coincide con lo
  /// que el usuario escribió, igual que el <mark> de la web.
  Widget _textoConCoincidenciaResaltada(
    String opcion,
    String consulta,
    TextTheme temaDeTexto,
  ) {
    final indice = opcion.toLowerCase().indexOf(consulta.toLowerCase());
    if (consulta.isEmpty || indice == -1) {
      return Text(opcion, style: temaDeTexto.bodyMedium);
    }

    return RichText(
      text: TextSpan(
        style: temaDeTexto.bodyMedium,
        children: [
          TextSpan(text: opcion.substring(0, indice)),
          TextSpan(
            text: opcion.substring(indice, indice + consulta.length),
            style: const TextStyle(
              color: ColoresApp.vino,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: opcion.substring(indice + consulta.length)),
        ],
      ),
    );
  }
}