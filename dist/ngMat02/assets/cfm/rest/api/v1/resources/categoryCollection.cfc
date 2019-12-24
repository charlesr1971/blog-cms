
<cfcomponent extends="taffy.core.resource" taffy_uri="/categories">

  <cffunction name="get">
	<cfset var local = StructNew()>
    <cfset local['userToken'] = "">
    <cfset local['userid'] = 0>
    <cfset local.data = StructNew()>
	<cfset local.data['categories'] = ArrayNew(1)>
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
    <CFQUERY NAME="local.qGetCategories" DATASOURCE="#request.domain_dsn#">
      SELECT Category  
      FROM tblFile 
      WHERE Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(local['userid'])> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local['userid']#">)</cfif>
      GROUP BY Category 
      ORDER BY Category ASC
    </CFQUERY>
    <cfif local.qGetCategories.RecordCount>
      <cfloop query="local.qGetCategories">
        <cfset local.obj = StructNew()>
        <cfset local.obj['category'] = local.qGetCategories.Category>
        <CFQUERY NAME="local.qGetFile" DATASOURCE="#request.domain_dsn#">
          SELECT * 
          FROM tblFile 
          WHERE Category = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.qGetCategories.Category#"> AND (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(local['userid'])> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local['userid']#">)</cfif>)
        </CFQUERY>
        <cfset local.obj['pages'] = Ceiling(local.qGetFile.RecordCount/request.filebatch)>
        <cfset ArrayAppend(local.data['categories'],local.obj)>
      </cfloop>
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>