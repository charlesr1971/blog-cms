
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="Authorization,userToken" />

<cfparam name="uploadfolder" default="#request.uploadfolder#" />
<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="userToken" default="" />
<cfparam name="userid" default="0" />
<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset data = StructNew()>
<cfset data['dates'] = ArrayNew(1)>

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
  SELECT Submission_date  
  FROM tblFile 
  WHERE Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(userid)> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#">)</cfif>
  GROUP BY YEAR(Submission_date), MONTH(Submission_date) 
  ORDER BY Submission_date DESC
</CFQUERY>

<cfif qGetCategories.RecordCount>
  <cfloop query="qGetCategories">
    <cfset obj = StructNew()>
    <cfset obj['date'] = qGetCategories.Submission_date>
    <cfset obj['year'] = Year(qGetCategories.Submission_date)>
    <cfset obj['month'] = Month(qGetCategories.Submission_date)>
    <CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblFile 
      WHERE YEAR(Submission_date) = #Year(qGetCategories.Submission_date)# AND MONTH(Submission_date) = #Month(qGetCategories.Submission_date)# AND (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(userid)> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#">)</cfif>)
    </CFQUERY>
    <cfset obj['pages'] = Ceiling(qGetFile.RecordCount/request.filebatch)>
    <cfset ArrayAppend(data['dates'],obj)>
  </cfloop>
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>