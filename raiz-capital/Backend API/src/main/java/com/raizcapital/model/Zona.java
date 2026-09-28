package com.raizcapital.model;

import jakarta.persistence.*;

@Entity
@Table(name = "zona")
public class Zona {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_zona")
    private Long id;

    @Column(name = "nombre_zona", nullable = false)
    private String nombreZona;

    @Column(nullable = false)
    private String ciudad;

    private String descripcion;

    public Long getId() { return id; }
    public String getNombreZona() { return nombreZona; }
    public void setNombreZona(String nombreZona) { this.nombreZona = nombreZona; }
    public String getCiudad() { return ciudad; }
    public void setCiudad(String ciudad) { this.ciudad = ciudad; }
    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
}
