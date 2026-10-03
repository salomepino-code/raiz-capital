package com.raizcapital.controller;

import com.raizcapital.dto.LoginRequest;
import com.raizcapital.model.Usuario;
import com.raizcapital.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/usuarios")
@CrossOrigin(origins = "*")
public class UsuarioController {

    @Autowired
    private UsuarioRepository usuarioRepository;

    // POST /api/usuarios/login
    // NOTA: compara la contraseña en texto plano por ahora (sin hash/BCrypt).
    // Funciona para la entrega escolar, pero NO es seguro para producción real.
    @PostMapping("/login")
    public ResponseEntity<Usuario> login(@RequestBody LoginRequest datos) {
        return usuarioRepository
                .findByCorreoAndContrasena(datos.getCorreo(), datos.getContrasena())
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.status(401).build());
    }
}
