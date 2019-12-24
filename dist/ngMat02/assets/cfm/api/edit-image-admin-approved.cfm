
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />

<cfheader name="Access-Control-Allow-Headers" value="content-type,Authorization,userToken" />

<cfparam name="fileUuid" default="" />
<cfparam name="approved" default="" />
<cfparam name="roleid" default="0" />
<cfparam name="isAdmin" default="false" />
<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset data = StructNew()>
<cfset data['fileUuid'] = Trim(LCase(fileUuid))>
<cfset data['approved'] = approved>
<cfset data['userToken'] = "">
<cfset data['jwtObj'] = StructNew()>
<cfset data['error'] = "">

<cfset requestBody = getHttpRequestData().headers>
<cftry>
  <cfif StructKeyExists(requestBody,"userToken")>
	<cfset userToken = Trim(requestBody['userToken'])>
  </cfif>
  <cfcatch>
	<cfset data['error'] = cfcatch.message>
  </cfcatch>
</cftry>

<CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblFile 
  WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['fileUuid']#"> 
</CFQUERY>
<CFQUERY NAME="qGetUserTokenRoleId" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblUser INNER JOIN tblUsertoken ON tblUser.User_ID = tblUsertoken.User_ID
  WHERE tblUsertoken.User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['userToken']#">
</CFQUERY>
<cfif qGetUserTokenRoleId.RecordCount AND qGetUserTokenRoleId.Role_ID GTE 6>
  <cfset isAdmin = true>
</cfif> 
<cfif qGetFile.RecordCount AND isAdmin AND ISNUMERIC(data['approved'])>
  <CFQUERY DATASOURCE="#request.domain_dsn#">
    UPDATE tblFile
    SET Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#data['approved']#"> 
    WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['fileUuid']#"> 
  </CFQUERY>
<cfelse>
  <cfset data['error'] = "Permission denied">
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>