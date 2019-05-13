/**
 * An image represents comment made by a user
 */

import { uuid } from '../util/uuid';

export class Comment {

    id: string;
    commentid: number;
    userid: number;
    fileUuid: string;
    fileid: number;
    comment: string;
    forename: string;
    surname: string;
    avatarSrc: string;
    token: string;
    replyToCommentid: number;
    replies: any;
    createdAt: string;
    displayName: string;

    constructor(obj?: any) {

        this.id = obj && obj.id || uuid();
        this.commentid = obj && obj.commentid || 0;
        this.userid = obj && obj.userid || 0;
        this.fileUuid = obj && obj.fileUuid || null;
        this.fileid = obj && obj.fileid || 0;
        this.comment = obj && obj.comment || null;
        this.forename = obj && obj.forename || null;
        this.surname = obj && obj.surname || null;
        this.avatarSrc = obj && obj.avatarSrc || null;
        this.token = obj && obj.token || null;
        this.replyToCommentid = obj && obj.replyToCommentid || 0;
        this.replies = obj && obj.replies || null;
        this.createdAt = obj && obj.createdAt || null;
        this.displayName = obj && obj.displayName || '';

    }

}
