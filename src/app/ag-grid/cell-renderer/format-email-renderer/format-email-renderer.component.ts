import { Component, OnInit } from '@angular/core';
import { ICellRendererAngularComp } from "ag-grid-angular";

@Component({
  selector: 'email-cell',
  template: `<a href="mailto:{{ params.value }}">{{ params.value }}</a>`
})
export class FormatEmailRenderer implements ICellRendererAngularComp {

  public params: any;

  agInit(params: any): void {
      this.params = params;
  }

  refresh(): boolean {
    return false;
  }

}
