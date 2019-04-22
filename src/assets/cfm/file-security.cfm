<cfoutput>

  <cfparam name="local.imagemembersecurityusertoken" default="">
  <cfparam name="local.imagemembersecurityfileuuid" default="">

  <cfif Len(Trim(local.imagemembersecurityusertoken))>
    <CFQUERY NAME="local.qGetUserTokenRoleId" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUser INNER JOIN tblUsertoken ON tblUser.User_ID = tblUsertoken.User_ID
      WHERE tblUsertoken.User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.imagemembersecurityusertoken#">
    </CFQUERY>
    <cfif local.qGetUserTokenRoleId.RecordCount AND local.qGetUserTokenRoleId.Role_ID LT 6>
      <CFQUERY NAME="local.qGetFileUserToken" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblFile INNER JOIN tblUser ON tblFile.User_ID = tblUser.User_ID INNER JOIN tblUsertoken ON tblUser.User_ID = tblUsertoken.User_ID
        WHERE <cfif NOT ISNUMERIC(local.imagemembersecurityfileuuid)>File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.imagemembersecurityfileuuid#"><cfelse>File_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.imagemembersecurityfileuuid#"></cfif> AND tblUsertoken.User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.imagemembersecurityusertoken#">
      </CFQUERY>
      <cfif NOT local.qGetFileUserToken.RecordCount>
        <cfset local.authorized = false>
        <cfset local.data = StructNew()>
        <cfset local.data['error'] = "The file reference does not belong to this user">
      </cfif>
    <cfelse>
	  <cfset local.isAdmin = true>
    </cfif>
  <cfelse>
    <cfset local.authorized = false>
    <cfset local.data = StructNew()>
    <cfset local.data['error'] = "The file reference does not belong to this user">
  </cfif>

</cfoutput>