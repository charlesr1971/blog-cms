
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type,Authorization,userToken" />

<cfparam name="uploadfolder" default="#request.uploadfolder#" />
<cfparam name="emailsubject" default="Forgotten password from #request.title#" />
<cfparam name="forgottenpasswordtoken" default="#LCase(CreateUUID())#" />
<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset emailtemplateheaderbackground = getMaterialThemePrimaryColour(theme=request.theme)>
<cfset emailtemplatemessage = "">

<cfset data = StructNew()>
<cfset data['email'] =  "">
<cfset data['userToken'] =  "">
<cfset data['forgottenpasswordtoken'] = forgottenpasswordtoken>
<cfset data['createdat'] = "">
<cfset data['error'] = "">

<cfset requestBody = toString(getHttpRequestData().content)>
<cfset requestBody = Trim(requestBody)>
<cftry>
  <cfset requestBody = DeserializeJSON(requestBody)>
  <cfif StructKeyExists(requestBody,"email")>
  	<cfset data['email'] = Trim(requestBody['email'])>
  </cfif>
  <cfcatch>
    <cftry>
      <cfset requestBody = REReplaceNoCase(requestBody,"[\s+]"," ","ALL")>
      <cfset requestBody = DeserializeJSON(requestBody)>
      <cfif StructKeyExists(requestBody,"email")>
		<cfset data['email'] = Trim(requestBody['email'])>
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
	<cfset data['userToken'] =  Trim(requestBody['userToken'])>
  </cfif>
  <cfcatch>
	<cfset data['error'] = cfcatch.message>
  </cfcatch>
</cftry>

<cfset emailpassword = Decrypt(request.emailPassword,request.emailSalt,request.crptographyalgorithm,request.crptographyencoding)>
<CFQUERY NAME="qGetUserID" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblUser 
  WHERE E_mail = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['email']#">
</CFQUERY>
<cfif qGetUserID.RecordCount AND Len(Trim(data['email'])) AND FindNoCase("@",data['email'])>
  <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
	SELECT * 
	FROM tblUser 
	WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUserID.User_ID#">
  </CFQUERY>
  <cfif qGetUser.RecordCount>
	<CFQUERY DATASOURCE="#request.domain_dsn#">
	  UPDATE tblUser
	  SET ForgottenPasswordToken = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['forgottenpasswordtoken']#">, ForgottenPasswordValidated = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0">
	  WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#">
	</CFQUERY>
    <cfset forename = CapFirst(qGetUser.Forename)>
	<cfset data['createdat'] = Now()>
	<cfset salutation = forename>
	<cfsavecontent variable="emailtemplatemessage">
	  <cfoutput>
		<h1>Hi<cfif Len(Trim(salutation))> #salutation#</cfif></h1>
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
			  <a href="#uploadfolder#/index.cfm?forgottenPasswordToken=#data['forgottenpasswordtoken']#">Validate E-mail</a>
			</td>
		  </tr>
		</table>
	  </cfoutput>
	</cfsavecontent>
	<cfmail to="#data['email']#" from="#request.email#" server="#request.emailServer#" username="#request.emailUsername#" password="#emailpassword#" port="#request.emailPort#" useSSL="#request.emailUseSsl#" useTLS="#request.emailUseTls#" subject="#emailsubject#" type="html">
	  <cfinclude template="../../../../email-template.cfm">
	</cfmail>
  <cfelse>
	<cfset data['error'] = "User not registered">
  </cfif>
<cfelse>
  <cfset data['error'] = "User token not registered">
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>