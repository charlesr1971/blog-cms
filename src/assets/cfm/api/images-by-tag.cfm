
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="Authorization,userToken" />

<cfparam name="page" default="1" />
<cfparam name="startrow" default="1" />
<cfparam name="endrow" default="#request.filebatch#" />

<cfparam name="tag" default="" />

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
<cfset query = QueryNew("User_ID,File_ID,Category,ImagePath,File_uuid,Author,Title,Description,Article,Size,Likes,Tags,Publish_article_date,Approved,Submission_date")>

<CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblFile  
  WHERE Tags IS NOT NULL OR Tags <> <cfqueryparam cfsqltype="cf_sql_longvarchar" value=""> AND (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(userid)> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#">)</cfif>)
  ORDER BY Submission_date DESC
</CFQUERY>

<cfset tag = URLDecode(tag)>

<cfif qGetFile.RecordCount AND Len(Trim(tag))>
  <cfloop query="qGetFile">
    <cfset tagList = TagsToList(qGetFile.Tags)>
    <cfif ListFindNoCase(tagList,tag)>
	  <cfset QueryAddRow(query)> 
      <cfset QuerySetCell(query,"User_ID",qGetFile.User_ID)> 
      <cfset QuerySetCell(query,"File_ID",qGetFile.File_ID)>
      <cfset QuerySetCell(query,"Category",qGetFile.Category)>
      <cfset QuerySetCell(query,"ImagePath",qGetFile.ImagePath)>
      <cfset QuerySetCell(query,"File_uuid",qGetFile.File_uuid)>
      <cfset QuerySetCell(query,"Author",qGetFile.Author)>
      <cfset QuerySetCell(query,"Title",qGetFile.Title)>
      <cfset QuerySetCell(query,"Description",qGetFile.Description)>
      <cfset QuerySetCell(query,"Article",qGetFile.Article)>
      <cfset QuerySetCell(query,"Size",qGetFile.Size)>
      <cfset QuerySetCell(query,"Likes",qGetFile.Likes)>
      <cfset QuerySetCell(query,"Tags",qGetFile.Tags)>
      <cfset QuerySetCell(query,"Publish_article_date",qGetFile.Publish_article_date)>
      <cfset QuerySetCell(query,"Approved",qGetFile.Approved)>
      <cfset QuerySetCell(query,"Submission_date",qGetFile.Submission_date)>
    </cfif>
  </cfloop>
</cfif>

<cfset qGetFile = query>

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