
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type,Authorization,userToken" />

<cfparam name="uploadfolder" default="#request.uploadfolder#" />
<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset themeObj = createTheme(request.theme)>

<cfset data = StructNew()>
<cfset data['userid'] = 0>
<cfset data['forename'] = "">
<cfset data['surname'] = "">
<cfset data['email'] = "">
<cfset data['salt'] = "">
<cfset data['password'] = "">
<cfset data['cfid'] = cookie.cfid>
<cfset data['cftoken'] = cookie.cftoken>
<cfset data['signUpToken'] = "">
<cfset data['signUpValidated'] = 0>
<cfset data['avatarSrc'] = "">
<cfset data['emailNotification'] = 1>
<cfset data['theme'] = themeObj['default']>
<cfset data['roleid'] = 2>
<cfset data['keeploggedin'] = 0>
<cfset data['submitArticleNotification'] = 1>
<cfset data['cookieAcceptance'] = 0>
<cfset data['createdAt'] = "">
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
  <cfif StructKeyExists(requestBody,"password")>
  	<cfset data['password'] = Trim(requestBody['password'])>
  </cfif>
  <cfif StructKeyExists(requestBody,"emailNotification")>
  	<cfset data['emailNotification'] = Trim(requestBody['emailNotification'])>
  </cfif>
  <cfif StructKeyExists(requestBody,"theme")>
  	<cfset data['theme'] = Trim(requestBody['theme'])>
  </cfif>
  <cfif StructKeyExists(requestBody,"userid")>
 	<cfset data['userid'] = Trim(requestBody['userid'])>
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
      <cfif StructKeyExists(requestBody,"password")>
        <cfset data['password'] = Trim(requestBody['password'])>
      </cfif>
      <cfif StructKeyExists(requestBody,"emailNotification")>
        <cfset data['emailNotification'] = Trim(requestBody['emailNotification'])>
      </cfif>
      <cfif StructKeyExists(requestBody,"theme")>
        <cfset data['theme'] = Trim(requestBody['theme'])>
      </cfif>
      <cfif StructKeyExists(requestBody,"userid")>
        <cfset data['userid'] = Trim(requestBody['userid'])>
      </cfif>
      <cfcatch>
		<cfset data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
  </cfcatch>
</cftry>

<CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblUser 
  WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['userid']#">
</CFQUERY>
<cfif qGetUser.RecordCount>
  <cfif Len(Trim(data['password']))>
    <cftry>
      <cfset encryptedstring = Encrypts(data['password'],qGetUser.Salt)>
      <cfcatch>
        <cfset encryptedstring = "">
      </cfcatch>
    </cftry>
  <cfelse>
    <cfset encryptedstring = "">
  </cfif>
  <cfif Len(Trim(encryptedstring))>
	<cfset data['password'] = Hashed(encryptedstring,request.lckbcryptlib)>
  <cfelse>
	<cfset data['password'] = "">
  </cfif>
  <CFQUERY NAME="qUpdateUser" DATASOURCE="#request.domain_dsn#">
    UPDATE tblUser
    SET <cfif Len(Trim(data['password']))>Password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['password']#">,</cfif>Forename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CapFirst(data['forename'])#">,Surname =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#CapFirst(data['surname'])#">,Email_notification =  <cfqueryparam cfsqltype="cf_sql_tinyint" value="#data['emailNotification']#">,Theme =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#ListLast(data['theme'],'-')#">
    WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['userid']#">
  </CFQUERY>
  <cfset data['password'] = qGetUser.Password>
  <cfset data['email'] = qGetUser.E_mail>
  <cfset data['salt'] = qGetUser.Salt>
  <cfset data['cfid'] = qGetUser.Cfid>
  <cfset data['cftoken'] = qGetUser.Cftoken>
  <cfset data['signUpToken'] = qGetUser.SignUpToken>
  <cfset data['signUpValidated'] = qGetUser.SignUpValidated>
  <cfset data['avatarSrc'] = request.avatarbasesrc & qGetUser.Filename>
  <cfset data['roleid'] = qGetUser.Role_ID>
  <cfset data['keeploggedin'] = qGetUser.Keep_logged_in>
  <cfset data['submitArticleNotification'] = qGetUser.Submit_article_notification>
  <cfset data['cookieAcceptance'] = qGetUser.Cookie_acceptance>
  <cfset data['createdAt'] = qGetUser.Submission_date>
  <cfset data['error'] = "">
<cfelse>
  <cfset data['error'] = "User is not registered">
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>