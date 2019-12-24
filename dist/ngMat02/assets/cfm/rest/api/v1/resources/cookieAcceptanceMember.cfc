
<cfcomponent extends="taffy.core.resource" taffy_uri="/cookie/acceptance/{usertoken}" taffy_docs_hide>
  
  <cffunction name="put">
    <cfargument name="usertoken" type="string" required="yes" />
	<cfset var local = StructNew()>
    <cfset local.data = StructNew()>
    <cfset local.data['userid'] = 0>
    <cfset local.data['usertoken'] = arguments.usertoken EQ 'empty' ? '' : arguments.usertoken>
    <cfset local.data['cookieAcceptance'] = 0>
    <cfset local.data['error'] = "">
    <!---<cfdump var="#local.data#" output="C:\Users\Charles Robertson\Desktop\cfdump1.htm" format="html" />--->
    <!---<cfdump var="#getHttpRequestData().headers#" abort />--->
    <CFQUERY NAME="local.qGetUserID" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUserToken 
      WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['usertoken']#"> 
    </CFQUERY>
    <cfif local.qGetUserID.RecordCount>
	  <cfset local.data['userid'] = local.qGetUserID.User_ID>
    </cfif>
    <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUser 
      WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.data['userid']#">
    </CFQUERY>
    <cfif local.qGetUser.RecordCount>
      <CFQUERY DATASOURCE="#request.domain_dsn#">
        UPDATE tblUser
        SET Cookie_acceptance =  <cfqueryparam cfsqltype="cf_sql_tinyint" value="1">
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.data['userid']#">
      </CFQUERY>
      <cfset local.data['cookieAcceptance'] = 1>
    <cfelse>
      <cfset local.data['error'] = "User is not registered">
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>