export class PrecioListDTO {
    public encrypted_id: string;
	public codigo: string;
	public descripcion: string;
	public precio: number;
    public listaDePrecios: string;
    public aplicaDesdeFechaHora: Date;
    public aplicaDesdeDias: number;
}