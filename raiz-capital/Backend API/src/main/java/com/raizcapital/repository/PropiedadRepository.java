package com.raizcapital.repository;

import com.raizcapital.model.Propiedad;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PropiedadRepository extends JpaRepository<Propiedad, Long> {
    // Spring Data genera automáticamente los métodos CRUD básicos.
    // Aquí se pueden ir agregando consultas como:
    // List<Propiedad> findByZonaIdAndOperacion(Long idZona, Propiedad.Operacion operacion);
}
