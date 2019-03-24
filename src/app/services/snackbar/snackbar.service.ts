import { Subscription } from 'rxjs/Subscription';
import { Subject } from 'rxjs/Subject';
import { Inject, Injectable, OnDestroy } from '@angular/core';
import { MatSnackBar, MatSnackBarConfig, MatSnackBarRef, SimpleSnackBar } from '@angular/material';

export class SnackBarMessage  {
  message: string;
  action: string = null;
  config: MatSnackBarConfig = null;
}

@Injectable()
export class SnackbarService implements OnDestroy
{
    private snackBarRef:  MatSnackBarRef<SimpleSnackBar>;
    private msgQueue = [];
    private subscription: Subscription;
    private isInstanceVisible = false;
    
    constructor(public snackBar: MatSnackBar){
    }
    
    showNext() {
      if (this.msgQueue.length === 0) {
        return;
      }
      const message = this.msgQueue.shift();
      this.isInstanceVisible = true;
      this.snackBarRef = this.snackBar.open(message.message, message.action, {duration: 2000});
      this.snackBarRef.afterDismissed().subscribe(() => {
        this.isInstanceVisible = false;
        this.showNext();
      });
    }

    /**
     * Add a message
     * @param message The message to show in the snackbar.
     * @param action The label for the snackbar action.
     * @param config Additional configuration options for the snackbar.
     */
    add(message: string, action?: string, config?: MatSnackBarConfig): void{

        const sbMessage = new SnackBarMessage();
        sbMessage.message = message;
        sbMessage.action = action;

        this.msgQueue.push(sbMessage);
        if (!this.isInstanceVisible) {
            this.showNext(); 
        }
    }

    ngOnDestroy() {
      this.subscription.unsubscribe();
    }
}
