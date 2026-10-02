package com.raizcapital.repository;

import com.raizcapital.model.Propiedad;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.util.List;

public interface PropiedadRepository extends JpaRepository<Propiedad, Long> {
    // Spring Data genera automáticamente los métodos CRUD básicos.
    // Aquí se pueden ir agregando consultas como:
    // List<Propiedad> findByZonaIdAndOperacion(Long idZona, Propiedad.Operacion operacion);

    // Búsqueda con filtros opcionales para el catálogo (RF04). Cada
    // condición se ignora si el parámetro llega null, así que puedes
    // mandar cualquier combinación de filtros, o ninguno.
    @Query("SELECT p FROM Propiedad p WHERE " +
           "(:tipo IS NULL OR p.tipo = :tipo) AND " +
           "(:operacion IS NULL OR p.operacion = :operacion) AND " +
           "(:zona IS NULL OR LOWER(p.zona.nombreZona) LIKE LOWER(CONCAT('%', :zona, '%'))) AND " +
           "(:precioMax IS NULL OR p.precio <= :precioMax)")
    List<Propiedad> buscarConFiltros(
            @Param("tipo") Propiedad.Tipo tipo,
            @Param("operacion") Propiedad.Operacion operacion,
            @Param("zona") String zona,
            @Param("precioMax") BigDecimal precioMax
    );
}