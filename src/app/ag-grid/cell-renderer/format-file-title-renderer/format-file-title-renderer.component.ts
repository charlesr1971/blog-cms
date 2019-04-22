import { Component, OnInit } from '@angular/core';
import { ICellRendererAngularComp } from "ag-grid-angular";

@Component({
  selector: 'title-cell',
  template: `<a (click)="previewArticle()" class="ag-grid-format-file-title-renderer"><i class="fa fa-eye"></i></a>{{ this.params.value }}`,
})
export class FormatFileTitleRenderer implements ICellRendererAngularComp {

  params: any;

  agInit(params: any): void {
    this.params = params;
  }

  public previewArticle() {
    this.params.context.componentParent.previewArticle(this.params.node);
  }

  refresh(params: any): boolean {
    this.params = params;
    return false;
  }

}
