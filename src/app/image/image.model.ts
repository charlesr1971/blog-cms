/**
 * An image represents an image uploaded by a user
 */

import { uuid } from '../util/uuid';

export class Image {

    id: string;
    fileid: number;
    userid: number;
    category: string;
    src: string;
    author: string;
    title: string;
    description: string;
    article: string;
    size: number;
    likes: number;
    tags: string;
    comments: any;
    publishArticleDate: string;
    approved: number;
    createdAt: string;
    avatarSrc: string;
    imageAccreditation: string;
    imageOrientation: string;

    constructor(obj?: any) {

        this.id = obj && obj.id || uuid();
        this.fileid = obj && obj.fileid || 0;
        this.userid = obj && obj.userid || 0;
        this.category = obj && obj.category || null;
        this.src = obj && obj.src || null;
        this.author = obj && obj.author || null;
        this.title = obj && obj.title || null;
        this.description = obj && obj.description || null;
        this.article = obj && obj.article || null;
        this.size = obj && obj.size || 0;
        this.likes = obj && obj.likes || 0;
        this.tags = obj && obj.tags || null;
        this.comments = obj && obj.comments || null;
        this.publishArticleDate = obj && obj.publishArticleDate || null;
        this.approved = obj && obj.approved || 0;
        this.createdAt = obj && obj.createdAt || null;
        this.avatarSrc = obj && obj.avatarSrc || '';
        this.imageAccreditation = obj && obj.imageAccreditation || '';
        this.imageOrientation = obj && obj.imageOrientation || 'landscape';


    }

}
