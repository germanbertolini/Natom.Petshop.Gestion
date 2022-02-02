export class MovimientoCajaFuerteDTO {
    public encrypted_id: string;
    public fechaHora: Date;
    public usuarioNombre: String;
    public tipo: String;
    public importe: number;
    public proveedor_encrypted_id: string;
    public observaciones: String;
    public esCtaCte: boolean;
    public esCheque: boolean;
}