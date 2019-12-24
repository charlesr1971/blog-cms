
<cfcomponent extends="taffy.core.resource" taffy_uri="/pages/tag/{tag}">

  <cffunction name="get">
    <cfargument name="tag" type="string" required="yes" />
	<cfset var local = StructNew()>
    <cfset local['userToken'] = "">
    <cfset local['userid'] = 0>
    <cfset local.data['pages'] = 0>
	<cfset local.query = QueryNew("User_ID")>
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
    </CFQUERY>
    <cfif local.qGetFile.RecordCount AND Len(Trim(URLDecode(arguments.tag)))>
      <cfloop query="local.qGetFile">
        <cfset local.tagList = request.utils.TagsToList(local.qGetFile.Tags)>
        <cfif ListFindNoCase(local.tagList,URLDecode(arguments.tag))>
          <cfset QueryAddRow(local.query)> 
          <cfset QuerySetCell(local.query,"User_ID",local.qGetFile.User_ID)> 
        </cfif>
      </cfloop>
    </cfif>
    <cfset local.qGetFile = local.query>
    <cfif local.qGetFile.RecordCount>
      <cfset local.data['pages'] = Ceiling(local.qGetFile.RecordCount/request.filebatch)>
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>