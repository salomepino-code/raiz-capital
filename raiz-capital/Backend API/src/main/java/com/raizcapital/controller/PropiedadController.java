package com.raizcapital.controller;

import com.raizcapital.model.Propiedad;
import com.raizcapital.repository.PropiedadRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/propiedades")
@CrossOrigin(origins = "*") // ajustar en producción al dominio real del frontend
public class PropiedadController {

    @Autowired
    private PropiedadRepository propiedadRepository;

    // GET /api/propiedades  -> catálogo (usado por index.html / pantalla_catalogo)
    @GetMapping
    public List<Propiedad> listar() {
        return propiedadRepository.findAll();
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
