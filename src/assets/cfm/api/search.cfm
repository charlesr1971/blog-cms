
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type,Authorization,userToken" />

<cfparam name="page" default="1" />
<cfparam name="startrow" default="1" />
<cfparam name="endrow" default="#request.filebatch#" />

<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="userToken" default="" />
<cfparam name="userid" default="0" />
<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset data = StructNew()>
<cfset data['term'] = "">
<cfset data['titles'] = ArrayNew(1)>
<cfset data['page'] = 1>
<cfset data['error'] = "">

<cfset requestBody = toString(getHttpRequestData().content)>

<cfset requestBody = Trim(requestBody)>
<cftry>
  <cfset requestBody = DeserializeJSON(requestBody)>
  <cfif StructKeyExists(requestBody,"term")>
  	<cfset data['term'] = Trim(requestBody['term'])>
  </cfif>
  <cfif StructKeyExists(requestBody,"page")>
  	<cfset data['page'] = Trim(requestBody['page'])>
  </cfif>
  <cfcatch>
    <cftry>
      <cfset requestBody = REReplaceNoCase(requestBody,"[\s+]"," ","ALL")>
      <cfset requestBody = DeserializeJSON(requestBody)>
      <cfif StructKeyExists(requestBody,"term")>
		<cfset data['term'] = Trim(requestBody['term'])>
      </cfif>
      <cfif StructKeyExists(requestBody,"page")>
        <cfset data['page'] = Trim(requestBody['page'])>
      </cfif>
      <cfcatch>
		<cfset data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
  </cfcatch>
</cftry>

<cfset page = data['page']>

<cfif Val(page) AND Val(request.filebatch)>
  <cfif page GT 1>
    <cfset startrow = Int((page - 1) * request.filebatch) + 1>
    <cfset endrow = (startrow + request.filebatch) - 1>
  <cfelse>
	<cfset endrow = (startrow + request.filebatch) - 1>
  </cfif>
</cfif>

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

<CFQUERY NAME="qGetFileTitles" DATASOURCE="#request.domain_dsn#">
  SELECT File_ID, File_uuid, Title, ImagePath 
  FROM tblFile
  WHERE (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(userid)> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#">)</cfif>)<cfif Len(Trim(data['term']))> AND TRIM(Title) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#data['term']#%"></cfif>
  ORDER BY TRIM(Title) ASC
</CFQUERY>

<cfif qGetFileTitles.RecordCount>
  <cfloop query="qGetFileTitles" startrow="#startrow#" endrow="#endrow#">
	<cfset obj = StructNew()>
    <cfset obj['fileid'] = qGetFileTitles.File_ID>
    <cfset obj['title'] = qGetFileTitles.Title>
    <cfset directory = ListDeleteAt(qGetFileTitles.ImagePath,ListLen(qGetFileTitles.ImagePath,"/"),"/")>
    <cfset obj['directory'] = directory>
    <cfset obj['fileUuid'] = qGetFileTitles.File_uuid>
    <cfset ArrayAppend(data['titles'],obj)>
  </cfloop>
  <cfset data['error'] = "">
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>