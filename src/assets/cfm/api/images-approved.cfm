
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="Authorization,userToken" />

<cfparam name="page" default="1" />
<cfparam name="startrow" default="1" />
<cfparam name="endrow" default="#request.filebatch#" />

<cfparam name="uploadfolder" default="#request.uploadfolder#" />
<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="userToken" default="" />
<cfparam name="userid" default="0" />
<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfif Val(page) AND Val(request.filebatch)>
  <cfif page GT 1>
    <cfset startrow = Int((page - 1) * request.filebatch) + 1>
    <cfset endrow = (startrow + request.filebatch) - 1>
  <cfelse>
	<cfset endrow = (startrow + request.filebatch) - 1>
  </cfif>
</cfif>

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

<cfset temp = ArrayNew(1)>

<CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblFile 
  WHERE Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#"> 
  ORDER BY Submission_date DESC
</CFQUERY>

<cfif qGetFile.RecordCount>
  <cfloop query="qGetFile" startrow="#startrow#" endrow="#endrow#">
    <cfset data = StructNew()>
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
    <cfset data['tags'] = qGetFile.Tags>
    <cfset data['publishArticleDate'] = qGetFile.Publish_article_date>
    <cfset data['approved'] = qGetFile.Approved>
    <cfset data['createdAt'] = qGetFile.Submission_date>
    <cfset ArrayAppend(temp,data)>
  </cfloop>
</cfif>

<cfset data = SerializeJSON(temp)>

<cfoutput>
#data#
</cfoutput>