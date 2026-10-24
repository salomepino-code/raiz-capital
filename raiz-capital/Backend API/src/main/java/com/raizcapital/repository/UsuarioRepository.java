
package com.raizcapital.repository;

import com.raizcapital.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    Optional<Usuario> findByCorreoAndContrasena(
            String correo, String contrasena);

    boolean existsByCorreo(String correo);

    List<Usuario> findByRol(Usuario.Rol rol);
}
