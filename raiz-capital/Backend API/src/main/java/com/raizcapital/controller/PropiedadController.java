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
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.ArrayList;
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
    // Si el texto no coincide con ningún valor del enum, regresa null.
    private <T extends Enum<T>> T parsearEnum(Class<T> tipoEnum, String valor) {
        if (valor == null || valor.isBlank()) return null;
        try {
            return Enum.valueOf(tipoEnum, valor.trim().toUpperCase());
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    // Por ahora el backend no tiene sesión/token: la app manda el id del
    // usuario logueado en el header X-Usuario-Id y aquí solo se comprueba
    // que ese usuario exista y sea ADMINISTRADOR. Es el mismo nivel de
    // confianza que ya tiene el POST (que confía en idVendedor); una
    // seguridad real requeriría un token (JWT) firmado por el servidor.
    private boolean esAdministrador(Long idUsuario) {
        if (idUsuario == null) return false;
        return usuarioRepository.findById(idUsuario)
                .map(u -> u.getRol() == Usuario.Rol.ADMINISTRADOR)
                .orElse(false);
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
        guardarImagenes(propiedadGuardada, datos.getImagenesUrls());

        return ResponseEntity.ok(propiedadGuardada);
    }

    // PUT /api/propiedades/{id} -> editar propiedad (SOLO administrador).
    // Reemplaza todos los datos por los que manda el formulario, incluida la
    // lista de fotos (la app manda los links que se quedan + los nuevos).
    // El vendedor solo cambia si la app manda idVendedor; si no, se queda.
    @PutMapping("/{id}")
    @Transactional
    public ResponseEntity<Void> actualizar(
            @PathVariable Long id,
            @RequestHeader(value = "X-Usuario-Id", required = false) Long idUsuario,
            @RequestBody PropiedadRequest datos
    ) {
        if (!esAdministrador(idUsuario)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        Propiedad propiedad = propiedadRepository.findById(id).orElse(null);
        if (propiedad == null) {
            return ResponseEntity.notFound().build();
        }

        if (datos.getIdZona() == null) {
            return ResponseEntity.badRequest().build();
        }
        Zona zona = zonaRepository.findById(datos.getIdZona()).orElse(null);
        if (zona == null) {
            return ResponseEntity.badRequest().build();
        }

        Propiedad.Tipo tipo = parsearEnum(Propiedad.Tipo.class, datos.getTipo());
        Propiedad.Operacion operacion = parsearEnum(Propiedad.Operacion.class, datos.getOperacion());
        if (tipo == null || operacion == null) {
            return ResponseEntity.badRequest().build();
        }

        if (datos.getIdVendedor() != null) {
            Usuario vendedor = usuarioRepository.findById(datos.getIdVendedor()).orElse(null);
            if (vendedor == null) {
                return ResponseEntity.badRequest().build();
            }
            propiedad.setVendedor(vendedor);
        }

        propiedad.setZona(zona);
        propiedad.setTitulo(datos.getTitulo());
        propiedad.setDescripcion(datos.getDescripcion());
        propiedad.setPrecio(datos.getPrecio());
        propiedad.setTipo(tipo);
        propiedad.setOperacion(operacion);
        propiedad.setRecamaras(datos.getRecamaras());
        propiedad.setBanos(datos.getBanos());
        propiedad.setSuperficieM2(datos.getSuperficieM2());
        propiedad.setCalle(datos.getCalle());
        propiedad.setColonia(datos.getColonia());
        propiedad.setUbicacionMaps(datos.getUbicacionMaps());

        // Se vacía y se vuelve a llenar la misma colección (no se reemplaza
        // el objeto) para que Hibernate actualice la tabla propiedad_caracteristica.
        propiedad.getCaracteristicas().clear();
        if (datos.getCaracteristicas() != null) {
            propiedad.getCaracteristicas().addAll(datos.getCaracteristicas());
        }

        propiedadRepository.save(propiedad);

        // Fotos: se borran las que tenía y se vuelven a guardar las que
        // mandó la app, en ese orden. El flush hace que los DELETE se
        // ejecuten antes de los INSERT (si no, Hibernate hace primero los
        // INSERT y podría chocar con una restricción de orden único).
        List<Imagen> actuales = propiedad.getImagenes();
        if (actuales != null && !actuales.isEmpty()) {
            imagenRepository.deleteAll(new ArrayList<>(actuales));
            imagenRepository.flush();
        }
        guardarImagenes(propiedad, datos.getImagenesUrls());

        return ResponseEntity.ok().build();
    }

    // DELETE /api/propiedades/{id} -> eliminar propiedad (SOLO administrador).
    // Quita primero lo que depende de ella (recomendaciones que apuntan a
    // ella y sus fotos); sus características y las recomendaciones que ella
    // hace a otras se borran solas junto con la propiedad.
    // NOTA: cuando se agreguen reseñas/favoritos con llave foránea a
    // propiedad, hay que borrarlos también aquí.
    @DeleteMapping("/{id}")
    @Transactional
    public ResponseEntity<Void> eliminar(
            @PathVariable Long id,
            @RequestHeader(value = "X-Usuario-Id", required = false) Long idUsuario
    ) {
        if (!esAdministrador(idUsuario)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        Propiedad propiedad = propiedadRepository.findById(id).orElse(null);
        if (propiedad == null) {
            return ResponseEntity.notFound().build();
        }

        propiedadRepository.quitarRecomendacionesHacia(id);

        List<Imagen> imagenes = propiedad.getImagenes();
        if (imagenes != null && !imagenes.isEmpty()) {
            imagenRepository.deleteAll(new ArrayList<>(imagenes));
        }

        propiedadRepository.delete(propiedad);

        return ResponseEntity.noContent().build();
    }

    // Una fila en "imagen" por cada link, respetando el orden de la lista.
    private void guardarImagenes(Propiedad propiedad, List<String> urls) {
        if (urls == null) return;
        int orden = 0;
        for (String url : urls) {
            if (url == null || url.isBlank()) continue;
            Imagen imagen = new Imagen();
            imagen.setPropiedad(propiedad);
            imagen.setUrl(url.trim());
            imagen.setOrden(orden++);
            imagenRepository.save(imagen);
        }
    }
}