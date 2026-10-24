package com.raizcapital.repository;

import com.raizcapital.model.Propiedad;
import com.raizcapital.model.Usuario;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.util.List;

public interface PropiedadRepository
        extends JpaRepository<Propiedad, Long> {

    @Query("SELECT p FROM Propiedad p WHERE " +
           "(:tipo IS NULL OR p.tipo = :tipo) AND " +
           "(:operacion IS NULL OR p.operacion = :operacion) AND " +
           "(:zona IS NULL OR LOWER(p.zona.nombreZona) " +
           "LIKE LOWER(CONCAT('%', :zona, '%'))) AND " +
           "(:precioMax IS NULL OR p.precio <= :precioMax)")
    List<Propiedad> buscarConFiltros(
            @Param("tipo") Propiedad.Tipo tipo,
            @Param("operacion") Propiedad.Operacion operacion,
            @Param("zona") String zona,
            @Param("precioMax") BigDecimal precioMax
    );

    long countByVendedor_Id(Long idVendedor);

    @Modifying
    @Query("UPDATE Propiedad p SET p.vendedor = :destino " +
           "WHERE p.vendedor.id = :idVendedor")
    int reasignarVendedor(
            @Param("idVendedor") Long idVendedor,
            @Param("destino") Usuario destino
    );

    @Modifying
    @Query(value = "DELETE FROM propiedad_recomendacion " +
           "WHERE id_propiedad_recomendada = :id",
           nativeQuery = true)
    void quitarRecomendacionesHacia(@Param("id") Long id);
}