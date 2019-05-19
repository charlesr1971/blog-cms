
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type,Authorization,userToken" />

<cfparam name="page" default="1" />
<cfparam name="startrow" default="1" />
<cfparam name="endrow" default="#request.agGridTableBatch#" />

<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset startrow = 1>
<cfset endrow = request.agGridTableBatch>
<cfif Val(page) AND Val(request.agGridTableBatch)>
  <cfif page GT 1>
	<cfset startrow = Int((page - 1) * request.agGridTableBatch) + 1>
	<cfset endrow = (startrow + request.agGridTableBatch) - 1>
  <cfelse>
	<cfset endrow = (startrow + request.agGridTableBatch) - 1>
  </cfif>
</cfif>

<cfset data = StructNew()>
<cfset data['rowData'] = ArrayNew(1)>
<cfset data['task'] =  "">
<cfset data['userToken'] =  "">
<cfset data['error'] = "">

<cfset requestBody = toString(getHttpRequestData().content)>
<cfset requestBody = Trim(requestBody)>
<cftry>
  <cfset requestBody = DeserializeJSON(requestBody)>
  <cfif StructKeyExists(requestBody,"task")>
	<cfset data['task'] = requestBody['task']>
  </cfif>
  <cfcatch>
    <cftry>
      <cfset requestBody = REReplaceNoCase(requestBody,"[\s+]"," ","ALL")>
      <cfset requestBody = DeserializeJSON(requestBody)>
      <cfif StructKeyExists(requestBody,"task")>
		<cfset data['task'] = requestBody['task']>
      </cfif>
      <cfcatch>
		<cfset data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
  </cfcatch>
</cftry>

<cfset requestBody = getHttpRequestData().headers>
<cftry>
  <cfif StructKeyExists(requestBody,"userToken")>
	<cfset data['userToken'] = Trim(requestBody['userToken'])>
  </cfif>
  <cfcatch>
	<cfset data['error'] = cfcatch.message>
  </cfcatch>
</cftry>

<cfswitch expression="#data['task']#">
  <cfcase value="userFile">
    <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
      SELECT COUNT(File_ID) AS countfileid, Surname, Forename, tblUser.User_ID 
      FROM tblUser INNER JOIN tblFile ON tblUser.User_ID = tblFile.User_ID 
      GROUP BY tblUser.User_ID 
      ORDER BY countfileid DESC
      LIMIT 10
    </CFQUERY>
    <cfif qGetUser.RecordCount>
      <cfloop query="qGetUser">
        <CFQUERY NAME="qGetApprovedCount" DATASOURCE="#request.domain_dsn#">
          SELECT COUNT(Approved) AS Approved  
          FROM tblUser INNER JOIN tblFile ON tblUser.User_ID = tblFile.User_ID 
          WHERE tblUser.User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#"> AND Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1">
        </CFQUERY>
        <CFQUERY NAME="qGetFileCount" DATASOURCE="#request.domain_dsn#">
          SELECT * 
          FROM tblFile 
          WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#"> 
        </CFQUERY>
        <cfif qGetApprovedCount.RecordCount>
          <cfset obj = StructNew()>
          <cfset obj['name'] = qGetUser.Surname & ", " & qGetUser.Forename>
          <cfset obj['approved'] = qGetApprovedCount.Approved>
          <cfset obj['unapproved'] = (qGetFileCount.RecordCount - qGetApprovedCount.Approved)>
          <cfset ArrayAppend(data['rowData'],obj)>
        </cfif>
      </cfloop>
    <cfelse>
      <cfset data['error'] = "No users found">
    </cfif>
  </cfcase>
</cfswitch>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>