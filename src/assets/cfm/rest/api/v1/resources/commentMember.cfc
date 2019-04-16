
<cfcomponent extends="taffy.core.resource" taffy_uri="/comment/{commentId}">

  <cffunction name="get">
    <cfargument name="commentId" type="numeric" required="yes" />
	<cfset var local = StructNew()>
    <cfset local.data['comments'] = ArrayNew(1)>
	<cfset local.data['total'] = 0>
    <cfset local.data['viewcomment'] = 0>
    <cfif Val(arguments.commentId)>
      <cfset local.data['viewcomment'] = 1>
    </cfif>
    <CFQUERY NAME="local.qGetComment" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblComment
      WHERE Comment_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.commentId#"> AND Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"> 
    </CFQUERY>
    <cfif local.qGetComment.RecordCount>
      <cfset local.data['total'] = local.qGetComment.RecordCount>
      <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblUser 
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetComment.User_ID#">
      </CFQUERY>
      <cfset local.forename = "">
      <cfset local.surname = "">
      <cfset local.avatarSrc = "">
      <cfif local.qGetUser.RecordCount>
        <cfset local.forename = local.qGetUser.Forename>
        <cfset local.surname = local.qGetUser.Surname>
        <cfif Len(Trim(local.qGetUser.Filename))>
          <cfset local.avatarSrc = request.avatarbasesrc & local.qGetUser.Filename>
        </cfif>
      </cfif>
      <cfset local.obj = StructNew()>
      <cfset local.obj['commentid'] = local.qGetComment.Comment_ID>
      <cfset local.obj['fileid'] = local.qGetComment.File_ID>
      <cfset local.obj['fileUuid'] = local.qGetComment.File_uuid>
      <cfset local.obj['userid'] = local.qGetComment.User_ID>
      <cfset local.obj['comment'] = request.utils.FormatCommentOut(local.qGetComment.Comment)>
      <cfset local.obj['forename'] = local.forename>
      <cfset local.obj['surname'] = local.surname>
      <cfset local.obj['avatarSrc'] = local.avatarSrc>
      <cfset local.obj['token'] = local.qGetComment.Token>
      <cfset local.obj['replyToCommentid'] = local.qGetComment.Reply_to_comment_ID>
      <cfset local.obj['createdAt'] = local.qGetComment.Submission_date>
      <cfset ArrayAppend(local.data['comments'],local.obj)>
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

  <cffunction name="post" taffy_docs_hide>
	  <cfset var local = StructNew()>
      <cfset var emailtemplateheaderbackground = request.utils.getMaterialThemePrimaryColour(theme=request.theme)>
      <cfset var emailtemplatemessage = "">
      <cfset local.uploadfolder = request.uploadfolder>
      <cfset local.timestamp = DateFormat(Now(),'yyyymmdd') & TimeFormat(Now(),'HHmmss')>
      <cfset local.token = LCase(CreateUUID())>
      <cfset local.submissiondate = Now()>
      <cfset local.emailsubject = "Comment notification e-mail from " & request.title>
      <cfset local.jwtString = "">
      <cfset local.data = StructNew()>
	  <cfset local.data['commentid'] = 0>
      <cfset local.data['fileid'] = 0>
      <cfset local.data['fileUuid'] = "">
      <cfset local.data['userid'] = 0>
      <cfset local.data['comment'] = "">
      <cfset local.data['forename'] = "">
      <cfset local.data['surname'] = "">
      <cfset local.data['avatarSrc'] = "">
      <cfset local.data['token'] = "">
      <cfset local.data['replyToCommentid'] = 0>
      <cfset local.data['createdAt'] = "">
      <cfset local.data['emailSent'] = 0>
      <cfset local.data['userToken'] = "">
      <cfset local.data['jwtObj'] = StructNew()>
      <cfset local.data['error'] = "">
      <cfset local.data['hasProfanity'] = false>
      <cfset local.requestBody = getHttpRequestData().headers>
      <cftry>
		<cfif StructKeyExists(local.requestBody,"fileUuid")>
		  <cfset local.data['fileUuid'] = Trim(local.requestBody['fileUuid'])>
        </cfif>
        <cfif StructKeyExists(local.requestBody,"userid")>
		  <cfset local.data['userid'] = Trim(local.requestBody['userid'])>
        </cfif>
        <cfif StructKeyExists(local.requestBody,"comment")>
		  <cfset local.data['comment'] =  Trim(local.requestBody['comment'])>
        </cfif>
        <cfif StructKeyExists(local.requestBody,"replyToCommentid")>
		  <cfset local.data['replyToCommentid'] =  Trim(local.requestBody['replyToCommentid'])>
        </cfif>
        <cfif StructKeyExists(local.requestBody,"userToken")>
		  <cfset local.data['userToken'] =  Trim(local.requestBody['userToken'])>
        </cfif>
        <cfif StructKeyExists(local.requestBody,"Authorization")>
		  <cfset local.jwtString = request.utils.GetJwtString(Trim(local.requestBody['Authorization']))>
        </cfif>
        <cfcatch>
		  <cfset local.data['error'] = cfcatch.message>
        </cfcatch>
      </cftry>
      <cfset local.data['hasProfanity'] = request.utils.HasProfanity(string=local.data['comment'])>
      <cfif NOT local.data['hasProfanity']>
        <cfinclude template="../../../../jwt-decrypt.cfm">
        <cfif StructKeyExists(local.data['jwtObj'],"jwtAuthenticated") AND NOT local.data['jwtObj']['jwtAuthenticated']>
          <cfreturn representationOf(local.data).withStatus(403,"Not Authorized") />
        </cfif>
        <cfset local.emailpassword = Decrypt(request.emailPassword,request.emailSalt,request.crptographyalgorithm,request.crptographyencoding)>
        <CFQUERY NAME="local.qGetFile" DATASOURCE="#request.domain_dsn#">
          SELECT * 
          FROM tblFile 
          WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['fileUuid']#"> 
        </CFQUERY>
        <cfif local.qGetFile.RecordCount AND Len(Trim(local.data['comment']))>
          <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
            SELECT * 
            FROM tblUser 
            WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.data['userid']#">
          </CFQUERY>
          <cfif local.qGetUser.RecordCount>
            <CFQUERY DATASOURCE="#request.domain_dsn#" result="local.queryInsertResult">
              INSERT INTO tblComment (File_ID,File_uuid,User_ID,Comment,Token,Reply_to_comment_ID) 
              VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetFile.File_ID#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['fileUuid']#">,<cfqueryparam cfsqltype="cf_sql_integer" value="#local.data['userId']#">,<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#request.utils.CapFirstSentence(request.utils.FormatCommentIn(local.data['comment']),true)#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.token#">,<cfqueryparam cfsqltype="cf_sql_integer" value="#local.data['replyToCommentid']#">)
            </CFQUERY>
            <cfset local.data['error'] = "">
            <cfset local.data['commentid'] = local.queryInsertResult.generatedkey>
            <cfif NOT Val(local.data['replyToCommentid'])>
              <CFQUERY NAME="local.qUpdateComment" DATASOURCE="#request.domain_dsn#">
                UPDATE tblComment
                SET Reply_to_comment_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.data['commentid']#"> 
                WHERE Comment_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.data['commentid']#">
              </CFQUERY>
              <cfset local.data['replyToCommentid'] = local.data['commentid']>
            </cfif>
            <cfset local.data['fileid'] = local.qGetFile.File_ID>
            <CFQUERY NAME="local.qGetComment" DATASOURCE="#request.domain_dsn#">
              SELECT * 
              FROM tblComment
              WHERE Comment_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.data['commentid']#">
            </CFQUERY>
            <cfif local.qGetComment.RecordCount>
              <cfset local.data['comment'] =  request.utils.FormatCommentOut(local.qGetComment.Comment)>
            </cfif>
            <cfset local.data['forename'] = local.qGetUser.Forename>
            <cfset local.data['surname'] = local.qGetUser.Surname>
            <cfif Len(Trim(local.qGetUser.Filename))>
              <cfset local.data['avatarSrc'] = request.avatarbasesrc & local.qGetUser.Filename>
            <cfelse>  
              <cfset local.data['avatarSrc'] = "">
            </cfif>
            <cfset local.data['token'] = local.token>
            <cfset local.data['createdAt'] = local.submissiondate>
            <CFQUERY NAME="local.qGetFileAuthor" DATASOURCE="#request.domain_dsn#">
              SELECT * 
              FROM tblUser INNER JOIN tblFile ON tblUser.User_ID = tblFile.User_ID
              WHERE tblUser.User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetFile.User_ID#">
            </CFQUERY>
            <cfif local.qGetFileAuthor.RecordCount AND local.qGetUser.Email_notification AND Len(Trim(local.qGetFileAuthor.E_mail)) AND FindNoCase("@",local.qGetFileAuthor.E_mail)>
              <cfset local.salutation = request.utils.CapFirst(LCase(local.qGetFileAuthor.Forename))>
              <cfsavecontent variable="emailtemplatemessage">
                <cfoutput>
                  <h1>Hi<cfif Len(Trim(local.salutation))> #local.salutation#</cfif></h1>
                  <table cellpadding="0" cellspacing="0" border="0" width="100%">
                    <tr valign="middle">
                      <td width="10" bgcolor="##DDDDDD"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="10" height="1" /></td>
                      <td width="20"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="20" height="1" /></td>
                      <td style="font-size:16px;">
                        <strong>The following comment has been made about the photo entitled '#request.utils.FormatTitle(local.qGetFileAuthor.Title)#'</strong><br /><br />
                        #request.utils.CapFirstSentence(local.data['comment'],true)#
                      </td>
                    </tr>
                    <tr>
                      <td colspan="3">
                        <p><strong>Comment author:</strong></p>
                        #request.utils.CapFirst(LCase(local.qGetUser.Forename))# #request.utils.CapFirst(LCase(local.qGetUser.Surname))#<br />
                        <em>#DateFormat(local.submissiondate,"medium")# #TimeFormat(local.submissiondate,"medium")#</em>
                      </td>
                    </tr>
                    <tr>
                      <td colspan="3">
                        <p><strong>To view the comment, please follow the link below</strong></p>
                        <a href="#local.uploadfolder#/index.cfm?commentToken=#local.data['token']#">View Comment</a>
                      </td>
                    </tr>
                  </table>
                </cfoutput>
              </cfsavecontent>
              <cfmail to="#local.qGetFileAuthor.E_mail#" from="#request.email#" server="#request.emailServer#" username="#request.emailUsername#" password="#local.emailpassword#" port="#request.emailPort#" useSSL="#request.emailUseSsl#" useTLS="#request.emailUseTls#" subject="#local.emailsubject#" type="html">
                <cfinclude template="../../../../email-template.cfm">
              </cfmail>
              <cfset local.data['emailSent'] = 1>
            </cfif>
          <cfelse>
            <cfset local.data['error'] = "The user associated with this comment cannot be found">
          </cfif>
        <cfelse>
          <cfset local.data['error'] = "The file associated with this comment cannot be found">
        </cfif>
      </cfif>
      <cfreturn representationOf(local.data) />
  </cffunction>
  
  <cffunction name="delete">
    <cfargument name="commentId" type="numeric" required="yes" />
	<cfset var local = StructNew()>
    <cfset local.jwtString = "">
    <cfset local.data = StructNew()>
	<cfset local.data['commentid'] = arguments.commentId>
    <cfset local.data['userToken'] = "">
    <cfset local.data['jwtObj'] = StructNew()>
    <cfset local.data['error'] = "">
    <cfset local.requestBody = getHttpRequestData().headers>
    <cftry>
      <cfif StructKeyExists(local.requestBody,"userToken")>
        <cfset local.data['userToken'] =  Trim(local.requestBody['userToken'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"Authorization")>
        <cfset local.jwtString = request.utils.GetJwtString(Trim(local.requestBody['Authorization']))>
      </cfif>
      <cfcatch>
        <cfset local.data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
    <cfinclude template="../../../../jwt-decrypt.cfm">
	<cfif StructKeyExists(local.data['jwtObj'],"jwtAuthenticated") AND NOT local.data['jwtObj']['jwtAuthenticated']>
      <cfreturn representationOf(local.data).withStatus(403,"Not Authorized") />
    </cfif>
    <cftry>
      <cfif Val(arguments.commentId)>
        <CFQUERY DATASOURCE="#request.domain_dsn#">
          DELETE
          FROM tblComment
          WHERE Comment_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.commentId#"> 
        </CFQUERY>
        <CFQUERY DATASOURCE="#request.domain_dsn#">
          DELETE
          FROM tblComment
          WHERE Reply_to_comment_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.commentId#"> 
        </CFQUERY>
        <cfset local.data['error'] = "">
      </cfif>
      <cfcatch>
        <cfset local.data['error'] = "Record for this comment cannot be found">
      </cfcatch>
    </cftry>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>