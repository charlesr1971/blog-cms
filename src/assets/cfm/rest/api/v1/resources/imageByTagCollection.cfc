
<cfcomponent extends="taffy.core.resource" taffy_uri="/images/tag/{tag}/{page}">

  <cffunction name="get">
    <cfargument name="tag" type="string" required="yes" />
    <cfargument name="page" type="numeric" required="yes" />
	<cfset var local = StructNew()>
    <cfset local['userToken'] = "">
    <cfset local['userid'] = 0>
    <cfset local.data = ArrayNew(1)>
    <cfset local.query = QueryNew("User_ID,File_ID,Category,ImagePath,File_uuid,Author,Title,Description,Article,Size,Likes,Tags,Publish_article_date,Approved,Submission_date")>
    <cfset local.startrow = 1>
    <cfset local.endrow = request.filebatch>
    <cfif Val(arguments.page) AND Val(request.filebatch)>
	  <cfif arguments.page GT 1>
        <cfset local.startrow = Int((arguments.page - 1) * request.filebatch) + 1>
        <cfset local.endrow = (local.startrow + request.filebatch) - 1>
      <cfelse>
        <cfset local.endrow = (local.startrow + request.filebatch) - 1>
      </cfif>
    </cfif>
    <cfset local.requestBody = getHttpRequestData().headers>
    <cftry>
	  <cfif StructKeyExists(local.requestBody,"userToken")>
      	<cfset local['userToken'] = Trim(local.requestBody['userToken'])>
      </cfif>
      <cfcatch>
      </cfcatch>
    </cftry>
    <CFQUERY NAME="local.qGetUserID" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUserToken 
      WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local['userToken']#">
    </CFQUERY>
    <cfif local.qGetUserID.RecordCount>
	  <cfset local['userid'] = local.qGetUserID.User_ID>
    </cfif>
    <CFQUERY NAME="local.qGetFile" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblFile 
      WHERE Tags IS NOT NULL OR Tags <> <cfqueryparam cfsqltype="cf_sql_longvarchar" value=""> AND (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(local['userid'])> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local['userid']#">)</cfif>)
      ORDER BY Submission_date DESC
    </CFQUERY>
    <cfif local.qGetFile.RecordCount AND Len(Trim(URLDecode(arguments.tag)))>
      <cfloop query="local.qGetFile">
        <cfset local.tagList = request.utils.TagsToList(local.qGetFile.Tags)>
        <cfif ListFindNoCase(local.tagList,URLDecode(arguments.tag))>
          <cfset QueryAddRow(local.query)> 
          <cfset QuerySetCell(local.query,"User_ID",local.qGetFile.User_ID)> 
          <cfset QuerySetCell(local.query,"File_ID",local.qGetFile.File_ID)>
          <cfset QuerySetCell(local.query,"Category",local.qGetFile.Category)>
          <cfset QuerySetCell(local.query,"ImagePath",local.qGetFile.ImagePath)>
          <cfset QuerySetCell(local.query,"File_uuid",local.qGetFile.File_uuid)>
          <cfset QuerySetCell(local.query,"Author",local.qGetFile.Author)>
          <cfset QuerySetCell(local.query,"Title",local.qGetFile.Title)>
          <cfset QuerySetCell(local.query,"Description",local.qGetFile.Description)>
          <cfset QuerySetCell(local.query,"Article",local.qGetFile.Article)>
          <cfset QuerySetCell(local.query,"Size",local.qGetFile.Size)>
          <cfset QuerySetCell(local.query,"Likes",local.qGetFile.Likes)>
          <cfset QuerySetCell(local.query,"Tags",local.qGetFile.Tags)>
          <cfset QuerySetCell(local.query,"Publish_article_date",local.qGetFile.Publish_article_date)>
          <cfset QuerySetCell(local.query,"Approved",local.qGetFile.Approved)>
          <cfset QuerySetCell(local.query,"Submission_date",local.qGetFile.Submission_date)>
        </cfif>
      </cfloop>
    </cfif>
    <cfset local.qGetFile = local.query>
    <cfif local.qGetFile.RecordCount>
      <cfloop query="local.qGetFile" startrow="#local.startrow#" endrow="#local.endrow#">
        <cfset local.obj = StructNew()>
        <cfset local.obj['userid'] = local.qGetFile.User_ID>
        <cfset local.obj['fileid'] = local.qGetFile.File_ID>
        <cfset local.obj['category'] = local.qGetFile.Category>
        <cfset local.obj['src'] = local.qGetFile.ImagePath>
        <cfset local.obj['fileUuid'] = local.qGetFile.File_uuid>
        <cfset local.obj['author'] = request.utils.FormatTitle(local.qGetFile.Author)>
        <cfset local.obj['title'] = request.utils.FormatTitle(local.qGetFile.Title)>
        <cfset local.obj['description'] = local.qGetFile.Description>
        <cfset local.obj['article'] = local.qGetFile.Article>
        <cfset local.obj['size'] = local.qGetFile.Size>
        <cfset local.obj['likes'] = local.qGetFile.Likes>
        <cfset local.obj['tags'] = local.qGetFile.Tags>
        <cfset local.obj['publishArticleDate'] = local.qGetFile.Publish_article_date>
        <cfset local.obj['approved'] = local.qGetFile.Approved>
        <cfset local.obj['createdAt'] = local.qGetFile.Submission_date>
        <cfset ArrayAppend(local.data,local.obj)>
      </cfloop>
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>