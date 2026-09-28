package com.raizcapital.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;

@Entity
@Table(name = "usuario")
public class Usuario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_usuario")
    private Long id;

    private String nombre;

    @Column(unique = true, nullable = false)
    private String correo;

    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY) // nunca se devuelve en las respuestas JSON
    @Column(name = "contrasena", nullable = false)
    private String contrasena; // guardar siempre con hash (BCrypt), nunca texto plano

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Rol rol;

    private String telefono;

    public enum Rol {
        COMPRADOR, VENDEDOR, ADMINISTRADOR
    }

    // Getters y setters
    public Long getId() { return id; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getCorreo() { return correo; }
    public void setCorreo(String correo) { this.correo = correo; }
    public String getContrasena() { return contrasena; }
    public void setContrasena(String contrasena) { this.contrasena = contrasena; }
    public Rol getRol() { return rol; }
    public void setRol(Rol rol) { this.rol = rol; }
    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }
}