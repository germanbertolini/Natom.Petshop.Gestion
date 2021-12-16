import { VentaDetalleDTO } from "./venta-detalle.dto";

export class VentaDTO {
    public encrypted_id: string;
    public numero: string;
    public fechaHora: Date;
    public cliente_encrypted_id: string;
    public usuario: string;
    public tipo_factura: string;
    public numero_factura: string;
    public observaciones: string;

    public detalle: VentaDetalleDTO[];
}