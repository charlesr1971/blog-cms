
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="Authorization,userToken" />

<cfparam name="id" default="" />
<cfparam name="fileid" default="0" />
<cfparam name="commentid" default="0" />

<cfparam name="uploadfolder" default="#request.uploadfolder#" />
<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="userToken" default="" />
<cfparam name="userid" default="0" />
<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset data = StructNew()>
<cfset data['error'] = "">

<cfset requestBody = getHttpRequestData().headers>
<cftry>
  <cfif StructKeyExists(requestBody,"userToken")>
	<cfset userToken = Trim(requestBody['userToken'])>
  </cfif>
  <cfcatch>
  </cfcatch>
</cftry>

<CFQUERY NAME="qGetUserID" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblUserToken 
  WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#userToken#">
</CFQUERY>
<cfif qGetUserID.RecordCount>
  <cfset userid = qGetUserID.User_ID>
</cfif>

<CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblFile  
  WHERE <cfif NOT Val(fileid)>File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#id#"><cfelse>File_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#fileid#"></cfif> AND (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(userid)> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#">)</cfif>)
</CFQUERY>

<cfif qGetFile.RecordCount>
  <cfset data['userid'] = qGetFile.User_ID>
  <cfset data['fileid'] = qGetFile.File_ID>
  <cfset data['category'] = qGetFile.Category>
  <cfset data['src'] = qGetFile.ImagePath>
  <cfset data['fileUuid'] = qGetFile.File_uuid>
  <cfset data['author'] = FormatTitle(qGetFile.Author)>
  <cfset data['title'] = FormatTitle(qGetFile.Title)>
  <cfset data['description'] = qGetFile.Description>
  <cfset data['article'] = qGetFile.Article>
  <cfset data['size'] = qGetFile.Size>
  <cfset data['likes'] = qGetFile.Likes>
  <cfset data['imagePath'] = qGetFile.ImagePath>
  <cfset data['tags'] = qGetFile.Tags>
  <cfset data['commentid'] = commentid>
  <cfset data['publishArticleDate'] = qGetFile.Publish_article_date>
  <cfset data['approved'] = qGetFile.Approved>
  <cfdirectory action="list" directory="#request.filepath#\article-images\#qGetFile.File_ID#" name="qGetArticleImages" type="file" recurse="no" />
  <cfset data['tinymceArticleImageCount'] = qGetArticleImages.RecordCount>
  <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
    SELECT * 
    FROM tblUser 
    WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetFile.User_ID#">
  </CFQUERY>
  <cfif qGetUser.RecordCount>
	<cfset data['submitArticleNotification'] = qGetUser.Submit_article_notification>
  </cfif>
  <cfset data['createdAt'] = qGetFile.Submission_date>
<cfelse>
	<cfset data['error'] = "Record could not be found">
</cfif>

<cfset data = SerializeJSON(data)>

<cfoutput>
#data#
</cfoutput>