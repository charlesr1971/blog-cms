
<cfcomponent extends="taffy.core.resource" taffy_uri="/images/date/{year}/{month}/{page}">

  <cffunction name="get">
    <cfargument name="year" type="numeric" required="yes" />
    <cfargument name="month" type="numeric" required="yes" />
    <cfargument name="page" type="numeric" required="yes" />
	<cfset var local = StructNew()>
    <cfset local['userToken'] = "">
    <cfset local['userid'] = 0>
    <cfset local.data = ArrayNew(1)>
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
      WHERE YEAR(Submission_date) = #arguments.year# AND MONTH(Submission_date) = #arguments.month# AND (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(local['userid'])> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local['userid']#">)</cfif>)
      ORDER BY Submission_date DESC
    </CFQUERY>
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