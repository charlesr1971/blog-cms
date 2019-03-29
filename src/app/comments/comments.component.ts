import { Component, OnInit, OnDestroy, Input, Inject, Renderer2, ViewChild, TemplateRef, Output, EventEmitter } from '@angular/core';
import { Observable, Subscription } from 'rxjs';
import { debounceTime, distinctUntilChanged } from 'rxjs/operators';
import { DOCUMENT } from '@angular/common';
import { DeviceDetectorService } from 'ngx-device-detector';
import { FormGroup, FormControl, Validators } from '@angular/forms';
import { trigger, state, style, animate, transition, AnimationEvent} from '@angular/animations';
import { firstBy } from 'thenby';
import { MatDialog } from '@angular/material';
import { CookieService } from 'ngx-cookie-service';
import { styler } from '../util/styler';
import { updateCdkOverlayThemeClass } from '../util/updateCdkOverlayThemeClass';

import { User } from '../user/user.model';
import { Comment } from '../comment/comment.model';
import { UtilsService } from '../services/utils/utils.service';
import { Image } from '../image/image.model';
import { HttpService } from '../services/http/http.service';
import { environment } from '../../environments/environment';

declare var TweenMax: any, Elastic: any;

interface CommentElementsPrefix {
  parentClose: string;
  refchildClose: string
};

@Component({
  selector: 'app-comments',
  templateUrl: './comments.component.html',
  styleUrls: ['./comments.component.css'],
  animations: [
    trigger('commentsFadeInOutAnimation', [
      state('in', style({
        opacity: 1,
        display: 'block'
      })),
      state('out', style({
        opacity: 0,
        display: 'none'
      })),
      transition('in => out', animate('250ms ease-in')),
      transition('out => in', animate('250ms ease-out'))
  ]),
  ]
})
export class CommentsComponent implements OnInit, OnDestroy {

  @ViewChild('dialogComments') private dialogCommentsTpl: TemplateRef<any>;
  @ViewChild('dialogCommentsProfanityNotification') private dialogCommentsProfanityNotificationTpl: TemplateRef<any>;
  @Output() sendCommentsTotal: EventEmitter<any> = new EventEmitter();
  @Output() sendDisableCommentTooltip: EventEmitter<any> = new EventEmitter();
  @Output() sendHideCommentInput: EventEmitter<any> = new EventEmitter();
  @Input() image: Image;
  @Input() commentsState: string = 'out';
  @Input() scrollToCommentsPanel: boolean = false;
  @Input() currentUser: User;
  @Input() disableCommentTooltip: boolean = false;

  @Input() CommentElementsPrefix: CommentElementsPrefix  = {
    parentClose: '',
    refchildClose: ''
  };

  isMobile: boolean = false;

  formData = {};
  commentForm: FormGroup;
  commentInput: FormControl;
  minCommentInputLength: number = 3;
  maxCommentInputLength: number = environment.maxCommentInputLength;

  comments = [];
  scrollCallbackComments; 
  currentPage: number = 1;
  commentsArrayIsEmpty: boolean = true;
  commentsTotal: number = 0;
  addCommentSubscription: Subscription;
  deleteCommentSubscription: Subscription;
  commentsDo: boolean = false;
  currentUserid: number = 0;
  disableCommentExpandTooltip: boolean = false;
  disableCommentGeneralTooltip: boolean = false;
  hideCommentInput: boolean = false;
  showCommentTooltipMax: number = 99;
  replyToCommentid: number = 0;
  lastReplyToCommentid: number = 0;
  commentsDialogIsOpen: boolean = false;
  themeTypeLight: boolean = false;
  themeRemove: string = '';
  themeAdd: string = '';
  debug: boolean = false;

  constructor(@Inject(DOCUMENT) private documentBody: Document,
    private renderer: Renderer2,
    private httpService: HttpService,
    private utilsService: UtilsService,
    private deviceDetectorService: DeviceDetectorService,
    public cookieService: CookieService,
    public dialog: MatDialog) { 

      if(environment.debugComponentLoadingOrder) {
        console.log('comments.component loaded');
      }

      const themeObj = this.httpService.themeObj;
      this.themeTypeLight = this.cookieService.check('theme') && this.cookieService.get('theme') === themeObj['light'] ? true : false;
      this.themeRemove = this.cookieService.check('theme') && this.cookieService.get('theme') === themeObj['light'] ? themeObj['dark'] : themeObj['light'];
      this.themeAdd = this.themeRemove === themeObj['light'] ? themeObj['dark'] : themeObj['light'];

      this.isMobile = this.deviceDetectorService.isMobile();

      if(this.isMobile) {
        this.disableCommentTooltip = true;
        this.sendDisableCommentTooltip.emit(this.disableCommentTooltip);
        this.disableCommentExpandTooltip = true;
        this.disableCommentGeneralTooltip = true;
      }

      this.scrollCallbackComments = this.fetchComments.bind(this);

  }

  ngOnInit() {

    if(environment.debugComponentLoadingOrder) {
      console.log('comments.component init');
    }

    if(this.debug) {
      console.log(this.dialogCommentsTpl);
    }
    if(this.debug) {
      console.log('comments.component: this.currentUser: ', this.currentUser);
    }  
    this.currentUserid = this.currentUser['userid'];
    if(this.debug) {
      console.log('comments.component: this.currentUserid: ',this.currentUserid);
    }
    if(this.debug) {
      console.log('comments.component: this.image: ', this.image);
      console.log('comments.component: this.image.id: ', this.image.id);
      console.log('comments.component: this.image.userid: ', this.image.userid);
    }  
    this.createFormControls();
    this.createForm();
    this.monitorFormValueChanges();

  }

  fetchComments(): Observable<any> {
    if(this.debug) {
      console.log('comments.component: fetchComments: this.httpService.viewCommentid: ', this.httpService.viewCommentid);
    }
    return this.httpService.fetchComments(this.currentPage,this.image['id'],this.httpService.viewCommentid).do(this.processComments);
  }

  addComment(event: any,id): void {
    if(this.debug) {
      console.log('comments.component: addComment: this.formData["comment"]: ',this.formData['comment']);
      console.log('comments.component: addComment: this.image["id"]: ',this.image['id']);
      console.log('comments.component: addComment: this.currentUserid: ',this.currentUserid);
      console.log('comments.component: addComment: id: ',id);
    }
    const data = {
      fileUuid: this.image['id'],
      userid: this.currentUserid,
      comment: this.formData['comment'],
      replyToCommentid: this.replyToCommentid
    }
    if(this.minCommentInputLength < this.formData['comment'].length) {
      this.addCommentSubscription = this.httpService.addComment(data).do(this.processAddCommentData).subscribe();
    }
  }

  deleteComment($event,commentid): void {
    if(this.debug) {
      console.log('comments.component: deleteComment: commentid: ',commentid);
    }
    const data = {
      commentid: commentid
    }
    this.deleteCommentSubscription = this.httpService.deleteComment(data).do(this.processDeleteCommentData).subscribe();
  }

  commentScore(n: number): void {
    if((this.commentsTotal) >= 0) {
      this.commentsTotal = n;
    }
    else{
      this.commentsTotal = 0;
    }
  }

  private processComments = (data) => {
    if(this.debug) {
      console.log('comments.component: processComments: data: ', data);
    }
    if(data) {
      this.currentPage++;
      this.commentScore(data['total']);
      this.sendCommentsTotal.emit(this.commentsTotal);
      if(this.debug) {
        console.log('comments.component: processComments: this.currentPage ', this.currentPage);
        console.log('comments.component: processComments: this.commentsTotal ', this.commentsTotal);
      }
      if(!this.utilsService.isEmpty(data) && 'comments' in data && Array.isArray(data['comments']) && data['comments'].length) {
        this.image['comments'] = [];
        data['comments'].map( (item: any) => {
          const comment = new Comment({
            commentid: item['commentid'],
            userid: item['userid'],
            fileUuid: item['fileUuid'],
            fileid: item['fileid'],
            comment: item['comment'],
            forename: item['forename'],
            surname: item['surname'],
            avatarSrc: item['avatarSrc'],
            token: item['token'],
            replyToCommentid: item['replyToCommentid'],
            createdAt: item['createdAt']
          });
          this.comments.push(comment);
        });
        this.sortCommentsWithReplies('asc');
        this.image['comments'] = this.comments;
        this.disableCommentTooltip = !this.isMobile ? this.disabledCommentTooltip() : true;
        this.sendDisableCommentTooltip.emit(this.disableCommentTooltip);
        this.commentsArrayIsEmpty = false;
        if(data['viewcomment'] === 1) {
          this.commentsState = 'in';
          this.httpService.viewCommentid = 0;
          this.scrollCallbackComments = null;
          this.hideCommentInput = true;
          this.sendHideCommentInput.emit(this.hideCommentInput);
        }
        if(this.debug) {
          console.log('comments.component: processComments: this.comments: ', this.comments);
        }
      }
    }
  }

  private processAddCommentData = (data) => {
    if(this.debug) {
      console.log('comments.component: processAddCommentData: data',data);
    }
    if(data) {
      if(!this.utilsService.isEmpty(data)) {
        if('hasProfanity' in data && !data['hasProfanity']) {
          if('error' in data && data['error'] === '') {
            this.resetCommentReplyToCommentid();
            this.replyToCommentid = 0;
            this.lastReplyToCommentid = 0;
            this.commentInput.patchValue('');
            this.resetComments();
            const commentcharcounter = this.documentBody.querySelector('#comment-char-counter-' + this.image.id);
            if(commentcharcounter) {
              commentcharcounter.innerHTML = environment.maxCommentInputLength.toString();
            }
          }
          else{
            if('jwtObj' in data) {
              this.httpService.jwtHandler(data['jwtObj']);
            }
          }
        }
        else{
          const dialogcommentsprofanitynotification = this.documentBody.querySelector('#dialog-comments-profanity-notification');
          if(this.debug) {
            console.log('comments.component: processAddCommentData: dialogcommentsprofanitynotification: ', dialogcommentsprofanitynotification);
          }
          if(!dialogcommentsprofanitynotification) {
            this.openCommentsProfanityNotificationDialog();
          }
        }
      }
      if(this.debug) {
        console.log('comments.component: processAddCommentData: this.comments: ', this.comments);
      }
    }
  }

  private processDeleteCommentData = (data) => {
    if(this.debug) {
      console.log('comments.component: processDeleteCommentData: data',data);
    }
    if(data) {
      if('error' in data && data['error'] === '') {
        this.resetComments();
      }
      else {
        if('jwtObj' in data) {
          this.httpService.jwtHandler(data['jwtObj']);
        }
      }
    }
  }

  createForm(): void {
    this.commentForm = new FormGroup({
      commentInput: this.commentInput
    });
  }

  createFormControls(): void {
    this.commentInput = new FormControl('', [
      Validators.required,
      Validators.minLength(this.minCommentInputLength),
      Validators.maxLength(this.maxCommentInputLength)
    ]);
  }

  monitorFormValueChanges(): void {
    if(this.commentForm) {
      this.commentInput.valueChanges
      .pipe(
        debounceTime(400),
        distinctUntilChanged()
      )
      .subscribe(comment => {
        if(this.debug) {
          console.log('comment: ',comment);
        }
        this.formData['comment'] = comment;
      });
    }
  }

  resetComments(): void {
    const commentContainer = this.documentBody.querySelector('#infinite-scroller-comments-' + this.image['id']);
    if(commentContainer) {
      commentContainer.scrollTop = 0;
    }
    this.comments = [];
    this.image['comments'] = [];
    this.currentPage = 1;
    this.scrollCallbackComments = null;
    this.httpService.fetchComments(this.currentPage,this.image['id'],this.httpService.viewCommentid).do(this.processComments).subscribe();
    this.scrollCallbackComments = this.fetchComments.bind(this);
    if(this.debug) {
      console.log('comments.component: removeComment: this.comments: ', this.comments);
      console.log('comments.component: removeComment: this.image["comments"]: ', this.image['comments']);
    }
  }

  openComments(event: any): void {
    this.commentsState = this.commentsState === 'in' ? 'out' : 'in';
    event.stopPropagation();
  }

  disabledCommentTooltip(): boolean {
    return this.comments.length > this.showCommentTooltipMax;
  }

  sortComments(): void {
    this.comments.sort(function(a, b) {
      const dateA: any = new Date(a.createdAt), dateB: any = new Date(b.createdAt);
      return dateB - dateA;
    });
  }

  sortCommentsWithReplies(sortMethod: string = 'desc'): void {
    switch (sortMethod) {
      case 'desc':
        var comments1 = [];
        comments1 = this.comments.filter( (comment) => {
          return comment['commentid'] === comment['replyToCommentid'];
        });
        var comments2 = [];
        comments2 = this.comments.filter( (comment) => {
          return comment['commentid'] !== comment['replyToCommentid'];
        });
        comments1.map( (comment1) => {
          comments2.map( (comment2) => {
            if (comment1['commentid'] === comment1['replyToCommentid'] && comment2['replyToCommentid'] === comment1['commentid']) {
            comment1['replies'].push(comment2);
            }
          });
        });
        const comments = [];
        comments1.map( (comment) => {
          comments.push(comment);
          if(comment['replies'].length) {
            comment['replies'].map( (item) => {
              comments.push(item);
            });
          }
          comment['replies'] = [];
        });
        this.comments = comments;
        break;
      case 'asc':
        this.comments.sort(
            firstBy(function (v1, v2) { return v1['replyToCommentid'] - v2['replyToCommentid'];},-1)
            .thenBy(function (v1, v2) { return v1['commentid'] - v2['commentid'];})
        );
        break;
      default:
    }
  }

  replyToComment($event,commentid): void {
    const overshoot=5;
    const period=0.25;
    if(this.debug) {
      console.log('comments.component: replyToComment: $event: ', $event);
      console.log('comments.component: replyToComment: commentid: ', commentid);
    }
    const commentReplyToCommentid = this.documentBody.querySelector('#comment-replytocommentid-' + commentid);
    if(this.debug) {
      console.log('comments.component: replyToComment: this.lastReplyToCommentid 1: ', this.lastReplyToCommentid);
      console.log('comments.component: replyToComment: commentid: ', commentid);
    }
    this.resetCommentReplyToCommentid();
    if(this.debug) {
      console.log('comments.component: replyToComment: this.lastReplyToCommentid 2: ', this.lastReplyToCommentid);
    }
    if(this.lastReplyToCommentid !== commentid) {
      this.lastReplyToCommentid = commentid;
      if(commentReplyToCommentid.classList.contains('comment-replytocommentid')){
        commentReplyToCommentid.classList.add('comment-replytocommentid-in');
        const styles = styler('.comment-replytocommentid-in').get(['color']);
        if(this.debug) {
          console.log('comments.component: replyToComment: styles: ', styles);
          console.log('comments.component: replyToComment: is object: ', typeof styles === 'object');
        }
        if(typeof styles === 'object' && 'color' in styles) {
          TweenMax.to(commentReplyToCommentid,0.5,{
            scale:0.25,
            color:styles['color'],
            onComplete:function(){
              TweenMax.to(commentReplyToCommentid,1.4,{
                scale:1,
                ease:Elastic.easeOut,
                easeParams:[overshoot,period]
              })
            }
          });
        }
        this.replyToCommentid = commentid;
      }
    }
    else{
      this.lastReplyToCommentid = 0;
      this.replyToCommentid = 0;
    }
    if(this.debug) {
      console.log('comments.component: replyToComment: this.replyToCommentid: ', this.replyToCommentid);
      console.log('comments.component: replyToComment: this.lastReplyToCommentid: ', this.lastReplyToCommentid);
    }
  }

  resetCommentReplyToCommentid(): void {
    const commentReplyToCommentidArray = Array.prototype.slice.call(this.documentBody.querySelectorAll('.comment-replytocommentid')).concat(Array.prototype.slice.call(this.documentBody.querySelectorAll('.comment-replytocommentid-in')));
    if(this.debug) {
      console.log('comments.component: replyToComment: commentReplyToCommentidArray: ', commentReplyToCommentidArray);
    }
    if(this.debug) {
      console.log('comments.component: replyToComment: commentReplyToCommentidArray: ', commentReplyToCommentidArray);
    }
    if(Array.isArray(commentReplyToCommentidArray) && commentReplyToCommentidArray.length) {
      if(this.debug) {
        console.log('comments.component: replyToComment: commentReplyToCommentidArray.length: ', commentReplyToCommentidArray.length);
      }
      commentReplyToCommentidArray.map( (element) => {
        if(this.debug) {
          console.log('comments.component: replyToComment: element: ', element);
        }
        element.classList.add('comment-replytocommentid');
        element.style.color = '';
        if(element.classList.contains('comment-replytocommentid-in')){
          element.classList.remove('comment-replytocommentid-in');
        }
      });
    }
  }

  closeCommentsDialog(): void {
    this.dialog.closeAll();
  }

  openCommentsDialog(): void {
    const dialogRef = this.dialog.open(this.dialogCommentsTpl, {
      width: this.isMobile ? '100%' :'50%',
      height: this.isMobile ? '100%' :'90%',
      maxWidth: 740,
      id: 'dialog-comments-' + this.image['id']
    });
    updateCdkOverlayThemeClass(this.themeRemove,this.themeAdd);
    const infiniteScrollerComments = this.documentBody.querySelector('#infinite-scroller-comments-' + this.image['id']);
    const newChild = this.documentBody.querySelector('#app-comments-' + this.image['id']);
    dialogRef.beforeClose().subscribe(result => {
      if(this.debug) {
        console.log('comments.component: dialog before close');
      }
      if(result) {
        if(this.debug) {
          console.log('comments.component: dialog result: ', result);
        }
      }
      this.commentsDialogIsOpen = false;
      if(this.debug) {
        console.log('comments.component: dialog result: this.CommentElementsPrefix: ', this.CommentElementsPrefix);
      }
      const parent = this.documentBody.querySelector(this.CommentElementsPrefix['parentClose'] + this.image['id']);
      const refChild = this.documentBody.querySelector(this.CommentElementsPrefix['refchildClose'] + this.image['id']);
      if(this.debug) {
        console.log('comments.component: dialog result: parent: ', parent);
        console.log('comments.component: dialog result: refChild: ', refChild);
      }
      this.renderer.setStyle(infiniteScrollerComments, 'height', '250px');
      this.renderer.insertBefore(parent, newChild, refChild);
      this.httpService.commentsDialogOpened.next(false);
    });
    dialogRef.afterOpen().subscribe( () => {
      if(this.debug) {
        console.log('comments.component: dialog after open');
      }
      this.commentsDialogIsOpen = true;
      const parent = this.documentBody.querySelector('#dialog-comments-' + this.image['id']);
      let height = parent.clientHeight ? parent.clientHeight : 0;
      const offset = this.currentUser.authenticated !== 0 ? 12 : 42;
      const padding = 48;
      const commentInputHeight = this.currentUser.authenticated !== 0 ? 108 : 0;
      const matCardContentPadding = 32;
      const commentAddHeight = this.currentUser.authenticated !== 0 ? 24 : 0;
      if(!isNaN(height) && (height - (padding + commentInputHeight + matCardContentPadding + commentAddHeight + offset)) > 0) {
        height = height - (padding + commentInputHeight + matCardContentPadding + commentAddHeight + offset);
      }
      if(this.debug) {
        console.log('comments.component: dialog: height: ', height);
      }
      this.renderer.appendChild(parent, newChild);
      if(height > 0 ) {
        this.renderer.setStyle(infiniteScrollerComments, 'height', height + 'px');
      }
      this.httpService.commentsDialogOpened.next(true);
    });
  }

  openCommentsProfanityNotificationDialog(): void {
    const dialogRef = this.dialog.open(this.dialogCommentsProfanityNotificationTpl, {
      width: this.isMobile ? '90%' :'25%',
      id: 'dialog-comments-profanity-notification'
    });
    updateCdkOverlayThemeClass(this.themeRemove,this.themeAdd);
    dialogRef.beforeClose().subscribe(result => {
      if(this.debug) {
        console.log('comments.component: dialog comments profanity notification: before close');
      }
      if(result) {
        if(this.debug) {
          console.log('comments.component: dialog comments profanity notification: before close: result: ', result);
        }
      }
    });
    dialogRef.afterOpen().subscribe( () => {
      if(this.debug) {
        console.log('comments.component: dialog comments profanity notification: after open');
      }
    });
  }

  commentsFadeInOutAnimationStart(event: AnimationEvent): void {
    if(this.debug) {
      console.log('comments.component: commentsFadeInOutAnimationStart: this.commentsState: ',this.commentsState);
    }
  }

  commentsFadeInOutAnimationDone(event: AnimationEvent): void {
    const element1 = this.documentBody.querySelector('#mat-sidenav-content');
    const element2 = this.documentBody.querySelector('.gallery-detail-comments-container');
    if(this.debug) {
      console.log('comments.component: closeAvatarSelectionContainerDone: this.commentsState: ',this.commentsState);
    }
    if(this.isMobile && this.scrollToCommentsPanel && element1 && element2) {
      if(this.commentsState === 'in') {
        if(this.debug) {
          console.log('comments.component: openComments(): element1.scrollHeight: ', element1.scrollHeight);
          console.log('comments.component: openComments(): element1.scrollTop: ', element1.scrollTop);
          console.log('comments.component: openComments(): element1.clientHeight: ', element1.clientHeight);
        }
        element1.scrollTop =  element1.scrollHeight;
      }
    }
    if(this.isMobile && !this.scrollToCommentsPanel && element1 && element2) {
      if(this.commentsState === 'in') {
        this.scrollToCommentsPanel = true;
      }
    }
  }

  ngOnDestroy() {

    if (this.addCommentSubscription) {
      this.addCommentSubscription.unsubscribe();
    }

    if (this.deleteCommentSubscription) {
      this.deleteCommentSubscription.unsubscribe();
    }

  }

}
