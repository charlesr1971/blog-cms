
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="Authorization,userToken" />

<cfparam name="uploadfolder" default="#request.uploadfolder#" />
<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="userToken" default="" />
<cfparam name="userid" default="0" />
<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset data = StructNew()>
<cfset data['categories'] = ArrayNew(1)>

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

<CFQUERY NAME="qGetCategories" DATASOURCE="#request.domain_dsn#">
  SELECT Category  
  FROM tblFile 
  WHERE Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(userid)> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#">)</cfif>
  GROUP BY Category 
  ORDER BY Category ASC
</CFQUERY>

<cfif qGetCategories.RecordCount>
  <cfloop query="qGetCategories">
    <cfset obj = StructNew()>
    <cfset obj['category'] = qGetCategories.Category>
    <CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblFile  
      WHERE Category = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetCategories.Category#"> AND (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(userid)> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#">)</cfif>)
    </CFQUERY>
    <cfset obj['pages'] = Ceiling(qGetFile.RecordCount/request.filebatch)>
    <cfset ArrayAppend(data['categories'],obj)>
  </cfloop>
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>