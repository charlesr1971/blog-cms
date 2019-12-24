
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type,Authorization,userToken" />

<cfparam name="userToken" default="" />

<cfparam name="uploadfolder" default="#request.uploadfolder#" />
<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset data = StructNew()>
<cfset data['userid'] = 0>
<cfset data['usertoken'] = userToken>
<cfset data['cookieAcceptance'] = 0>
<cfset data['error'] = "">

<CFQUERY NAME="qGetUserID" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblUserToken 
  WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['usertoken']#"> 
</CFQUERY>
<cfif qGetUserID.RecordCount>
  <cfset data['userid'] = qGetUserID.User_ID>
</cfif>
<CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblUser 
  WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['userid']#">
</CFQUERY>
<cfif qGetUser.RecordCount>
  <CFQUERY NAME="qUpdateUser" DATASOURCE="#request.domain_dsn#">
    UPDATE tblUser
    SET Cookie_acceptance =  <cfqueryparam cfsqltype="cf_sql_tinyint" value="1">
    WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['userid']#">
  </CFQUERY>
  <cfset data['cookieAcceptance'] = 1>
<cfelse>
  <cfset data['error'] = "User is not registered">
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>