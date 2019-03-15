import { Component, OnInit } from '@angular/core';
import { MatDialogRef } from '@angular/material';

@Component({
  selector: 'app-dialog-account-delete',
  templateUrl: './dialog-account-delete.component.html',
  styleUrls: ['./dialog-account-delete.component.css']
})
export class DialogAccountDeleteComponent implements OnInit {

  constructor(public dialogRef: MatDialogRef<DialogAccountDeleteComponent>,) { }

  ngOnInit() {
  }

}
