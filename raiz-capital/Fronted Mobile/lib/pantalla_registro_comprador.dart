import 'package:flutter/material.dart';
import 'logo_raiz_capital.dart';
import 'servicio_usuarios.dart';
import 'sesion_usuario.dart';
import 'tema_app.dart';

class PantallaRegistroComprador extends StatefulWidget {
  const PantallaRegistroComprador({super.key});

  @override
  State<PantallaRegistroComprador> createState() =>
      _EstadoPantallaRegistroComprador();
}

class _EstadoPantallaRegistroComprador
    extends State<PantallaRegistroComprador> {
  final _llaveFormulario = GlobalKey<FormState>();

  final _controladorNombre = TextEditingController();
  final _controladorCorreo = TextEditingController();
  final _controladorContrasena = TextEditingController();
  final _controladorConfirmarContrasena = TextEditingController();

  final _servicioUsuarios = ServicioUsuarios();

  bool _ocultarContrasena = true;
  bool _ocultarConfirmarContrasena = true;
  bool _cargando = false;
  String? _errorRegistro;

  @override
  void dispose() {
    _controladorNombre.dispose();
    _controladorCorreo.dispose();
    _controladorContrasena.dispose();
    _controladorConfirmarContrasena.dispose();
    super.dispose();
  }

  String? _validarNombre(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresa tu nombre';
    }
    return null;
  }

  String? _validarCorreo(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresa tu correo electrónico';
    }

    final patronCorreo = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!patronCorreo.hasMatch(valor.trim())) {
      return 'Ingresa un correo válido';
    }

    return null;
  }

  String? _validarContrasena(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Ingresa tu contraseña';
    }

    if (valor.length < 8) {
      return 'Debe tener al menos 8 caracteres';
    }

    return null;
  }

  String? _validarConfirmarContrasena(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Confirma tu contraseña';
    }

    if (valor != _controladorContrasena.text) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  Future<void> _manejarRegistro() async {
    setState(() => _errorRegistro = null);

    if (!_llaveFormulario.currentState!.validate()) {
      return;
    }

    setState(() => _cargando = true);

    try {
      final usuario = await _servicioUsuarios.registrarComprador(
        _controladorNombre.text.trim(),
        _controladorCorreo.text.trim(),
        _controladorContrasena.text,
      );

      if (!mounted) return;

      SesionUsuario.actual = usuario;

      setState(() => _cargando = false);

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;

        if (e.toString().contains('CORREO_DUPLICADO')) {
          _errorRegistro = 'Este correo ya está registrado.';
        } else {
          _errorRegistro =
              'No pudimos crear tu cuenta. Intenta de nuevo.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final temaDeTexto = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 24,
          ),
          child: Form(
            key: _llaveFormulario,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),

                const LogoRaizCapital(altura: 64),

                const SizedBox(height: 20),

                Text(
                  'Crear cuenta',
                  style: temaDeTexto.displayLarge,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 6),

                Text(
                  'Regístrate para guardar tus favoritos',
                  style: temaDeTexto.bodyMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                Text(
                  'Nombre',
                  style: temaDeTexto.bodyMedium,
                ),

                const SizedBox(height: 6),

                TextFormField(
                  controller: _controladorNombre,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Tu nombre',
                  ),
                  validator: _validarNombre,
                ),

                const SizedBox(height: 20),

                Text(
                  'Correo electrónico',
                  style: temaDeTexto.bodyMedium,
                ),

                const SizedBox(height: 6),

                TextFormField(
                  controller: _controladorCorreo,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    hintText: 'tucorreo@ejemplo.com',
                  ),
                  validator: _validarCorreo,
                ),

                const SizedBox(height: 20),

                Text(
                  'Contraseña',
                  style: temaDeTexto.bodyMedium,
                ),

                const SizedBox(height: 6),

                TextFormField(
                  controller: _controladorContrasena,
                  obscureText: _ocultarContrasena,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.password],
                  decoration: InputDecoration(
                    hintText: 'Mínimo 8 caracteres',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _ocultarContrasena
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: ColoresApp.textoApagado,
                      ),
                      onPressed: () {
                        setState(() {
                          _ocultarContrasena = !_ocultarContrasena;
                        });
                      },
                    ),
                  ),
                  validator: _validarContrasena,
                ),

                const SizedBox(height: 20),

                Text(
                  'Confirmar contraseña',
                  style: temaDeTexto.bodyMedium,
                ),

                const SizedBox(height: 6),

                TextFormField(
                  controller: _controladorConfirmarContrasena,
                  obscureText: _ocultarConfirmarContrasena,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _manejarRegistro(),
                  decoration: InputDecoration(
                    hintText: 'Repite tu contraseña',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _ocultarConfirmarContrasena
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: ColoresApp.textoApagado,
                      ),
                      onPressed: () {
                        setState(() {
                          _ocultarConfirmarContrasena =
                              !_ocultarConfirmarContrasena;
                        });
                      },
                    ),
                  ),
                  validator: _validarConfirmarContrasena,
                ),

                if (_errorRegistro != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorRegistro!,
                    style: temaDeTexto.bodyMedium?.copyWith(
                      color: ColoresApp.error,
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _cargando ? null : _manejarRegistro,
                  child: _cargando
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Crear cuenta'),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: _cargando
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Ya tengo una cuenta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}