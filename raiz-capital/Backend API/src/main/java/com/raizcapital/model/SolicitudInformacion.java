package com.raizcapital.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

// Relación ternaria Solicita_Información: comprador – propiedad – vendedor
@Entity
@Table(name = "solicitud_informacion")
public class SolicitudInformacion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_solicitud")
    private Long id;

    @ManyToOne
    @JoinColumn(name = "id_comprador", nullable = false)
    private Usuario comprador;

    @ManyToOne
    @JoinColumn(name = "id_propiedad", nullable = false)
    private Propiedad propiedad;

    @ManyToOne
    @JoinColumn(name = "id_vendedor", nullable = false)
    private Usuario vendedor;

    @Column(name = "fecha_solicitud")
    private LocalDateTime fechaSolicitud = LocalDateTime.now();

    @Enumerated(EnumType.STRING)
    @Column(name = "medio_contacto", nullable = false)
    private MedioContacto medioContacto;

    public enum MedioContacto { WHATSAPP, TELEFONO, CORREO }

    public Long getId() { return id; }
    public Usuario getComprador() { return comprador; }
    public void setComprador(Usuario comprador) { this.comprador = comprador; }
    public Propiedad getPropiedad() { return propiedad; }
    public void setPropiedad(Propiedad propiedad) { this.propiedad = propiedad; }
    public Usuario getVendedor() { return vendedor; }
    public void setVendedor(Usuario vendedor) { this.vendedor = vendedor; }
    public LocalDateTime getFechaSolicitud() { return fechaSolicitud; }
    public void setFechaSolicitud(LocalDateTime fechaSolicitud) { this.fechaSolicitud = fechaSolicitud; }
    public MedioContacto getMedioContacto() { return medioContacto; }
    public void setMedioContacto(MedioContacto medioContacto) { this.medioContacto = medioContacto; }
}
