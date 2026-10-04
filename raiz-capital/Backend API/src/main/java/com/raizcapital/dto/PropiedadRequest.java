package com.raizcapital.dto;

import java.math.BigDecimal;
import java.util.List;

// DTO para crear una propiedad: en vez de mandar los objetos Usuario/Zona
// completos (que obligaría a resolver referencias JPA en el JSON), el
// formulario de la app solo manda los ids y acá los resolvemos.
public class PropiedadRequest {
    private Long idVendedor;
    private Long idZona;
    private String titulo;
    private String descripcion;
    private BigDecimal precio;
    private String tipo;       // CASA, DEPARTAMENTO, TERRENO, LOCAL
    private String operacion;  // VENTA, RENTA
    private Integer recamaras;
    private Integer banos;
    private BigDecimal superficieM2;
    private String calle;
    private String colonia;
    private String ubicacionMaps;
    private List<String> caracteristicas;
    private List<String> imagenesUrls; // links de Cloudinary, en el orden en que se deben mostrar

    public Long getIdVendedor() { return idVendedor; }
    public void setIdVendedor(Long idVendedor) { this.idVendedor = idVendedor; }
    public Long getIdZona() { return idZona; }
    public void setIdZona(Long idZona) { this.idZona = idZona; }
    public String getTitulo() { return titulo; }
    public void setTitulo(String titulo) { this.titulo = titulo; }
    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
    public BigDecimal getPrecio() { return precio; }
    public void setPrecio(BigDecimal precio) { this.precio = precio; }
    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }
    public String getOperacion() { return operacion; }
    public void setOperacion(String operacion) { this.operacion = operacion; }
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
    public List<String> getCaracteristicas() { return caracteristicas; }
    public void setCaracteristicas(List<String> caracteristicas) { this.caracteristicas = caracteristicas; }
    public List<String> getImagenesUrls() { return imagenesUrls; }
    public void setImagenesUrls(List<String> imagenesUrls) { this.imagenesUrls = imagenesUrls; }
}