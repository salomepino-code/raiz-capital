package com.raizcapital.controller;

import com.raizcapital.dto.PropiedadRequest;
import com.raizcapital.model.Imagen;
import com.raizcapital.model.Propiedad;
import com.raizcapital.model.Usuario;
import com.raizcapital.model.Zona;
import com.raizcapital.repository.ImagenRepository;
import com.raizcapital.repository.PropiedadRepository;
import com.raizcapital.repository.UsuarioRepository;
import com.raizcapital.repository.ZonaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.HashSet;
import java.util.List;

@RestController
@RequestMapping("/api/propiedades")
@CrossOrigin(origins = "*") // ajustar en producción al dominio real del frontend
public class PropiedadController {

    @Autowired
    private PropiedadRepository propiedadRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private ZonaRepository zonaRepository;

    @Autowired
    private ImagenRepository imagenRepository;

    // GET /api/propiedades
    // GET /api/propiedades?tipo=casa&operacion=venta&zona=playas&precioMax=2000000
    // Todos los parámetros son opcionales; si no mandas ninguno, regresa
    // el catálogo completo igual que antes.
    @GetMapping
    public List<Propiedad> listar(
            @RequestParam(required = false) String tipo,
            @RequestParam(required = false) String operacion,
            @RequestParam(required = false) String zona,
            @RequestParam(required = false) BigDecimal precioMax
    ) {
        Propiedad.Tipo tipoEnum = parsearEnum(Propiedad.Tipo.class, tipo);
        Propiedad.Operacion operacionEnum = parsearEnum(Propiedad.Operacion.class, operacion);
        String zonaFiltro = (zona != null && !zona.isBlank()) ? zona.trim() : null;

        return propiedadRepository.buscarConFiltros(tipoEnum, operacionEnum, zonaFiltro, precioMax);
    }

    // Convierte el texto que manda la app (ej. "casa", "VENTA", "Venta")
    // al enum correspondiente, sin importar mayúsculas/minúsculas.
    // Si el texto no coincide con ningún valor del enum, se ignora el filtro.
    private <T extends Enum<T>> T parsearEnum(Class<T> tipoEnum, String valor) {
        if (valor == null || valor.isBlank()) return null;
        try {
            return Enum.valueOf(tipoEnum, valor.trim().toUpperCase());
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    // GET /api/propiedades/{id} -> detalle
    @GetMapping("/{id}")
    public ResponseEntity<Propiedad> obtenerPorId(@PathVariable Long id) {
        return propiedadRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // POST /api/propiedades -> alta de propiedad (formulario "Publicar propiedad")
    // TODO: cuando haya sesión/token real en el backend, validar aquí que
    // quien llama sea efectivamente el vendedor con id = idVendedor (o un
    // administrador), en vez de confiar en el id que manda la app.
    @PostMapping
    public ResponseEntity<Propiedad> crear(@RequestBody PropiedadRequest datos) {
        Usuario vendedor = usuarioRepository.findById(datos.getIdVendedor())
                .orElse(null);
        if (vendedor == null) {
            return ResponseEntity.badRequest().build();
        }

        Zona zona = zonaRepository.findById(datos.getIdZona())
                .orElse(null);
        if (zona == null) {
            return ResponseEntity.badRequest().build();
        }

        Propiedad propiedad = new Propiedad();
        propiedad.setVendedor(vendedor);
        propiedad.setZona(zona);
        propiedad.setTitulo(datos.getTitulo());
        propiedad.setDescripcion(datos.getDescripcion());
        propiedad.setPrecio(datos.getPrecio());
        propiedad.setTipo(Propiedad.Tipo.valueOf(datos.getTipo()));
        propiedad.setOperacion(Propiedad.Operacion.valueOf(datos.getOperacion()));
        propiedad.setRecamaras(datos.getRecamaras());
        propiedad.setBanos(datos.getBanos());
        propiedad.setSuperficieM2(datos.getSuperficieM2());
        propiedad.setCalle(datos.getCalle());
        propiedad.setColonia(datos.getColonia());
        propiedad.setUbicacionMaps(datos.getUbicacionMaps());
        propiedad.setEstado(Propiedad.Estado.DISPONIBLE);
        if (datos.getCaracteristicas() != null) {
            propiedad.setCaracteristicas(new HashSet<>(datos.getCaracteristicas()));
        }

        Propiedad propiedadGuardada = propiedadRepository.save(propiedad);

        // Una fila en "imagen" por cada link (de Cloudinary u otro hosting)
        // que se haya pegado en el formulario.
        if (datos.getImagenesUrls() != null) {
            int orden = 0;
            for (String url : datos.getImagenesUrls()) {
                if (url == null || url.isBlank()) continue;
                Imagen imagen = new Imagen();
                imagen.setPropiedad(propiedadGuardada);
                imagen.setUrl(url.trim());
                imagen.setOrden(orden++);
                imagenRepository.save(imagen);
            }
        }

        return ResponseEntity.ok(propiedadGuardada);
    }
}