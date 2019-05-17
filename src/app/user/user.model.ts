/**
 * A user represents an agent that uploads images
 */

export class User {

  userid: number;
  email: string;
  salt: string;
  password: string;
  forename: string;
  surname: string;
  userToken: string;
  signUpToken: string;
  signUpValidated: number;
  createdAt: string;
  authenticated: number;
  avatarSrc: string;
  emailNotification: number;
  keeploggedin: number;
  submitArticleNotification: number;
  cookieAcceptance: number;
  theme: string;
  roleid: number;
  forgottenPasswordToken: string;
  forgottenPasswordValidated: number;
  displayName: string;
  replyNotification: number;
  threadNotification: number;

  constructor(obj?: any) {

    this.userid = obj && obj.userid || 0;
    this.email = obj && obj.email || null;
    this.salt = obj && obj.salt || null;
    this.password = obj && obj.password || null;
    this.forename = obj && obj.forename || null;
    this.surname = obj && obj.surname || null;
    this.userToken = obj && obj.userToken || null;
    this.signUpToken = obj && obj.signUpToken || null;
    this.signUpValidated = obj && obj.signUpValidated || 0;
    this.createdAt = obj && obj.createdAt || null;
    this.authenticated = obj && obj.authenticated || 0;
    this.avatarSrc = obj && obj.avatarSrc || null;
    this.emailNotification = obj && obj.emailNotification || 0;
    this.keeploggedin = obj && obj.keeploggedin || 0;
    this.submitArticleNotification = obj && obj.submitArticleNotification || 0;
    this.cookieAcceptance = obj && obj.cookieAcceptance || 0;
    this.theme = obj && obj.theme || null;
    this.roleid = obj && obj.roleid || 2;
    this.forgottenPasswordToken = obj && obj.forgottenPasswordToken || null;
    this.forgottenPasswordValidated = obj && obj.forgottenPasswordValidated || 0;
    this.displayName = obj && obj.displayName || '';
    this.replyNotification = obj && obj.replyNotification || 0;
    this.threadNotification = obj && obj.threadNotification || 0;

  }
  
}
