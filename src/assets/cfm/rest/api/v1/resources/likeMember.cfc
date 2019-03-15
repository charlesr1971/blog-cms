
<cfcomponent extends="taffy.core.resource" taffy_uri="/like/{fileUuid}/{add}/{allowMultipleLikesPerUser}">

  <cffunction name="post">
    <cfargument name="fileUuid" type="string" required="yes" />
    <cfargument name="add" type="numeric" required="yes" hint="tinyInt" />
    <cfargument name="allowMultipleLikesPerUser" type="numeric" required="yes" hint="tinyInt" />
    <cfset var local = StructNew()>
    <cfset local.jwtString = "">
    <cfset local.data = StructNew()>
    <cfset local.data['fileUuid'] = arguments.fileUuid>
    <cfset local.data['userToken'] = "">
    <cfset local.data['add'] = arguments.add>
    <cfset local.data['allowMultipleLikesPerUser'] = request.allowMultipleLikesPerUser EQ -1 ? arguments.allowMultipleLikesPerUser : request.allowMultipleLikesPerUser>
    <cfset local.data['likes'] = 0>
    <cfset local.data['jwtObj'] = StructNew()>
    <cfset local.data['error'] = "">
    <cfset local.requestBody = getHttpRequestData().headers>
    <cftry>
	  <cfif StructKeyExists(local.requestBody,"userToken")>
		<cfset local.data['userToken'] = Trim(local.requestBody['userToken'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"Authorization")>
        <cfset local.jwtString = request.utils.GetJwtString(Trim(local.requestBody['Authorization']))>
      </cfif>
      <cfcatch>
		<cfset local.data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
    <cfif Val(local.data['add'])>
      <cfinclude template="../../../../jwt-decrypt.cfm">
      <cfif StructKeyExists(local.data['jwtObj'],"jwtAuthenticated") AND NOT local.data['jwtObj']['jwtAuthenticated']>
        <cfreturn representationOf(local.data).withStatus(403,"Not Authorized") />
      </cfif>
      <CFQUERY NAME="local.qGetFile" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblFile 
        WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['fileUuid']#">
      </CFQUERY>
      <cfset local.allowMultipleLikesPerUser = true>
      <cfif Len(Trim(local.data['userToken'])) AND NOT local.data['allowMultipleLikesPerUser']>
        <CFQUERY NAME="local.qGetUserID" DATASOURCE="#request.domain_dsn#">
          SELECT * 
          FROM tblUserToken 
          WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['userToken']#">
        </CFQUERY>
        <cfif local.qGetUserID.RecordCount>
          <CFQUERY NAME="local.qGetFileUser" DATASOURCE="#request.domain_dsn#">
            SELECT * 
            FROM tblFileUser
            WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['fileUuid']#"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUserID.User_ID#">
          </CFQUERY>
          <cfif local.qGetFileUser.RecordCount>
            <cfset local.allowMultipleLikesPerUser = false>
          </cfif>
        </cfif>
        <cfset local.data['error'] = "">
      </cfif>
      <cfif local.qGetFile.RecordCount AND local.allowMultipleLikesPerUser AND Len(Trim(local.data['userToken']))>
        <cfset likes = Val(local.qGetFile.Likes) + 1>
        <CFQUERY DATASOURCE="#request.domain_dsn#">
          UPDATE tblFile
          SET Likes = <cfqueryparam cfsqltype="cf_sql_integer" value="#likes#"> 
          WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['fileUuid']#">
        </CFQUERY>
        <CFQUERY NAME="local.qGetUserID" DATASOURCE="#request.domain_dsn#">
          SELECT * 
          FROM tblUserToken 
          WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['userToken']#">
        </CFQUERY>
        <cfif local.qGetUserID.RecordCount>
          <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
            SELECT * 
            FROM tblUser
            WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUserID.User_ID#">
          </CFQUERY>
          <cfif local.qGetUser.RecordCount>
            <CFQUERY DATASOURCE="#request.domain_dsn#">
              INSERT INTO tblFileUser (User_ID,File_uuid) 
              VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUser.User_ID#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['fileUuid']#">)
            </CFQUERY>
          </cfif>
        </cfif>
        <cfset local.data['error'] = "">
      <cfelse>
        <cfset local.data['error'] = "Like could not be added to the database">
      </cfif>
    </cfif>
    <CFQUERY NAME="local.qGetFile" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblFile
      WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['fileUuid']#">
    </CFQUERY>
    <cfif local.qGetFile.RecordCount>
      <cfset local.data['likes'] = local.qGetFile.Likes>
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>