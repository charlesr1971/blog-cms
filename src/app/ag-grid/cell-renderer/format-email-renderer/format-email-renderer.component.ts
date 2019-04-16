import { Component, OnInit } from '@angular/core';
import { ICellRendererAngularComp } from "ag-grid-angular";

@Component({
  selector: 'email-cell',
  template: `<a href="mailto:{{ this.params.value }}" class="ag-grid-format-email-renderer">{{ this.params.value }}</a>`,
})
export class FormatEmailRenderer implements ICellRendererAngularComp {

  private params: any;

  agInit(params: any): void {
    this.params = params;
  }

  refresh(params: any): boolean {
    this.params = params;
    return false;
  }

}
