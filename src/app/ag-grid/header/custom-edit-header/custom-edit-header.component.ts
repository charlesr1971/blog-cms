/* import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-custom-edit-header',
  templateUrl: './custom-edit-header.component.html',
  styleUrls: ['./custom-edit-header.component.css']
})
export class CustomEditHeaderComponent implements OnInit {

  constructor() { }

  ngOnInit() {
  }

} */


import { Component } from '@angular/core';

@Component({
    selector: 'edit-header',
    template: `
        <div>
            <div *ngIf="params.menuIcon != ''" class="customHeaderMenuButton"><i class="fa {{ params.menuIcon }}"></i></div> 
            <div class="customHeaderLabel">{{ params.displayName }}</div> 
        </div>
    `,
    styles: [
        `
        .customHeaderMenuButton
        {
            float: right;
            margin: 0;
            line-height: 34px;
        }

        .customHeaderLabel
        {
            float: left;
            margin: 0;
            line-height: 34px;
            font-family: Roboto,"Helvetica Neue",sans-serif !important;
        }
    
    `
    ]
})

export class CustomEditHeader {

    params: any;

    agInit(params): void {

        this.params = params;

    }

}

