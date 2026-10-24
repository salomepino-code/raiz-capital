
import 'package:flutter/material.dart';

import 'modelo_vendedor.dart';
import 'servicio_usuarios.dart';
import 'sesion_usuario.dart';
import 'tema_app.dart';

class PantallaGestionarVendedores extends StatefulWidget {
  const PantallaGestionarVendedores({super.key});

  @override
  State<PantallaGestionarVendedores> createState() =>
      _PantallaGestionarVendedoresState();
}

class _PantallaGestionarVendedoresState
    extends State<PantallaGestionarVendedores> {
  List<Vendedor> _vendedores = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarVendedores();
  }

  Future<void> _cargarVendedores() async {
    final admin = SesionUsuario.actual;

    if (admin == null || !admin.esAdministrador) {
      setState(() {
        _cargando = false;
        _error = 'Solo un administrador puede gestionar vendedores.';
      });
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final lista = await ServicioUsuarios.obtenerVendedores(
        idAdmin: admin.id,
      );

      if (!mounted) return;

      setState(() {
        _vendedores = lista;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _mostrarFormularioCrear() async {
    final formularioKey = GlobalKey<FormState>();
    final nombreController = TextEditingController();
    final correoController = TextEditingController();
    final contrasenaController = TextEditingController();
    final telefonoController = TextEditingController();

    bool guardando = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (contexto, actualizarDialogo) {
            return AlertDialog(
              title: const Text('Agregar vendedor'),
              content: SingleChildScrollView(
                child: Form(
                  key: formularioKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre completo',
                        ),
                        validator: (valor) {
                          if (valor == null || valor.trim().isEmpty) {
                            return 'Ingresa el nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: correoController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                        ),
                        validator: (valor) {
                          if (valor == null ||
                              !valor.contains('@') ||
                              !valor.contains('.')) {
                            return 'Ingresa un correo válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: contrasenaController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                        ),
                        validator: (valor) {
                          if (valor == null || valor.length < 6) {
                            return 'Usa al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: telefonoController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono (WhatsApp)',
                          hintText: '10 dígitos o más',
                        ),
                        validator: (valor) {
                          final telefono =
                              (valor ?? '').replaceAll(RegExp(r'\D'), '');

                          if (telefono.length < 10) {
                            return 'Ingresa al menos 10 dígitos';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: guardando
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: guardando
                      ? null
                      : () async {
                          if (!formularioKey.currentState!.validate()) {
                            return;
                          }

                          final admin = SesionUsuario.actual;

                          if (admin == null) return;

                          actualizarDialogo(() {
                            guardando = true;
                          });

                          try {
                            final telefono = telefonoController.text
                                .replaceAll(RegExp(r'\D'), '');

                            await ServicioUsuarios.crearVendedor(
                              idAdmin: admin.id,
                              nombre: nombreController.text.trim(),
                              correo: correoController.text.trim(),
                              contrasena: contrasenaController.text,
                              telefono: telefono,
                            );

                            if (!dialogContext.mounted) return;

                            Navigator.pop(dialogContext);

                            await _cargarVendedores();

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Vendedor creado correctamente'),
                              ),
                            );
                          } catch (e) {
                            actualizarDialogo(() {
                              guardando = false;
                            });

                            ScaffoldMessenger.of(contexto).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'No se pudo crear el vendedor: $e',
                                ),
                              ),
                            );
                          }
                        },
                  child: guardando
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    nombreController.dispose();
    correoController.dispose();
    contrasenaController.dispose();
    telefonoController.dispose();
  }

  Future<void> _mostrarConfirmacionEliminar(Vendedor vendedor) async {
    int? reasignarA;

    if (vendedor.numeroPropiedades > 0) {
      final opciones = <_DestinoReasignacion>[
        _DestinoReasignacion(
          id: SesionUsuario.actual!.id,
          nombre: 'Administrador (mi cuenta)',
        ),
        ..._vendedores
            .where((v) => v.id != vendedor.id)
            .map(
              (v) => _DestinoReasignacion(
                id: v.id,
                nombre: '${v.nombre} (${v.correo})',
              ),
            ),
      ];

      if (opciones.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay un destinatario para las propiedades.'),
          ),
        );
        return;
      }

      reasignarA = opciones.first.id;

      final elegido = await showDialog<int>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (contexto, actualizarDialogo) {
              return AlertDialog(
                title: const Text('Reasignar propiedades'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${vendedor.nombre} tiene '
                      '${vendedor.numeroPropiedades} propiedades.',
                    ),
                    const SizedBox(height: 12),
                    const Text('¿Quién recibirá esas propiedades?'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: reasignarA,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Nuevo responsable',
                      ),
                      items: opciones.map((opcion) {
                        return DropdownMenuItem<int>(
                          value: opcion.id,
                          child: Text(
                            opcion.nombre,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (valor) {
                        actualizarDialogo(() {
                          reasignarA = valor;
                        });
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: reasignarA == null
                        ? null
                        : () => Navigator.pop(dialogContext, reasignarA),
                    child: const Text('Continuar'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (elegido == null) return;
      reasignarA = elegido;
    } else {
      final confirmar = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Eliminar vendedor'),
            content: Text(
              '¿Deseas eliminar a ${vendedor.nombre}? Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Eliminar'),
              ),
            ],
          );
        },
      );

      if (confirmar != true) return;
    }

    await _eliminarVendedor(
      vendedor,
      reasignarA: reasignarA,
    );
  }

  Future<void> _eliminarVendedor(
    Vendedor vendedor, {
    int? reasignarA,
  }) async {
    final admin = SesionUsuario.actual;

    if (admin == null) return;

    try {
      await ServicioUsuarios.eliminarVendedor(
        idAdmin: admin.id,
        id: vendedor.id,
        reasignarA: reasignarA,
      );

      await _cargarVendedores();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vendedor eliminado correctamente'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo eliminar el vendedor: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar vendedores'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarFormularioCrear,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Agregar vendedor'),
      ),
      body: RefreshIndicator(
        onRefresh: _cargarVendedores,
        child: _cargando
            ? ListView(
                children: const [
                  SizedBox(height: 250),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : _error != null
                ? ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: FilledButton(
                          onPressed: _cargarVendedores,
                          child: const Text('Reintentar'),
                        ),
                      ),
                    ],
                  )
                : _vendedores.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.all(24),
                        children: const [
                          SizedBox(height: 100),
                          Icon(
                            Icons.people_outline,
                            size: 56,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Todavía no hay vendedores registrados.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          16,
                          16,
                          100,
                        ),
                        itemCount: _vendedores.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, indice) {
                          final vendedor = _vendedores[indice];

                          return Card(
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person_outline),
                              ),
                              title: Text(vendedor.nombre),
                              subtitle: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(vendedor.correo),
                                  Text(
                                    'Teléfono: ${vendedor.telefono ?? 'Sin teléfono'}',
                                  ),
                                  Text(
                                    'Propiedades: ${vendedor.numeroPropiedades}',
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                              trailing: IconButton(
                                tooltip: 'Eliminar vendedor',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () =>
                                    _mostrarConfirmacionEliminar(vendedor),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}

class _DestinoReasignacion {
  const _DestinoReasignacion({
    required this.id,
    required this.nombre,
  });

  final int id;
  final String nombre;
}
