<cfoutput>

  <cfparam name="local.usermembersecurityusertoken" default="">

  <cfif Len(Trim(local.usermembersecurityusertoken))>
    <CFQUERY NAME="local.qGetUserToken" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUser JOIN tblUsertoken ON tblUser.User_ID = tblUsertoken.User_ID
      WHERE tblUsertoken.User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.usermembersecurityusertoken#">
    </CFQUERY>
    <cfif NOT local.qGetUserToken.RecordCount>
      <cfset local.authorized = false>
	  <cfset local.data = StructNew()>
      <cfset local.data['error'] = "The token provided does not belong to this user">
    </cfif>
  <cfelse>
	  <cfset local.authorized = false>
	  <cfset local.data = StructNew()>
      <cfset local.data['error'] = "The token provided does not belong to this user">
  </cfif>

</cfoutput>