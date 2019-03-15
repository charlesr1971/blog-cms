
<cfcomponent extends="taffy.core.resource" taffy_uri="/search/{page}">

  <cffunction name="get">
    <cfargument name="page" type="numeric" required="yes" />
	<cfset var local = StructNew()>
    <cfset local['userToken'] = "">
    <cfset local['userid'] = 0>
    <cfset local.data = StructNew()>
    <cfset local.startrow = 1>
    <cfset local.endrow = request.filebatch>
    <cfset local.data['term'] = "">
	<cfset local.data['titles'] = ArrayNew(1)>
    <cfset local.data['page'] = arguments.page>
    <cfset local.data['error'] = "">
    <cfset local.requestBody = getHttpRequestData().headers>
    <cftry>
	  <cfif StructKeyExists(local.requestBody,"term")>
        <cfset local.data['term'] = Trim(local.requestBody['term'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"userToken")>
      	<cfset local['userToken'] = Trim(local.requestBody['userToken'])>
      </cfif>
      <cfcatch>
		<cfset local.data['error'] = cfcatch.message>
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
    <cfset local.page = local.data['page']>
    <cfif Val(local.page) AND Val(request.filebatch)>
      <cfif local.page GT 1>
        <cfset startrow = Int((local.page - 1) * request.filebatch) + 1>
        <cfset endrow = (startrow + request.filebatch) - 1>
      <cfelse>
        <cfset endrow = (startrow + request.filebatch) - 1>
      </cfif>
    </cfif>
    <CFQUERY NAME="local.qGetFileTitles" DATASOURCE="#request.domain_dsn#">
      SELECT File_ID, File_uuid, Title, ImagePath 
      FROM tblFile
      WHERE (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(local['userid'])> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local['userid']#">)</cfif>)<cfif Len(Trim(local.data['term']))> AND TRIM(Title) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#local.data['term']#%"></cfif>
      ORDER BY TRIM(Title) ASC
    </CFQUERY>
    <cfif local.qGetFileTitles.RecordCount>
      <cfloop query="local.qGetFileTitles" startrow="#startrow#" endrow="#endrow#">
        <cfset local.obj = StructNew()>
        <cfset local.obj['fileid'] = local.qGetFileTitles.File_ID>
        <cfset local.obj['title'] = local.qGetFileTitles.Title>
        <cfset local.directory = ListDeleteAt(local.qGetFileTitles.ImagePath,ListLen(local.qGetFileTitles.ImagePath,"/"),"/")>
        <cfset local.obj['directory'] = local.directory>
        <cfset local.obj['fileUuid'] = local.qGetFileTitles.File_uuid>
        <cfset ArrayAppend(local.data['titles'],local.obj)>
      </cfloop>
      <cfset local.data['error'] = "">
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>