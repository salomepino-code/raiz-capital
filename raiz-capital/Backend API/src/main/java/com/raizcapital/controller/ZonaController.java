package com.raizcapital.controller;

import com.raizcapital.model.Zona;
import com.raizcapital.repository.ZonaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/zonas")
@CrossOrigin(origins = "*")
public class ZonaController {

    @Autowired
    private ZonaRepository zonaRepository;

    // GET /api/zonas -> para llenar el dropdown de zona del formulario de publicar
    @GetMapping
    public List<Zona> listar() {
        return zonaRepository.findAll();
    }
}
