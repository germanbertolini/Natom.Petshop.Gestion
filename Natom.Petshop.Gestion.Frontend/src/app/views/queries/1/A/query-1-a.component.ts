import { Component, NgModule, OnInit } from "@angular/core";
import { ChartDataSets } from "chart.js";
import { Color, Label } from "ng2-charts";
import { ConfirmDialogService } from "src/app/components/confirm-dialog/confirm-dialog.service";
import { AuthService } from "src/app/services/auth.service";

@Component({
    selector: 'app-query-1-a',
    styleUrls: ['./query-1-a.component.css'],
    templateUrl: './query-1-a.component.html'
})
export class Query1AComponent implements OnInit {
    
    lineChartData: ChartDataSets[] = [
        { data: [12, 72, 78, 75, 17, 75], label: 'Crude oil prices' },
        { data: [85, 12, 28, 75, 17, 75], label: 'Another crud' }
    ];

    lineChartLabels: Label[] = [ 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio' ];

    lineChartOptions = { responsive: true };

    lineChartColors: Color[] = [
        {
            borderColor: "black",
            backgroundColor: "rgb(176, 196, 222, .5)"
        }
    ];

    lineChartLegend = true;
    lineChartPlugins = [];
    lineChartType = "line";


    constructor(private authService: AuthService,
                private confirmDialogService: ConfirmDialogService) {
        //PRUEBA DE AuthService
        // try {
        //     var result = authService.Login("german", "1234");
        // }
        // catch (error) {
        //     confirmDialogService.showOK(error);
        // }
    }

    ngOnInit(): void {
        
    }

}