
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type,Authorization,userToken" />

<cfparam name="uploadfolder" default="#request.uploadfolder#" />
<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="token" default="#LCase(CreateUUID())#" />
<cfparam name="submissiondate" default="#Now()#" />
<cfparam name="emailsubject" default="Comment notification e-mail from #request.title#" />
<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset emailtemplateheaderbackground = getMaterialThemePrimaryColour(theme=request.theme)>
<cfset emailtemplatemessage = "">

<cfset data = StructNew()>
<cfset data['commentid'] = 0>
<cfset data['fileid'] = 0>
<cfset data['fileUuid'] = "">
<cfset data['userid'] = 0>
<cfset data['comment'] = "">
<cfset data['forename'] = "">
<cfset data['surname'] = "">
<cfset data['avatarSrc'] = "">
<cfset data['token'] = "">
<cfset data['replyToCommentid'] = 0>
<cfset data['createdAt'] = "">
<cfset data['emailSent'] = 0>
<cfset data['error'] = "">

<cfset requestBody = toString(getHttpRequestData().content)>
<cfset requestBody = Trim(requestBody)>
<cftry>
  <cfset requestBody = DeserializeJSON(requestBody)>
  <cfif StructKeyExists(requestBody,"fileUuid")>
	<cfset data['fileUuid'] = Trim(requestBody['fileUuid'])>
  </cfif>
  <cfif StructKeyExists(requestBody,"userid")>
  	<cfset data['userid'] = Trim(requestBody['userid'])>
  </cfif>
  <cfif StructKeyExists(requestBody,"comment")>
  	<cfset data['comment'] =  Trim(requestBody['comment'])>
  </cfif>
  <cfif StructKeyExists(requestBody,"replyToCommentid")>
	<cfset data['replyToCommentid'] =  Trim(requestBody['replyToCommentid'])>
  </cfif>
  <cfcatch>
    <cftry>
      <cfset requestBody = REReplaceNoCase(requestBody,"[\s+]"," ","ALL")>
      <cfset requestBody = DeserializeJSON(requestBody)>
      <cfif StructKeyExists(requestBody,"fileUuid")>
		<cfset data['fileUuid'] = Trim(requestBody['fileUuid'])>
      </cfif>
      <cfif StructKeyExists(requestBody,"userid")>
        <cfset data['userid'] = Trim(requestBody['userid'])>
      </cfif>
      <cfif StructKeyExists(requestBody,"comment")>
        <cfset data['comment'] =  Trim(requestBody['comment'])>
      </cfif>
      <cfif StructKeyExists(requestBody,"replyToCommentid")>
        <cfset data['replyToCommentid'] =  Trim(requestBody['replyToCommentid'])>
      </cfif>
      <cfcatch>
		<cfset data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
  </cfcatch>
</cftry>

<cfset emailpassword = Decrypt(request.emailPassword,request.emailSalt,request.crptographyalgorithm,request.crptographyencoding)>

<CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblFile  
  WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['fileUuid']#"> 
</CFQUERY>
<cfif qGetFile.RecordCount AND Len(Trim(data['comment']))>
  <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
	SELECT * 
	FROM tblUser 
	WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['userid']#">
  </CFQUERY>
  <cfif qGetUser.RecordCount>
	<CFQUERY DATASOURCE="#request.domain_dsn#" result="queryInsertResult">
	  INSERT INTO tblComment (File_ID,File_uuid,User_ID,Comment,Token,Reply_to_comment_ID,Submission_date) 
	  VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#qGetFile.File_ID#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['fileUuid']#">,<cfqueryparam cfsqltype="cf_sql_integer" value="#data['userId']#">,<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#CapFirstSentence(FormatCommentIn(data['comment']),true)#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#token#">,<cfqueryparam cfsqltype="cf_sql_integer" value="#data['replyToCommentid']#">,<cfqueryparam cfsqltype="cf_sql_timestamp" value="#submissiondate#">)
	</CFQUERY>
	<cfset data['error'] = "">
	<cfset data['commentid'] = queryInsertResult.generatedkey>
	<cfif NOT Val(data['replyToCommentid'])>
	  <CFQUERY NAME="qUpdateComment" DATASOURCE="#request.domain_dsn#">
		UPDATE tblComment
		SET Reply_to_comment_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['commentid']#"> 
		WHERE Comment_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['commentid']#">
	  </CFQUERY>
	  <cfset data['replyToCommentid'] = data['commentid']>
	</cfif>
	<cfset data['fileid'] = qGetFile.File_ID>
	<CFQUERY NAME="qGetComment" DATASOURCE="#request.domain_dsn#">
	  SELECT * 
	  FROM tblComment
	  WHERE Comment_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['commentid']#">
	</CFQUERY>
	<cfif qGetComment.RecordCount>
	  <cfset data['comment'] =  FormatCommentOut(qGetComment.Comment)>
	</cfif>
	<cfset data['forename'] = qGetUser.Forename>
	<cfset data['surname'] = qGetUser.Surname>
	<cfif Len(Trim(qGetUser.Filename))>
	  <cfset data['avatarSrc'] = request.avatarbasesrc & qGetUser.Filename>
	<cfelse>  
	  <cfset data['avatarSrc'] = "">
	</cfif>
	<cfset data['token'] = token>
	<cfset data['createdAt'] = submissiondate>
	<CFQUERY NAME="qGetFileAuthor" DATASOURCE="#request.domain_dsn#">
	  SELECT * 
	  FROM tblUser INNER JOIN tblFile ON tblUser.User_ID = tblFile.User_ID
	  WHERE tblUser.User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetFile.User_ID#">
	</CFQUERY>
	<cfif qGetFileAuthor.RecordCount AND qGetUser.Email_notification AND Len(Trim(qGetFileAuthor.E_mail)) AND FindNoCase("@",qGetFileAuthor.E_mail)>
	  <cfset salutation = CapFirst(LCase(qGetFileAuthor.Forename))>
	  <cfsavecontent variable="emailtemplatemessage">
		<cfoutput>
		  <h1>Hi<cfif Len(Trim(salutation))> #salutation#</cfif></h1>
		  <table cellpadding="0" cellspacing="0" border="0" width="100%">
			<tr valign="middle">
			  <td width="10" bgcolor="##DDDDDD"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="10" height="1" /></td>
			  <td width="20"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="20" height="1" /></td>
			  <td style="font-size:16px;">
				<strong>The following comment has been made about the photo entitled '#qGetFileAuthor.Title#'</strong><br /><br />
				#CapFirstSentence(data['comment'],true)#
			  </td>
			</tr>
			<tr>
			  <td colspan="3">
				<p><strong>Comment author:</strong></p>
				#CapFirst(LCase(qGetUser.Forename))# #CapFirst(LCase(qGetUser.Surname))#<br />
				<em>#DateFormat(submissiondate,"medium")# #TimeFormat(submissiondate,"medium")#</em>
			  </td>
			</tr>
			<tr>
			  <td colspan="3">
				<p><strong>To view the comment, please follow the link below</strong></p>
				<a href="#uploadfolder#/index.cfm?commentToken=#data['token']#">View Comment</a>
			  </td>
			</tr>
		  </table>
		</cfoutput>
	  </cfsavecontent>
	  <cfmail to="#qGetFileAuthor.E_mail#" from="#request.email#" server="#request.emailServer#" username="#request.emailUsername#" password="#emailpassword#" port="#request.emailPort#" useSSL="#request.emailUseSsl#" useTLS="#request.emailUseTls#" subject="#emailsubject#" type="html">
		<cfinclude template="../email-template.cfm">
	  </cfmail>
	  <cfset data['emailSent'] = 1>
	</cfif>
  <cfelse>
	<cfset data['error'] = "The user associated with this comment cannot be found">
  </cfif>
<cfelse>
  <cfset data['error'] = "The file associated with this comment cannot be found">
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>