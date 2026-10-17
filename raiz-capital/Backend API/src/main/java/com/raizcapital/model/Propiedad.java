package com.raizcapital.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Entity
@Table(name = "propiedad")
public class Propiedad {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_propiedad")
    private Long id;

    @ManyToOne
    @JoinColumn(name = "id_vendedor", nullable = false)
    @JsonIgnoreProperties({"correo", "rol"}) // el catálogo es público: no exponer el correo del vendedor
    private Usuario vendedor; // relación "Publica"

    @ManyToOne
    @JoinColumn(name = "id_zona", nullable = false)
    private Zona zona; // relación "Pertenece"

    private String titulo;

    @Column(columnDefinition = "TEXT")
    private String descripcion;

    private BigDecimal precio;

    @Enumerated(EnumType.STRING)
    private Tipo tipo;

    @Enumerated(EnumType.STRING)
    private Operacion operacion;

    private Integer recamaras;
    private Integer banos;

    @Column(name = "superficie_m2")
    private BigDecimal superficieM2;

    private String calle;
    private String colonia;

    @Column(name = "ubicacion_maps")
    private String ubicacionMaps;

    @Enumerated(EnumType.STRING)
    private Estado estado;

    // Atributo multivalorado -> tabla propiedad_caracteristica
    @ElementCollection
    @CollectionTable(name = "propiedad_caracteristica", joinColumns = @JoinColumn(name = "id_propiedad"))
    @Column(name = "caracteristica")
    private Set<String> caracteristicas = new HashSet<>();

    // Relación recursiva N:M -> propiedad_recomendacion
    // @JsonIgnore evita un ciclo infinito al convertir a JSON (más adelante se expone como lista de ids)
    @JsonIgnore
    @ManyToMany
    @JoinTable(
        name = "propiedad_recomendacion",
        joinColumns = @JoinColumn(name = "id_propiedad"),
        inverseJoinColumns = @JoinColumn(name = "id_propiedad_recomendada")
    )
    private Set<Propiedad> recomendaciones = new HashSet<>();

    @OneToMany(mappedBy = "propiedad")
    @OrderBy("orden ASC")
    private List<Imagen> imagenes;

    public enum Tipo { DEPARTAMENTO, CASA, TERRENO, LOCAL }
    public enum Operacion { RENTA, VENTA }
    public enum Estado { DISPONIBLE, VENDIDA, RENTADA }

    // Atributo derivado: se calcula, no se guarda en columna
    @Transient
    public BigDecimal getPrecioPorM2() {
        if (superficieM2 == null || superficieM2.compareTo(BigDecimal.ZERO) == 0) return null;
        return precio.divide(superficieM2, 2, java.math.RoundingMode.HALF_UP);
    }

    // Getters y setters
    public Long getId() { return id; }
    public Usuario getVendedor() { return vendedor; }
    public void setVendedor(Usuario vendedor) { this.vendedor = vendedor; }
    public Zona getZona() { return zona; }
    public void setZona(Zona zona) { this.zona = zona; }
    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }
    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
    public BigDecimal getPrecio() { return precio; }
    public void setPrecio(BigDecimal precio) { this.precio = precio; }
    public Tipo getTipo() { return tipo; }
    public void setTipo(Tipo tipo) { this.tipo = tipo; }
    public Operacion getOperacion() { return operacion; }
    public void setOperacion(Operacion operacion) { this.operacion = operacion; }
    public Integer getRecamaras() { return recamaras; }
    public void setRecamaras(Integer recamaras) { this.recamaras = recamaras; }
    public Integer getBanos() { return banos; }
    public void setBanos(Integer banos) { this.banos = banos; }
    public BigDecimal getSuperficieM2() { return superficieM2; }
    public void setSuperficieM2(BigDecimal superficieM2) { this.superficieM2 = superficieM2; }
    public String getCalle() { return calle; }
    public void setCalle(String calle) { this.calle = calle; }
    public String getColonia() { return colonia; }
    public void setColonia(String colonia) { this.colonia = colonia; }
    public String getUbicacionMaps() { return ubicacionMaps; }
    public void setUbicacionMaps(String ubicacionMaps) { this.ubicacionMaps = ubicacionMaps; }
    public Estado getEstado() { return estado; }
    public void setEstado(Estado estado) { this.estado = estado; }
    public Set<String> getCaracteristicas() { return caracteristicas; }
    public void setCaracteristicas(Set<String> caracteristicas) { this.caracteristicas = caracteristicas; }
    public List<Imagen> getImagenes() { return imagenes; }
    public Set<Propiedad> getRecomendaciones() { return recomendaciones; }
    public void setRecomendaciones(Set<Propiedad> recomendaciones) { this.recomendaciones = recomendaciones; }
}