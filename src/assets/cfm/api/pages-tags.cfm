
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="Authorization,userToken" />

<cfparam name="tag" default="" />

<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="userToken" default="" />
<cfparam name="userid" default="0" />
<cfparam name="data" default="#StructNew()#" />

<cfinclude template="../functions.cfm">

<cfset data['pages'] = 0>

<cfset query = QueryNew("User_ID")>

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

<CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblFile 
  WHERE Tags IS NOT NULL OR Tags <> <cfqueryparam cfsqltype="cf_sql_longvarchar" value=""> AND (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(userid)> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#">)</cfif>)
</CFQUERY>

<cfset tag = URLDecode(tag)>

<cfif qGetFile.RecordCount AND Len(Trim(tag))>
  <cfloop query="qGetFile">
    <cfset tagList = TagsToList(qGetFile.Tags)>
    <cfif ListFindNoCase(tagList,tag)>
	  <cfset QueryAddRow(query)> 
      <cfset QuerySetCell(query,"User_ID",qGetFile.User_ID)> 
    </cfif>
  </cfloop>
</cfif>

<cfset qGetFile = query>

<cfif qGetFile.RecordCount>
  <cfset data['pages'] = Ceiling(qGetFile.RecordCount/request.filebatch)>
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>