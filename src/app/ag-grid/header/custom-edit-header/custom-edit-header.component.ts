import { Component } from '@angular/core';

@Component({
    selector: 'edit-header',
    template: `
        <div class="customEditHeaderContainer">
            <div class="customEditHeaderLabel">{{ params.displayName }}</div><i *ngIf="params.enableMenu" class="fa fa-pencil customEditHeaderIcon"></i> 
            <div *ngIf="params.enableSorting" (click)="onSortRequested('asc', $event)" [ngClass]="ascSort" class="customEditHeaderSortDownLabel"><i class="fa fa-long-arrow-down"></i></div> 
            <div *ngIf="params.enableSorting" (click)="onSortRequested('desc', $event)" [ngClass]="descSort" class="customEditHeaderSortUpLabel"><i class="fa fa-long-arrow-up"></i></div> 
            <div *ngIf="params.enableSorting" (click)="onSortRequested('', $event)" [ngClass]="noSort" class="customEditHeaderSortRemoveLabel"><i class="fa fa-times"></i></div>
        </div>
    `,
    styles: [
        `
        .customEditHeaderContainer
        {
          cursor: default !important;
        }

        .customEditHeaderIcon
        {
            float: right;
            margin: 0;
            line-height: 34px;
            cursor: default !important;
            pointer-events:none !important;
        }

        .customEditHeaderLabel, 
        .customEditHeaderSortDownLabel, 
        .customEditHeaderSortUpLabel, 
        .customEditHeaderSortRemoveLabel
        {
            float: left;
            margin: 0 5px 0 5px;
            line-height: 34px;
            font-family: Roboto,Helvetica,sans-serif !important;
        }

        .customEditHeaderSortDownLabel, 
        .customEditHeaderSortUpLabel, 
        .customEditHeaderSortRemoveLabel
        {
          cursor: pointer !important;
        }

        .customEditHeaderLabel
        {
          cursor: default !important;
          pointer-events:none !important;
        }

        .customEditHeaderSortUpLabel {
          margin: 0;
        }

        .customEditHeaderSortRemoveLabel {
            font-size: 11px;
        }
    
    `
    ]
})

export class CustomEditHeader {

    params: any;

    ascSort: string;
    descSort: string;
    noSort: string;


    agInit(params): void {

        this.params = params;

        params.column.addEventListener('sortChanged', this.onSortChanged.bind(this));
        this.onSortChanged();

    }

    onSortChanged() {
        this.ascSort = this.descSort = this.noSort = 'inactive';
        if (this.params.column.isSortAscending()) {
            this.ascSort = 'active';
        } else if (this.params.column.isSortDescending()) {
            this.descSort = 'active';
        } else {
            this.noSort = 'active';
        }
    }

    onSortRequested(order, event) {
        this.params.setSort(order, event.shiftKey);
    }

}

