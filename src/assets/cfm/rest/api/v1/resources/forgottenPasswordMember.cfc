
<cfcomponent extends="taffy.core.resource" taffy_uri="/forgotten/password" taffy_docs_hide>

  <cffunction name="post">
	<cfset var local = StructNew()>
    <cfset var emailtemplateheaderbackground = request.utils.getMaterialThemePrimaryColour(theme=request.theme)>
    <cfset var emailtemplatemessage = "">
	<cfset local.uploadfolder = request.uploadfolder>
    <cfset local.forgottenpasswordtoken = LCase(CreateUUID())>
    <cfset local.emailsubject = "Forgotten password from " & request.title>
    <cfset local.data = StructNew()>
    <cfset local.data['email'] =  "">
    <cfset local.data['userToken'] =  "">
    <cfset local.data['forgottenpasswordtoken'] = local.forgottenpasswordtoken>
    <cfset local.data['createdat'] = "">
    <cfset local.data['error'] = "">
    <cfset local.requestBody = getHttpRequestData().headers>
    <cftry>
	  <cfif StructKeyExists(local.requestBody,"email")>
		<cfset local.data['email'] =  Trim(local.requestBody['email'])>
      </cfif>
	  <cfif StructKeyExists(local.requestBody,"userToken")>
		<cfset local.data['userToken'] =  Trim(local.requestBody['userToken'])>
      </cfif>
      <cfcatch>
		<cfset local.data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
    <cfset local.emailpassword = Decrypt(request.emailPassword,request.emailSalt,request.crptographyalgorithm,request.crptographyencoding)>
    <CFQUERY NAME="local.qGetUserID" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUser 
      WHERE E_mail = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['email']#">
    </CFQUERY>
    <cfif local.qGetUserID.RecordCount AND Len(Trim(local.data['email'])) AND FindNoCase("@",local.data['email'])>
      <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblUser 
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUserID.User_ID#">
      </CFQUERY>
      <cfif local.qGetUser.RecordCount>
        <CFQUERY DATASOURCE="#request.domain_dsn#">
          UPDATE tblUser
          SET ForgottenPasswordToken = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['forgottenpasswordtoken']#">, ForgottenPasswordValidated = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> 
          WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUser.User_ID#">
        </CFQUERY>
        <cfset local.forename = request.utils.CapFirst(local.qGetUser.Forename)>
        <cfset local.data['createdat'] = Now()>
        <cfset local.salutation = local.forename>
        <cfsavecontent variable="emailtemplatemessage">
          <cfoutput>
            <h1>Hi<cfif Len(Trim(local.salutation))> #local.salutation#</cfif></h1>
            <table cellpadding="0" cellspacing="0" border="0" width="100%">
              <tr valign="middle">
                <td width="10" bgcolor="##DDDDDD"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="10" height="1" /></td>
                <td width="20"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="20" height="1" /></td>
                <td style="font-size:16px;">
                  <strong>#request.title# has received a message that you have forgotten your password</strong><br /><br />
                  A 'forgotten password' token has been issued. This token will allow you to change your password, but it can only be used once.<br />
                  Please follow the link below, in order to complete this process:
                </td>
              </tr>
              <tr>
                <td colspan="3">
                  <p>Please validate e-mail:</p>
                  <a href="#local.uploadfolder#/index.cfm?forgottenPasswordToken=#local.data['forgottenpasswordtoken']#">Validate E-mail</a>
                </td>
              </tr>
            </table>
          </cfoutput>
        </cfsavecontent>
        <cfmail to="#local.data['email']#" from="#request.email#" server="#request.emailServer#" username="#request.emailUsername#" password="#local.emailpassword#" port="#request.emailPort#" useSSL="#request.emailUseSsl#" useTLS="#request.emailUseTls#" subject="#local.emailsubject#" type="html">
          <cfinclude template="../../../../email-template.cfm">
        </cfmail>
      <cfelse>
		<cfset local.data['error'] = "User not registered">
      </cfif>
    <cfelse>
      <cfset local.data['error'] = "User token not registered">
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>