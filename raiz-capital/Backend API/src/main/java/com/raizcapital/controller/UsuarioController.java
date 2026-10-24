package com.raizcapital.controller;

import com.raizcapital.dto.LoginRequest;
import com.raizcapital.dto.RegistroRequest;
import com.raizcapital.dto.VendedorRequest;
import com.raizcapital.model.Usuario;
import com.raizcapital.repository.UsuarioRepository;
import com.raizcapital.repository.PropiedadRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.Comparator;
import java.util.List;

@RestController
@RequestMapping("/api/usuarios")
@CrossOrigin(origins = "*")
public class UsuarioController {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private PropiedadRepository propiedadRepository;

    public record VendedorResumen(
        Long id,
        String nombre,
        String correo,
        String telefono,
        long numeroPropiedades
    ) {}

    private boolean esAdministrador(Long id) {
        return id != null
            && usuarioRepository.findById(id)
                .map(u -> u.getRol() == Usuario.Rol.ADMINISTRADOR)
                .orElse(false);
    }

    @PostMapping("/login")
    public ResponseEntity<Usuario> login(@RequestBody LoginRequest datos) {
        return usuarioRepository
            .findByCorreoAndContrasena(
                datos.getCorreo(),
                datos.getContrasena()
            )
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.status(401).build());
    }

    @PostMapping("/registro")
    public ResponseEntity<?> registrar(@RequestBody RegistroRequest datos) {
        if (usuarioRepository.existsByCorreo(datos.getCorreo())) {
            return ResponseEntity.status(409)
                .body("El correo ya está registrado");
        }

        Usuario usuario = new Usuario();
        usuario.setNombre(datos.getNombre());
        usuario.setCorreo(datos.getCorreo());
        usuario.setContrasena(datos.getContrasena());
        usuario.setRol(Usuario.Rol.COMPRADOR);

        return ResponseEntity.ok(usuarioRepository.save(usuario));
    }

    @GetMapping("/vendedores")
    public ResponseEntity<?> listarVendedores(
        @RequestHeader("X-Usuario-Id") Long idAdmin
    ) {
        if (!esAdministrador(idAdmin)) {
            return ResponseEntity.status(403)
                .body("Acceso exclusivo para administradores");
        }

        List<VendedorResumen> vendedores =
            usuarioRepository.findAll().stream()
                .filter(u -> u.getRol() == Usuario.Rol.VENDEDOR)
                .sorted(Comparator.comparing(Usuario::getNombre))
                .map(u -> new VendedorResumen(
                    u.getId(),
                    u.getNombre(),
                    u.getCorreo(),
                    u.getTelefono(),
                    propiedadRepository.countByVendedor_Id(u.getId())
                ))
                .toList();

        return ResponseEntity.ok(vendedores);
    }

    @PostMapping("/vendedores")
    public ResponseEntity<?> crearVendedor(
        @RequestHeader("X-Usuario-Id") Long idAdmin,
        @RequestBody VendedorRequest datos
    ) {
        if (!esAdministrador(idAdmin)) {
            return ResponseEntity.status(403)
                .body("Acceso exclusivo para administradores");
        }

        if (datos.getNombre() == null || datos.getNombre().isBlank()
            || datos.getCorreo() == null || datos.getCorreo().isBlank()
            || datos.getContrasena() == null || datos.getContrasena().isBlank()
            || datos.getTelefono() == null
            || !datos.getTelefono().matches("\\d{10,}")) {
            return ResponseEntity.badRequest()
                .body("Verifica los datos y el teléfono de al menos 10 dígitos");
        }

        if (usuarioRepository.existsByCorreo(datos.getCorreo())) {
            return ResponseEntity.status(409)
                .body("El correo ya está registrado");
        }

        Usuario vendedor = new Usuario();
        vendedor.setNombre(datos.getNombre().trim());
        vendedor.setCorreo(datos.getCorreo().trim());
        vendedor.setContrasena(datos.getContrasena());
        vendedor.setTelefono(datos.getTelefono());
        vendedor.setRol(Usuario.Rol.VENDEDOR);

        return ResponseEntity.ok(usuarioRepository.save(vendedor));
    }

    @DeleteMapping("/vendedores/{id}")
    @Transactional
    public ResponseEntity<?> eliminarVendedor(
        @RequestHeader("X-Usuario-Id") Long idAdmin,
        @PathVariable Long id,
        @RequestParam(required = false) Long reasignarA
    ) {
        if (!esAdministrador(idAdmin)) {
            return ResponseEntity.status(403)
                .body("Acceso exclusivo para administradores");
        }

        Usuario vendedor = usuarioRepository.findById(id).orElse(null);

        if (vendedor == null || vendedor.getRol() != Usuario.Rol.VENDEDOR) {
            return ResponseEntity.badRequest()
                .body("El vendedor no existe");
        }

        long cantidad = propiedadRepository.countByVendedor_Id(id);

        if (cantidad > 0 && reasignarA == null) {
            return ResponseEntity.badRequest()
                .body("Debes elegir quién recibirá sus propiedades");
        }

        if (cantidad > 0) {
            Usuario destino = usuarioRepository.findById(reasignarA)
                .orElse(null);

            if (destino == null
                || destino.getId().equals(id)
                || (destino.getRol() != Usuario.Rol.VENDEDOR
                    && destino.getRol() != Usuario.Rol.ADMINISTRADOR)) {
                return ResponseEntity.badRequest()
                    .body("El destinatario no es válido");
            }

            propiedadRepository.reasignarVendedor(id, destino);
        }

        usuarioRepository.delete(vendedor);
        return ResponseEntity.noContent().build();
    }
}