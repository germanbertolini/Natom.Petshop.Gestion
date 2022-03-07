import { FeatureFlagsAccesoDTO } from "./feature-flags.acceso.dto";
import { FeatureFlagsStockDTO } from "./feature-flags.stock.dto";

export class FeatureFlagsDTO {
    public acceso: FeatureFlagsAccesoDTO;
    public stock: FeatureFlagsStockDTO;
}