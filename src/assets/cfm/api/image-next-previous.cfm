
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="Authorization,userToken" />

<cfparam name="id" default="" />
<cfparam name="direction" default="" />
<cfparam name="userid" default="0" />

<cfparam name="uploadfolder" default="#request.uploadfolder#" />
<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="userToken" default="" />
<cfparam name="userid" default="0" />
<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset data = StructNew()>
<cfset data['id'] = id>
<cfset data['direction'] = direction>

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
  
<CFQUERY NAME="qGetNextPreviousFile" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblFile   
  WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#"> AND (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(userid)> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#">)</cfif>)
</CFQUERY>

<cfif qGetNextPreviousFile.RecordCount AND Len(Trim(direction))>
  <cfloop query="qGetNextPreviousFile">
    <cfif CompareNoCase(qGetNextPreviousFile.File_uuid,id) EQ 0>
      <cfif CompareNoCase(direction,"next") EQ 0>
        <cfset row = qGetNextPreviousFile.CurrentRow + 1>
      <cfelse>
        <cfset row = qGetNextPreviousFile.CurrentRow - 1>
      </cfif>
      <cfif row EQ (qGetNextPreviousFile.RecordCount + 1) AND CompareNoCase(direction,"next") EQ 0>
        <cfset row = 1>
      </cfif>
      <cfif row LTE 0 AND CompareNoCase(direction,"previous") EQ 0>
        <cfset row = qGetNextPreviousFile.RecordCount>
      </cfif>
      <cfif row GT 0> 
        <cfset data['fileUuid'] = qGetNextPreviousFile['File_uuid'][row]>
      </cfif>
    </cfif>
  </cfloop>
</cfif>

<cfset data = SerializeJSON(data)>

<cfoutput>
#data#
</cfoutput>