
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="Authorization,userToken" />

<cfparam name="uploadfolder" default="#request.uploadfolder#" />
<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="userToken" default="" />
<cfparam name="userid" default="0" />
<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset requestBody = getHttpRequestData().headers>
<cftry>
  <cfif StructKeyExists(requestBody,"userToken")>
	<cfset userToken = Trim(requestBody['userToken'])>
  </cfif>
  <cfcatch>
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

<cfset data = StructNew()>
<cfset data['approved'] = true>

<cfif Len(Trim(userToken)) AND Val(userid)>

  <CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
    SELECT * 
    FROM tblFile 
    WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#"> AND Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> 
  </CFQUERY>
  
  <cfif qGetFile.RecordCount>
    <cfset data['approved'] = false>
  </cfif>

</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>