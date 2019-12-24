
<cfcomponent extends="taffy.core.resource" taffy_uri="/theme/{usertoken}">
  
  <cffunction name="put">
    <cfargument name="usertoken" type="string" required="yes" />
	<cfset var local = StructNew()>
    <cfset local.themeObj = request.utils.createTheme(request.theme)>
    <cfset local.jwtString = "">
    <cfset local.data = StructNew()>
	<cfset local.data['userid'] = 0>
    <cfset local.data['usertoken'] = arguments.usertoken EQ 'empty' ? '' : arguments.usertoken>
    <cfset local.data['theme'] = local.themeObj['default']>
    <cfset local.data['jwtObj'] = StructNew()>
    <cfset local.data['error'] = "">
    <cfset local.requestBody = getHttpRequestData().headers>
    <cftry>
      <cfif StructKeyExists(local.requestBody,"theme")>
      	<cfset local.data['theme'] = Trim(local.requestBody['theme'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"Authorization")>
        <cfset local.jwtString = request.utils.GetJwtString(Trim(local.requestBody['Authorization']))>
      </cfif>
      <cfcatch>
		<cfset local.data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
    <!---<cfdump var="#local.data#" output="C:\Users\Charles Robertson\Desktop\cfdump1.htm" format="html" />--->
    <!---<cfdump var="#getHttpRequestData().headers#" abort />--->
    <cfinclude template="../../../../jwt-decrypt.cfm">
	<cfif StructKeyExists(local.data['jwtObj'],"jwtAuthenticated") AND NOT local.data['jwtObj']['jwtAuthenticated']>
      <cfreturn representationOf(local.data).withStatus(403,"Not Authorized") />
    </cfif>
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
        SET Theme = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ListLast(local.data['theme'],'-')#"> 
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.data['userid']#">
      </CFQUERY>
      <cfset local.data['error'] = "">
    <cfelse>
      <cfset local.data['error'] = "User is not registered">
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>