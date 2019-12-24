
<cfcomponent extends="taffy.core.resource" taffy_uri="/amcharts/{page}" taffy_docs_hide>

  <cffunction name="get">
    <cfargument name="page" type="numeric" required="yes" />
	<cfset var local = StructNew()>
    <cfset local.startrow = 1>
    <cfset local.endrow = request.agGridTableBatch>
    <cfif Val(arguments.page) AND Val(request.agGridTableBatch)>
	  <cfif arguments.page GT 1>
        <cfset local.startrow = Int((arguments.page - 1) * request.agGridTableBatch) + 1>
        <cfset local.endrow = (local.startrow + request.agGridTableBatch) - 1>
      <cfelse>
        <cfset local.endrow = (local.startrow + request.agGridTableBatch) - 1>
      </cfif>
    </cfif>
    <cfset local.jwtString = "">
    <cfset local.data = StructNew()>
	<cfset local.data['rowData'] = ArrayNew(1)>
    <cfset local.data['task'] =  "">
    <cfset local.data['userToken'] =  "">
    <cfset local.data['jwtObj'] = StructNew()>
    <cfset local.data['error'] = "">
    <cfset local.requestBody = getHttpRequestData().headers>
    <cftry>
	  <cfif StructKeyExists(local.requestBody,"task")>
		<cfset local.data['task'] =  Trim(local.requestBody['task'])>
      </cfif>
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
    <cfswitch expression="#local.data['task']#">
      <cfcase value="userFile">
        <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
          SELECT COUNT(File_ID) AS countfileid, Surname, Forename, tblUser.User_ID 
          FROM tblUser INNER JOIN tblFile ON tblUser.User_ID = tblFile.User_ID 
          GROUP BY tblUser.User_ID 
          ORDER BY countfileid DESC
          LIMIT 10
        </CFQUERY>
        <cfif local.qGetUser.RecordCount>
          <cfloop query="local.qGetUser">
            <CFQUERY NAME="local.qGetApprovedCount" DATASOURCE="#request.domain_dsn#">
              SELECT COUNT(Approved) AS Approved  
              FROM tblUser INNER JOIN tblFile ON tblUser.User_ID = tblFile.User_ID 
              WHERE tblUser.User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUser.User_ID#"> AND Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1">
            </CFQUERY>
            <CFQUERY NAME="local.qGetFileCount" DATASOURCE="#request.domain_dsn#">
              SELECT * 
              FROM tblFile 
              WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUser.User_ID#"> 
            </CFQUERY>
            <cfif local.qGetApprovedCount.RecordCount>
			  <cfset local.obj = StructNew()>
              <cfset local.obj['name'] = local.qGetUser.Surname & ", " & local.qGetUser.Forename>
              <cfset local.obj['approved'] = local.qGetApprovedCount.Approved>
              <cfset local.obj['unapproved'] = (local.qGetFileCount.RecordCount - local.qGetApprovedCount.Approved)>
              <cfset ArrayAppend(local.data['rowData'],local.obj)>
            </cfif>
          </cfloop>
        <cfelse>
          <cfset local.data['error'] = "No users found">
        </cfif>
      </cfcase>
    </cfswitch>
    <!---<cfthread action="sleep" duration="15000" />--->
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>