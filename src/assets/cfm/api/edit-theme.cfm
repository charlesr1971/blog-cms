
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type,theme,Authorization,userToken" />

<cfparam name="uploadfolder" default="#request.uploadfolder#" />
<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="userToken" default="" />
<cfparam name="userid" default="0" />
<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset themeObj = createTheme(request.theme)>

<cfset data = StructNew()>
<cfset data['theme'] = themeObj['default']>
<cfset data['error'] = "">

<cfset requestBody = toString(getHttpRequestData().content)>
<cfset requestBody = Trim(requestBody)>
<cftry>
  <cfset requestBody = DeserializeJSON(requestBody)>
  <cfif StructKeyExists(requestBody,"theme")>
  	<cfset data['theme'] = Trim(requestBody['theme'])>
  </cfif>
  <cfcatch>
    <cftry>
      <cfset requestBody = REReplaceNoCase(requestBody,"[\s+]"," ","ALL")>
      <cfset requestBody = DeserializeJSON(requestBody)>
      <cfif StructKeyExists(requestBody,"theme")>
		<cfset data['theme'] = Trim(requestBody['theme'])>
      </cfif>
      <cfcatch>
		<cfset data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
  </cfcatch>
</cftry>

<CFQUERY NAME="qGetUserID" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblUserToken 
  WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#userToken#">
</CFQUERY>
<cfif qGetUserID.RecordCount>
  <cfset userid = qGetUserID.User_ID>
</cfif>

<CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblUser 
  WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#">
</CFQUERY>
<cfif qGetUser.RecordCount>
  <CFQUERY NAME="qUpdateUser" DATASOURCE="#request.domain_dsn#">
    UPDATE tblUser
    SET Theme =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#ListLast(data['theme'],'-')#">
    WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#">
  </CFQUERY>
  <cfset data['error'] = "">
<cfelse>
  <cfset data['error'] = "User is not registered">
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>