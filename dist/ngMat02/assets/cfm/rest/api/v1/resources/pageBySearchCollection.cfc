
<cfcomponent extends="taffy.core.resource" taffy_uri="/pages/search/{userToken}">

  <cffunction name="get">
    <cfargument name="userToken" type="string" required="yes" />
	<cfset var local = StructNew()>
    <cfset local.data = StructNew()>
    <cfset local.data['usertoken'] = arguments.userToken EQ 'empty' ? '' : arguments.userToken>
    <cfset local.data['term'] = "">
	<cfset local.data['pages'] = 0>
    <cfset local.requestBody = getHttpRequestData().headers>
    <cftry>
	  <cfif StructKeyExists(local.requestBody,"term")>
        <cfset local.data['term'] = Trim(local.requestBody['term'])>
      </cfif>
      <cfcatch>
		<cfset local.data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
    <cfif Len(Trim(local.data['usertoken']))>
      <CFQUERY NAME="local.qGetUserID" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblUserToken 
        WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['usertoken']#">
      </CFQUERY>
      <cfif local.qGetUserID.RecordCount>
        <CFQUERY NAME="local.qGetFiles" DATASOURCE="#request.domain_dsn#">
          SELECT * 
          FROM tblFile 
          WHERE (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(local.qGetUserID.User_ID)> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUserID.User_ID#">)</cfif>)<cfif Len(Trim(local.data['term']))> AND TRIM(Title) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#local.data['term']#%"></cfif>
        </CFQUERY>
        <cfif local.qGetFiles.RecordCount>
          <cfset local.data['pages'] = Ceiling(local.qGetFiles.RecordCount/request.filebatch)>
        </cfif>
      </cfif>
    <cfelse>
      <CFQUERY NAME="local.qGetFiles" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblFile 
        WHERE Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Len(Trim(local.data['term']))> AND TRIM(Title) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#local.data['term']#%"></cfif>
      </CFQUERY>
      <cfif local.qGetFiles.RecordCount>
        <cfset local.data['pages'] = Ceiling(local.qGetFiles.RecordCount/request.filebatch)>
      </cfif>
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>