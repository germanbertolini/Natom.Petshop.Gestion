export class Organization {
    public encrypted_id: string;
    public registered_at: Date;
    public picture_url: string;
    public business_name: string;
    public country_icon: string;

    public jornada_tolerancia_ingreso_mins: number;
    public jornada_tolerancia_egreso_mins: number;
    public almuerzo_rango_horario_desde: Date;
    public almuerzo_rango_horario_hasta: Date;
    public almuerzo_tiempo_limite_mins: number;
}