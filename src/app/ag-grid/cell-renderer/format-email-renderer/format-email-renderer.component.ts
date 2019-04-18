import { Component, OnInit } from '@angular/core';
import { ICellRendererAngularComp } from "ag-grid-angular";

@Component({
  selector: 'email-cell',
  template: `<a (click)="openEmailDialog()" class="ag-grid-format-email-renderer"><i class="fa fa-envelope"></i></a>{{ this.params.value }}`,
})
export class FormatEmailRenderer implements ICellRendererAngularComp {

  params: any;

  agInit(params: any): void {
    this.params = params;
    //console.log(this.params.node);
  }

  public openEmailDialog() {
    console.log(this.params.node);
    //this.params.context.componentParent.openEmailDialog(`${this.params.node}`)
    this.params.context.componentParent.openEmailDialog(this.params.node);
  }

  refresh(params: any): boolean {
    this.params = params;
    return false;
  }

}
