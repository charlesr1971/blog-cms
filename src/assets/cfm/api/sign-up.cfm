
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type,Authorization,userToken" />

<cfparam name="uploadfolder" default="#request.uploadfolder#" />
<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="thealgorithm" default="#request.crptographyalgorithm#">
<cfparam name="thekey" default="#request.crptographykey#">
<cfparam name="signuptoken" default="#LCase(CreateUUID())#" />
<cfparam name="testEmail" default="false" />
<cfparam name="emailsubject" default="Validate e-mail from #request.title#" />
<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset emailtemplateheaderbackground = getMaterialThemePrimaryColour(theme=request.theme)>
<cfset emailtemplatemessage = "">

<cfset data = StructNew()>
<cfset data['userid'] = 0>
<cfset data['forename'] = "">
<cfset data['surname'] = "">
<cfset data['email'] = "">
<cfset data['salt'] = thekey>
<cfset data['password'] = "">
<cfset data['usertoken'] = "">
<cfset data['cfid'] = cookie.cfid>
<cfset data['cftoken'] = cookie.cftoken>
<cfset data['signuptoken'] = signuptoken>
<cfset data['signUpValidated'] = 0>
<cfset data['roleid'] = 2>
<cfset data['cookieAcceptance'] = 0>
<cfset data['createdat'] = "">
<cfset data['error'] = "">

<cfset requestBody = toString(getHttpRequestData().content)>
<cfset requestBody = Trim(requestBody)>
<cftry>
  <cfset requestBody = DeserializeJSON(requestBody)>
  <cfif StructKeyExists(requestBody,"forename")>
  	<cfset data['forename'] = Trim(requestBody['forename'])>
  </cfif>
  <cfif StructKeyExists(requestBody,"surname")>
  	<cfset data['surname'] = Trim(requestBody['surname'])>
  </cfif>
  <cfif StructKeyExists(requestBody,"email")>
  	<cfset data['email'] = Trim(requestBody['email'])>
  </cfif>
  <cfif StructKeyExists(requestBody,"password")>
  	<cfset data['password'] = Trim(requestBody['password'])>
  </cfif>
  <cfif StructKeyExists(requestBody,"userToken")>
  	<cfset data['usertoken'] = Trim(requestBody['userToken'])>
  </cfif>
  <cfif StructKeyExists(requestBody,"cfid")>
  	<cfset data['cfid'] = Trim(requestBody['cfid'])>
  </cfif>
  <cfif StructKeyExists(requestBody,"cftoken")>
  	<cfset data['cftoken'] = Trim(requestBody['cftoken'])>
  </cfif>
  <cfif StructKeyExists(requestBody,"cookieAcceptance")>
  	<cfset data['cookieAcceptance'] = Trim(requestBody['cookieAcceptance'])>
  </cfif>
  <cfcatch>
    <cftry>
      <cfset requestBody = REReplaceNoCase(requestBody,"[\s+]"," ","ALL")>
      <cfset requestBody = DeserializeJSON(requestBody)>
      <cfif StructKeyExists(requestBody,"forename")>
		<cfset data['forename'] = Trim(requestBody['forename'])>
      </cfif>
      <cfif StructKeyExists(requestBody,"surname")>
        <cfset data['surname'] = Trim(requestBody['surname'])>
      </cfif>
      <cfif StructKeyExists(requestBody,"email")>
        <cfset data['email'] = Trim(requestBody['email'])>
      </cfif>
      <cfif StructKeyExists(requestBody,"password")>
        <cfset data['password'] = Trim(requestBody['password'])>
      </cfif>
      <cfif StructKeyExists(requestBody,"userToken")>
        <cfset data['usertoken'] = Trim(requestBody['userToken'])>
      </cfif>
      <cfif StructKeyExists(requestBody,"cfid")>
        <cfset data['cfid'] = Trim(requestBody['cfid'])>
      </cfif>
      <cfif StructKeyExists(requestBody,"cftoken")>
        <cfset data['cftoken'] = Trim(requestBody['cftoken'])>
      </cfif>
      <cfif StructKeyExists(requestBody,"cookieAcceptance")>
		<cfset data['cookieAcceptance'] = Trim(requestBody['cookieAcceptance'])>
      </cfif>
      <cfcatch>
		<cfset data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
  </cfcatch>
</cftry>

<cfset emailpassword = Decrypt(request.emailPassword,request.emailSalt,request.crptographyalgorithm,request.crptographyencoding)>

<cfif testEmail>
  <cfset salutation = "Charlie">
  <cfsavecontent variable="emailtemplatemessage">
	<cfoutput>
      <h1>Hi<cfif Len(Trim(salutation))> #salutation#</cfif></h1>
      <table cellpadding="0" cellspacing="0" border="0" width="100%">
        <tr valign="middle">
          <td width="10" bgcolor="##DDDDDD"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="10" height="1" /></td>
          <td width="20"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="20" height="1" /></td>
          <td style="font-size:16px;">
            <strong>#request.title# would like to welcome you to our community</strong><br /><br />
            Thank you for taking an interest.<br />
            To complete the sign up process, please follow the link below:
          </td>
        </tr>
        <tr>
          <td colspan="3">
            <p>Please validate e-mail:</p>
            <a href="#uploadfolder#/index.cfm?signUpToken=#data['signuptoken']#">Validate E-mail</a>
          </td>
        </tr>
      </table>
    </cfoutput>
  </cfsavecontent>
  <cfmail to="#request.email#" from="#request.email#" server="#request.emailServer#" username="#request.emailUsername#" password="#emailpassword#" port="#request.emailPort#" useSSL="#request.emailUseSsl#" useTLS="#request.emailUseTls#" subject="#emailsubject#" type="html">
    <cfinclude template="../email-template.cfm">
  </cfmail>
  <cfabort />
</cfif>

<CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblUser 
  WHERE E_mail = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['email']#">
</CFQUERY>
<cfif NOT qGetUser.RecordCount AND Len(Trim(data['email'])) AND FindNoCase("@",data['email']) AND Len(Trim(data['password']))>
  <cfset encryptedstring = Encrypts(data['password'],data['salt'])>
  <cfset data['password'] = Hashed(encryptedstring,request.lckbcryptlib)>
  <cfset forename = CapFirst(data['forename'])>
  <cfset surname = CapFirst(data['surname'])>
  <CFQUERY DATASOURCE="#request.domain_dsn#" result="queryInsertResult">
	INSERT INTO tblUser (Salt,Password,E_mail,Forename,Surname,Cfid,Cftoken,SignUpToken,Cookie_acceptance) 
	VALUES (<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['salt']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['password']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['email']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#forename#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#surname#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['cfid']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['cftoken']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['signuptoken']#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#data['cookieAcceptance']#">)
  </CFQUERY>
  <cfset data['userid'] = queryInsertResult.generatedkey>
  <CFQUERY NAME="qGetUserID" DATASOURCE="#request.domain_dsn#">
    SELECT * 
    FROM tblUserToken 
    WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['usertoken']#">
  </CFQUERY>
  <cfif NOT qGetUserID.RecordCount>
    <CFQUERY DATASOURCE="#request.domain_dsn#">
      INSERT INTO tblUserToken (User_ID,User_token) 
      VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#data['userid']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['usertoken']#">)
    </CFQUERY>
  </cfif>
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
            <strong>#request.title# would like to welcome you to our community</strong><br /><br />
            Thank you for taking an interest.<br />
            To complete the sign up process, please follow the link below:
          </td>
        </tr>
        <tr>
          <td colspan="3">
            <p>Please validate e-mail:</p>
            <a href="#uploadfolder#/index.cfm?signUpToken=#data['signuptoken']#">Validate E-mail</a>
          </td>
        </tr>
      </table>
    </cfoutput>
  </cfsavecontent>
  <cfmail to="#data['email']#" from="#request.email#" server="#request.emailServer#" username="#request.emailUsername#" password="#emailpassword#" port="#request.emailPort#" useSSL="#request.emailUseSsl#" useTLS="#request.emailUseTls#" subject="#emailsubject#" type="html">
    <cfinclude template="../email-template.cfm">
  </cfmail>
  <cfset data['error'] = "">
<cfelse>
  <cfset data['error'] = "User already registered">
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>