
<cfcomponent extends="taffy.core.resource" taffy_uri="/users/archive">

  <cffunction name="get">
	<cfset var local = StructNew()>
    <cfset local.jwtString = "">
    <cfset local.data = StructNew()>
    <cfset local.data['columnDefs'] = ArrayNew(1)>
	<cfset local.data['rowData'] = ArrayNew(1)>
    <cfset local.data['userToken'] =  "">
    <cfset local.data['jwtObj'] = StructNew()>
    <cfset local.data['error'] = "">
    <cfset local.requestBody = getHttpRequestData().headers>
    <cftry>
	  <cfif StructKeyExists(local.requestBody,"userToken")>
		<cfset local.data['userToken'] =  Trim(local.requestBody['userToken'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"Authorization")>
        <cfset local.jwtString = request.utils.GetJwtString(Trim(local.requestBody['Authorization']))>
      </cfif>
      <cfcatch>
		<cfset local.data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
    <cfinclude template="../../../../jwt-decrypt.cfm">
	<cfif StructKeyExists(local.data['jwtObj'],"jwtAuthenticated") AND NOT local.data['jwtObj']['jwtAuthenticated']>
      <cfreturn representationOf(local.data).withStatus(403,"Not Authorized") />
    </cfif>
    <!---User_ID
    Role_ID
    Salt
    Password
    E_mail
    Forename
    Surname
    Cfid
    Cftoken
    SignUpToken
    SignUpValidated
    Clientfilename
    Filename
    Email_notification
    Keep_logged_in
    Submit_article_notification
    Cookie_acceptance
    Theme
    Submission_date
    Submission_date--->
    <cfset local.columnOrder = "Surname,Forename,E_mail,Role_ID,Submission_date">
    <CFQUERY NAME="local.qGetUserArchive" DATASOURCE="#request.domain_dsn#">
      SELECT Surname, Forename ,E_mail, Role_ID, Submission_date 
      FROM tblUserArchive 
      ORDER BY Surname ASC
    </CFQUERY>
    <cfif local.qGetUserArchive.RecordCount>
	  <cfset local.columns = local.qGetUserArchive.columnList>
      <cfloop list="#local.columns#" index="local.column">
		<cfset local.obj = StructNew()>
        <cfset local.columnName = ReplaceNoCase(Trim(LCase(column)),"_"," ","ALL")>
        <cfset local.obj['headerName'] = request.utils.CapFirstAll(str=local.columnName)>
        <cfset local.obj['field'] = local.column>
        <cfset ArrayAppend(local.data['columnDefs'],local.obj)>
      </cfloop>
      <cfset local.data['rowData'] = request.utils.QueryToArray(query=local.qGetUserArchive)>
    <cfelse>
	  <cfset local.data['error'] = "No archived users found">
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>