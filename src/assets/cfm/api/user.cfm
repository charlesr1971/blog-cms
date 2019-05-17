
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type,Authorization,userToken" />

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
<cfset data['usertoken'] = "">
<cfset data['signuptoken'] = "">
<cfset data['signUpValidated'] = 0>
<cfset data['avatarSrc'] = "">
<cfset data['emailNotification'] = 1>
<cfset data['theme'] = themeObj['default']>
<cfset data['roleid'] = 2>
<cfset data['keeploggedin'] = 0>
<cfset data['submitArticleNotification'] = 1>
<cfset data['cookieAcceptance'] = 0>
<cfset data['forgottenPasswordToken'] = "">
<cfset data['forgottenPasswordValidated'] = 0>
<cfset data['displayName'] = "">
<cfset data['replyNotification'] = 1>
<cfset data['threadNotification'] = 1>
<cfset data['createdat'] = "">
<cfset data['error'] = "">

<cfset requestBody = toString(getHttpRequestData().content)>
<cfset requestBody = Trim(requestBody)>
<cftry>
  <cfset requestBody = DeserializeJSON(requestBody)>
  <cfif StructKeyExists(requestBody,"userToken")>
  	<cfset data['usertoken'] = Trim(requestBody['userToken'])>
  </cfif>
  <cfif StructKeyExists(requestBody,"userid")>
  	<cfset data['userid'] = Trim(requestBody['userid'])>
  </cfif>
  <cfcatch>
    <cftry>
      <cfset requestBody = REReplaceNoCase(requestBody,"[\s+]"," ","ALL")>
      <cfset requestBody = DeserializeJSON(requestBody)>
      <cfif StructKeyExists(requestBody,"userToken")>
		<cfset data['usertoken'] = Trim(requestBody['userToken'])>
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

<CFQUERY NAME="qGetUserID" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblUserToken 
  WHERE <cfif NOT Val(data['userid'])>User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['usertoken']#"><cfelse>User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['userid']#"></cfif>
</CFQUERY>

<cfif qGetUserID.RecordCount>
  <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
    SELECT * 
    FROM tblUser 
    WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUserID.User_ID#">
  </CFQUERY>
  <cfif qGetUser.RecordCount>
    <cfset data['userid'] = qGetUser.User_ID>
    <cfset data['forename'] = qGetUser.Forename>
    <cfset data['surname'] = qGetUser.Surname>
    <cfset data['email'] = qGetUser.E_mail>
    <cfset data['salt'] = qGetUser.Salt>
    <cfset data['password'] = qGetUser.Password>
    <cfset data['signuptoken'] = qGetUser.SignUpToken>
    <cfset data['signUpValidated'] = qGetUser.SignUpValidated>
    <cfset data['avatarSrc'] = request.avatarbasesrc & qGetUser.Filename>
    <cfset data['emailNotification'] = qGetUser.Email_notification>
    <cfset data['theme'] = themeObj['stem'] & "-" & qGetUser.Theme>
    <cfset data['roleid'] = qGetUser.Role_ID>
    <cfset data['keeploggedin'] = qGetUser.Keep_logged_in>
    <cfset data['submitArticleNotification'] = qGetUser.Submit_article_notification>
    <cfset data['cookieAcceptance'] = qGetUser.Cookie_acceptance>
    <cfset data['forgottenPasswordToken'] = qGetUser.ForgottenPasswordToken>
    <cfset data['forgottenPasswordValidated'] = qGetUser.ForgottenPasswordValidated>
    <cfset data['displayName'] = qGetUser.DisplayName>
    <cfset data['replyNotification'] = qGetUser.Reply_notification>
    <cfset data['threadNotification'] = qGetUser.Thread_notification>
    <cfset data['createdat'] = qGetUser.Submission_date>
  </cfif>
  <cfset data['error'] = "">
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>