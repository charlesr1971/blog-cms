
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type,Authorization,userToken" />

<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset data = StructNew()>
<cfset data['fileUuid'] = "">
<cfset data['likes'] = 0>
<cfset data['add'] = 0>
<cfset data['userToken'] = "">
<cfset data['error'] = "">
<cfset data['allowMultipleLikesPerUser'] = 0>

<cfset requestBody = toString(getHttpRequestData().content)>
<cfset requestBody = Trim(requestBody)>
<cftry>
  <cfset requestBody = DeserializeJSON(requestBody)>
  <cfif StructKeyExists(requestBody,"id")>
  	<cfset data['fileUuid'] = LCase(requestBody['id'])>
  </cfif>
  <cfif StructKeyExists(requestBody,"add")>
  	<cfset data['add'] = requestBody['add']>
  </cfif>
  <cfif StructKeyExists(requestBody,"userToken")>
  	<cfset data['userToken'] = LCase(requestBody['userToken'])>
  </cfif>
  <cfif StructKeyExists(requestBody,"allowMultipleLikesPerUser")>
  	<cfset data['allowMultipleLikesPerUser'] = requestBody['allowMultipleLikesPerUser']>
  </cfif>
  <cfcatch>
    <cftry>
      <cfset requestBody = REReplaceNoCase(requestBody,"[\s+]"," ","ALL")>
      <cfset requestBody = DeserializeJSON(requestBody)>
      <cfif StructKeyExists(requestBody,"id")>
		<cfset data['fileUuid'] = LCase(requestBody['id'])>
      </cfif>
      <cfif StructKeyExists(requestBody,"add")>
        <cfset data['add'] = requestBody['add']>
      </cfif>
      <cfif StructKeyExists(requestBody,"userToken")>
        <cfset data['userToken'] = LCase(requestBody['userToken'])>
      </cfif>
      <cfif StructKeyExists(requestBody,"allowMultipleLikesPerUser")>
        <cfset data['allowMultipleLikesPerUser'] = requestBody['allowMultipleLikesPerUser']>
      </cfif>
      <cfcatch>
		<cfset data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
  </cfcatch>
</cftry>

<cfif Val(data['add'])>
  <CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
    SELECT * 
    FROM tblFile  
    WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['fileUuid']#">
  </CFQUERY>
  <cfset allowMultipleLikesPerUser = true>
  <cfif Len(Trim(data['userToken'])) AND NOT data['allowMultipleLikesPerUser']>
    <CFQUERY NAME="qGetUserID" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUserToken 
      WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['userToken']#">
    </CFQUERY>
    <cfif qGetUserID.RecordCount>
      <CFQUERY NAME="qGetFileUser" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblFileUser
        WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['fileUuid']#"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUserID.User_ID#">
      </CFQUERY>
      <cfif qGetFileUser.RecordCount>
        <cfset allowMultipleLikesPerUser = false>
      </cfif>
    </cfif>
    <cfset data['error'] = "">
  </cfif>
  <cfif qGetFile.RecordCount AND allowMultipleLikesPerUser AND Len(Trim(data['userToken']))>
	<cfset likes = Val(qGetFile.Likes) + 1>
    <CFQUERY NAME="qUpdateFile" DATASOURCE="#request.domain_dsn#">
      UPDATE tblFile
      SET Likes = <cfqueryparam cfsqltype="cf_sql_integer" value="#likes#"> 
      WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['fileUuid']#">
    </CFQUERY>
    <CFQUERY NAME="qGetUserID" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUserToken 
      WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['userToken']#">
    </CFQUERY>
    <cfif qGetUserID.RecordCount>
      <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblUser
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUserID.User_ID#">
      </CFQUERY>
      <cfif qGetUser.RecordCount>
        <CFQUERY DATASOURCE="#request.domain_dsn#">
          INSERT INTO tblFileUser (User_ID,File_uuid) 
          VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['fileUuid']#">)
        </CFQUERY>
      </cfif>
    </cfif>
    <cfset data['error'] = "">
  <cfelse>
	<cfset data['error'] = "Like could not be added to the database">
  </cfif>
</cfif>

<CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblFile 
  WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['fileUuid']#">
</CFQUERY>
<cfif qGetFile.RecordCount>
  <cfset data['likes'] = qGetFile.Likes>
</cfif>

<cfset data = SerializeJSON(data)>

<cfoutput>
#data#
</cfoutput>