
<cfcomponent extends="taffy.core.resource" taffy_uri="/image/admin/approved/{fileUuid}/{approved}" taffy_docs_hide>

  <cffunction name="put">
    <cfargument name="fileUuid" type="string" required="yes" />
    <cfargument name="approved" type="numeric" required="yes" />
    <cfset var local = StructNew()>
    <cfset local.roleid = 0>
    <cfset local.jwtString = "">
    <cfset local.isAdmin = false>
    <cfset local.data = StructNew()>
	<cfset local.data['fileUuid'] = Trim(LCase(arguments.fileUuid))>
    <cfset local.data['approved'] = arguments.approved>
    <cfset local.data['userToken'] = "">
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
    <CFQUERY NAME="local.qGetFile" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblFile 
      WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['fileUuid']#"> 
    </CFQUERY>
    <CFQUERY NAME="local.qGetUserTokenRoleId" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUser INNER JOIN tblUsertoken ON tblUser.User_ID = tblUsertoken.User_ID
      WHERE tblUsertoken.User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['userToken']#">
    </CFQUERY>
    <cfif local.qGetUserTokenRoleId.RecordCount AND local.qGetUserTokenRoleId.Role_ID GTE 6>
      <cfset local.isAdmin = true>
    </cfif> 
    <cfif local.qGetFile.RecordCount AND local.isAdmin AND ISNUMERIC(local.data['approved'])>
      <CFQUERY DATASOURCE="#request.domain_dsn#">
        UPDATE tblFile
        SET Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#local.data['approved']#"> 
        WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['fileUuid']#"> 
      </CFQUERY>
    <cfelse>
	  <cfset local.data['error'] = "Permission denied">
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>