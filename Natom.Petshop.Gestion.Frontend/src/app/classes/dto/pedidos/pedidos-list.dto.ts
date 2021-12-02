export class PedidosListDTO {
    public encrypted_id: string;
    public numero: string;
    public venta_encrypted_id: string;
    public numeroVenta: string;
    public remito: string;
    public factura: string;
    public cliente: string;
    public fechaHora: Date;
    public usuario: string;
    public estado: string;
    public prepared: boolean;
}