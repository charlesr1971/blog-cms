
<cfcomponent extends="taffy.core.resource" taffy_uri="/pages/categories/{category}/{usertoken}">

  <cffunction name="get">
    <cfargument name="category" type="string" required="yes" />
    <cfargument name="usertoken" type="string" required="yes" />
	<cfset var local = StructNew()>
    <cfset local.data = StructNew()>
    <cfset local.data['category'] = arguments.category EQ 'empty' ? '' : arguments.category>
    <cfset local.data['usertoken'] = arguments.userToken EQ 'empty' ? '' : arguments.userToken>
	<cfset local.data['pages'] = 0>
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
          WHERE Category = <cfqueryparam cfsqltype="cf_sql_varchar" value="#LCase(Trim(URLDecode(arguments.category)))#"> AND (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(local.qGetUserID.User_ID)> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUserID.User_ID#">)</cfif>)
        </CFQUERY>
        <cfif local.qGetFiles.RecordCount>
          <cfset local.data['pages'] = Ceiling(local.qGetFiles.RecordCount/request.filebatch)>
        </cfif>
      </cfif>
    <cfelse>
      <CFQUERY NAME="local.qGetFiles" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblFile 
        WHERE Category = <cfqueryparam cfsqltype="cf_sql_varchar" value="#LCase(Trim(URLDecode(arguments.category)))#"> AND Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1">
      </CFQUERY>
      <cfif local.qGetFiles.RecordCount>
        <cfset local.data['pages'] = Ceiling(local.qGetFiles.RecordCount/request.filebatch)>
      </cfif>
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>