export class MovimientoCajaDiariaDTO {
    public encrypted_id: string;
    public fechaHora: Date;
    public usuarioNombre: String;
    public tipo: String;
    public importe: number;
    public observaciones: String;
    public esCheque: boolean;
    public esCtaCte: boolean;
    public cliente_encrypted_id: string;
}