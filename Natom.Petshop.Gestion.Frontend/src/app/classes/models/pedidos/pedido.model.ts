import { PedidoDetalle } from "./pedido-detalle.model";

export class Pedido {
    public encrypted_id: string;
    public numero: string;
    public fechaHora: Date;
    public cliente_encrypted_id: string;
    public entrega_estimada_fecha: Date;
    public entrega_estimada_rango_horario_encrypted_id: string;
    public entrega_observaciones: string;
    public usuario: string;
    public numero_remito: string;
    public observaciones: string;

    public detalle: PedidoDetalle[];
}