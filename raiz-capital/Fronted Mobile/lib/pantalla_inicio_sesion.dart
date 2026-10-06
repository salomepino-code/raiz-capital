import 'pantalla_registro_comprador.dart';
import 'package:flutter/material.dart';
import 'logo_raiz_capital.dart';
import 'servicio_usuarios.dart';
import 'sesion_usuario.dart';
import 'tema_app.dart';

/// Pantalla de inicio de sesión.
///
/// NOTA: la cuenta de ADMINISTRADOR se crea manualmente, fuera del autoregistro
/// El botón "Regístrate" de abajo es para el COMPRADOR, que puede crear una
/// cuenta opcional si quiere guardar reseñas o favoritos — no es
/// obligatorio para navegar el catálogo.

class PantallaInicioSesion extends StatefulWidget {
  const PantallaInicioSesion({super.key});

  @override
  State<PantallaInicioSesion> createState() => _EstadoPantallaInicioSesion();
}

class _EstadoPantallaInicioSesion extends State<PantallaInicioSesion> {
  final _llaveFormulario = GlobalKey<FormState>();
  final _controladorCorreo = TextEditingController();
  final _controladorContrasena = TextEditingController();
  final _servicioUsuarios = ServicioUsuarios();

  bool _ocultarContrasena = true;
  bool _cargando = false;
  String? _errorInicioSesion;

  @override
  void dispose() {
    _controladorCorreo.dispose();
    _controladorContrasena.dispose();
    super.dispose();
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

  Future<void> _manejarInicioSesion() async {
    setState(() => _errorInicioSesion = null);

    if (!_llaveFormulario.currentState!.validate()) {
      return;
    }

    setState(() => _cargando = true);

    try {
      final usuario = await _servicioUsuarios.iniciarSesion(
        _controladorCorreo.text.trim(),
        _controladorContrasena.text,
      );

      if (!mounted) return;
      setState(() => _cargando = false);

      if (usuario == null) {
        setState(() => _errorInicioSesion = 'Correo o contraseña incorrectos.');
        return;
      }

      SesionUsuario.actual = usuario;
      Navigator.of(context).pop(); // regresa al catálogo, que ya se refresca solo
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _errorInicioSesion = 'No pudimos conectar con el servidor. Intenta de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final temaDeTexto = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Form(
            key: _llaveFormulario,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                _Marca(temaDeTexto: temaDeTexto),
                const SizedBox(height: 40),
                Text('Correo electrónico', style: temaDeTexto.bodyMedium),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _controladorCorreo,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(hintText: 'tucorreo@ejemplo.com'),
                  validator: _validarCorreo,
                ),
                const SizedBox(height: 20),
                Text('Contraseña', style: temaDeTexto.bodyMedium),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _controladorContrasena,
                  obscureText: _ocultarContrasena,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => _manejarInicioSesion(),
                  decoration: InputDecoration(
                    hintText: 'Mínimo 8 caracteres',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _ocultarContrasena ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: ColoresApp.textoApagado,
                      ),
                      onPressed: () => setState(() => _ocultarContrasena = !_ocultarContrasena),
                    ),
                  ),
                  validator: _validarContrasena,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // aqui va la navegacion al flujo de recuperacion de contraseña (RF11)
                    },
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),
                if (_errorInicioSesion != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _errorInicioSesion!,
                    style: temaDeTexto.bodyMedium?.copyWith(color: ColoresApp.error),
                  ),
                ],
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _cargando ? null : _manejarInicioSesion,
                  child: _cargando
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Iniciar sesión'),
                ),
                const SizedBox(height: 28),
                // Registro opcional PARA EL COMPRADOR (no para administrador).
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('¿No tienes cuenta?', style: temaDeTexto.bodyMedium),
                   TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PantallaRegistroComprador(),
                          ),
                          );
                          },
                          child: const Text('Regístrate'),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Encabezado de marca: logo/wordmark en Fraunces + tagline en Inter.
class _Marca extends StatelessWidget {
  const _Marca({required this.temaDeTexto});

  final TextTheme temaDeTexto;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const LogoRaizCapital(altura: 64),
        const SizedBox(height: 20),
        Text('Raíz Capital', style: temaDeTexto.displayLarge, textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(
          'Encuentra tu próxima propiedad',
          style: temaDeTexto.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}