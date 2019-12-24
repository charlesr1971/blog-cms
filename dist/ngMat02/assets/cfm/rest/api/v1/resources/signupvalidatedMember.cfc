
<cfcomponent extends="taffy.core.resource" taffy_uri="/signupvalidated/{userToken}" taffy_docs_hide>

  <cffunction name="get">
    <cfargument name="userToken" type="string" required="yes" />
	<cfset var local = StructNew()>
    <cfset local.data = StructNew()>
	<cfset local.data['signUpValidated'] = 0>
    <CFQUERY NAME="local.qGetUserID" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUserToken 
      WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.usertoken#">
    </CFQUERY>
    <cfif local.qGetUserID.RecordCount>
      <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblUser 
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUserID.User_ID#"> AND SignUpValidated = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1">
      </CFQUERY>
      <cfif local.qGetUser.RecordCount>
        <cfset local.data['signUpValidated'] = 1>
      </cfif>
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>