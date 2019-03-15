
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type,Authorization,userToken" />

<cfparam name="usertoken" default="">
<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset data = StructNew()>
<cfset data['signUpValidated'] = 0>

<CFQUERY NAME="qGetUserID" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblUserToken 
  WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#usertoken#">
</CFQUERY>

<cfif qGetUserID.RecordCount>
  <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
    SELECT * 
    FROM tblUser 
    WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUserID.User_ID#"> AND SignUpValidated = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1">
  </CFQUERY>
  <cfif qGetUser.RecordCount>
	<cfset data['signUpValidated'] = 1>
  </cfif>
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>