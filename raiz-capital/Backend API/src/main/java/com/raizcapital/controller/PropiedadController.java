package com.raizcapital.controller;

import com.raizcapital.model.Propiedad;
import com.raizcapital.repository.PropiedadRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/propiedades")
@CrossOrigin(origins = "*") // ajustar en producción al dominio real del frontend
public class PropiedadController {

    @Autowired
    private PropiedadRepository propiedadRepository;

    // GET /api/propiedades  
    // GET /api/propiedades?tipo=casa&operacion=venta&zona=playas&precioMax=2000000
    // Todos los parámetros son opcionales; si no mandas ninguno, regresa
    // el catálogo completo igual que antes.

    @GetMapping
    public List<Propiedad> listar(
        @RequestParam (required = false) String tipo,
        @RequestParam (required = false) String operacion,
        @RequestParam (required = false) String zona,
        @RequestParam (required = false) BigDecimal precioMax
    ) { 
        Propiedad.Tipo tipoEnum = parsearEnum(Propiedad.Tipo.class, tipo);
        Propiedad.Operacion operacionEnum = parsearEnum(Propiedad.Operacion.class, operacion);
        String zonaFiltro = (zona != null && !zona.isBlank()) ? zona.trim() : null;
 
        return propiedadRepository.buscarConFiltros(tipoEnum, operacionEnum, zonaFiltro, precioMax);
    }

    // Convierte el texto que manda la app (ej. "casa", "VENTA", "Venta")
    // al enum correspondiente, sin importar mayúsculas/minúsculas.
    // Si el texto no coincide con ningún valor del enum, se ignora el filtro
    
    private <T extends Enum<T>> T parsearEnum(Class<T> tipoEnum, String valor) {
        if (valor == null || valor.isBlank()) return null;
        try {
            return Enum.valueOf(tipoEnum, valor.trim().toUpperCase());
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    // GET /api/propiedades/{id} -> detalle (usado por propiedad.html?id=X)
    @GetMapping("/{id}")
    public ResponseEntity<Propiedad> obtenerPorId(@PathVariable Long id) {
        return propiedadRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // POST /api/propiedades -> alta de propiedad (solo rol vendedor, validar en un futuro filtro/JWT)
    @PostMapping
    public Propiedad crear(@RequestBody Propiedad propiedad) {
        return propiedadRepository.save(propiedad);
    }
}
