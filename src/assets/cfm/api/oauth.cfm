
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type,Authorization,userToken" />

<cfparam name="uploadfolder" default="#request.uploadfolder#" />
<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="thealgorithm" default="#request.crptographyalgorithm#">
<cfparam name="thekey" default="#request.crptographykey#">
<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset themeObj = createTheme(request.theme)>

<cfset data = StructNew()>
<cfset data['userid'] = 0>
<cfset data['forename'] = "">
<cfset data['surname'] = "">
<cfset data['email'] = "">
<cfset data['salt'] = thekey>
<cfset data['password'] = "">
<cfset data['userToken'] = "">
<cfset data['authenticated'] = 0>
<cfset data['usertokenmatch'] = "">
<cfset data['cfid'] = cookie.cfid>
<cfset data['cftoken'] = cookie.cftoken>
<cfset data['signUpToken'] = "">
<cfset data['signUpValidated'] = 0>
<cfset data['avatarSrc'] = "">
<cfset data['emailNotification'] = 1>
<cfset data['theme'] = "">
<cfset data['roleid'] = 2>
<cfset data['keeploggedin'] = 0>
<cfset data['submitArticleNotification'] = 1>
<cfset data['commentToken'] = "">
<cfset data['commentid'] = 0>
<cfset data['fileUuid'] = "">
<cfset data['cookieAcceptance'] = 0>
<cfset data['forgottenPasswordToken'] = "">
<cfset data['forgottenPasswordValidated'] = 0>
<cfset data['isForgottenPasswordValidated'] = 0>
<cfset data['displayName'] = "">
<cfset data['replyNotification'] = 1>
<cfset data['createdAt'] = "">
<cfset data['error'] = "">

<cfset requestBody = toString(getHttpRequestData().content)>
<cfset requestBody = Trim(requestBody)>
<cftry>
  <cfset requestBody = DeserializeJSON(requestBody)>
  <cfif StructKeyExists(requestBody,"email")>
  	<cfset data['email'] = Trim(requestBody['email'])>
  </cfif>
  <cfif StructKeyExists(requestBody,"password")>
  	<cfset data['password'] = Trim(requestBody['password'])>
  </cfif>
  <cfif StructKeyExists(requestBody,"userToken")>
  	<cfset data['userToken'] = Trim(requestBody['userToken'])>
  </cfif>
  <cfif StructKeyExists(requestBody,"commentToken")>
  	<cfset data['commentToken'] = Trim(requestBody['commentToken'])>
  </cfif>
  <cfif StructKeyExists(requestBody,"keeploggedin")>
  	<cfset data['keeploggedin'] = Trim(requestBody['keeploggedin'])>
  </cfif>
  <cfif StructKeyExists(requestBody,"theme")>
  	<cfset data['theme'] = Trim(requestBody['theme'])>
  </cfif>
  <cfif StructKeyExists(requestBody,"forgottenPasswordToken")>
  	<cfset data['forgottenPasswordToken'] = Trim(requestBody['forgottenPasswordToken'])>
  </cfif>
  <cfif StructKeyExists(requestBody,"forgottenPasswordValidated")>
  	<cfset data['forgottenPasswordValidated'] = Trim(requestBody['forgottenPasswordValidated'])>
  </cfif>
  <cfcatch>
    <cftry>
      <cfset requestBody = REReplaceNoCase(requestBody,"[\s+]"," ","ALL")>
      <cfset requestBody = DeserializeJSON(requestBody)>
      <cfif StructKeyExists(requestBody,"email")>
		<cfset data['email'] = Trim(requestBody['email'])>
      </cfif>
      <cfif StructKeyExists(requestBody,"password")>
        <cfset data['password'] = Trim(requestBody['password'])>
      </cfif>
      <cfif StructKeyExists(requestBody,"userToken")>
        <cfset data['userToken'] = Trim(requestBody['userToken'])>
      </cfif>
      <cfif StructKeyExists(requestBody,"commentToken")>
        <cfset data['commentToken'] = Trim(requestBody['commentToken'])>
      </cfif>
      <cfif StructKeyExists(requestBody,"keeploggedin")>
        <cfset data['keeploggedin'] = Trim(requestBody['keeploggedin'])>
      </cfif>
      <cfif StructKeyExists(requestBody,"theme")>
		<cfset data['theme'] = Trim(requestBody['theme'])>
      </cfif>
      <cfif StructKeyExists(requestBody,"forgottenPasswordToken")>
		<cfset data['forgottenPasswordToken'] = Trim(requestBody['forgottenPasswordToken'])>
      </cfif>
      <cfif StructKeyExists(requestBody,"forgottenPasswordValidated")>
        <cfset data['forgottenPasswordValidated'] = Trim(requestBody['forgottenPasswordValidated'])>
      </cfif>
      <cfcatch>
		<cfset data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
  </cfcatch>
</cftry>

<cfset isForgottenPasswordValidated = false>
<cfif Len(Trim(data['forgottenPasswordToken'])) AND Val(data['forgottenPasswordValidated'])>
  <cfset isForgottenPasswordValidated = true>
</cfif>

<cfif NOT Len(Trim(data['commentToken'])) AND NOT isForgottenPasswordValidated>
  <CFQUERY NAME="qGetSalt" DATASOURCE="#request.domain_dsn#">
    SELECT * 
    FROM tblUser 
    WHERE E_mail = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['email']#"> AND SignUpValidated = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"> AND Suspend = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> 
  </CFQUERY>
  <cfif qGetSalt.RecordCount>
    <cfset salt = "">
    <cfset hashencryptedstring = "">
    <cfif qGetSalt.RecordCount>
      <cfset salt = qGetSalt.Salt>
      <cfset hashencryptedstring = qGetSalt.Password>
    </cfif>
    <cfif Len(Trim(data['password']))>
      <cftry>
        <cfset password = Encrypts(data['password'],salt)>
        <cfcatch>
          <cfset password = "">
        </cfcatch>
      </cftry>
    <cfelse>
      <cfset password = "">
    </cfif>
    <cfset hashmatched = HashMatched(password,hashencryptedstring,request.lckbcryptlib)>
    <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUser 
      WHERE E_mail = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['email']#"> AND Salt = <cfqueryparam cfsqltype="cf_sql_varchar" value="#salt#"> 
    </CFQUERY>
    <cfif qGetUser.RecordCount AND Len(Trim(data['password'])) AND hashmatched>
      <CFQUERY NAME="qGetUserID" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblUserToken 
        WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['userToken']#">
      </CFQUERY>
      <cfif NOT qGetUserID.RecordCount AND Len(Trim(data['userToken']))>
		<CFQUERY DATASOURCE="#request.domain_dsn#">
          INSERT INTO tblUserToken (User_ID,User_token) 
          VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['userToken']#">)
        </CFQUERY>
        <cfset data['usertokenmatch'] = "no user token match, so new one was inserted">
	  <cfelse>
        <cfif qGetUser.User_ID NEQ qGetUserID.User_ID>
		  <cfset data['userToken'] = LCase(CreateUUID())>
          <CFQUERY NAME="qUpdateUserToken" DATASOURCE="#request.domain_dsn#">
            UPDATE tblUserToken
            SET User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['userToken']#"> 
            WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#">
          </CFQUERY>
          <cfset data['usertokenmatch'] = "user token match, but belonged to different user, so old token updated with new token">
        </cfif>
        <cfset data['usertokenmatch'] = "user token match">
      </cfif>
      <cfif Len(Trim(data['theme']))>
        <CFQUERY NAME="qUpdateUser" DATASOURCE="#request.domain_dsn#">
          UPDATE tblUser
          SET Keep_logged_in = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#data['keeploggedin']#">,Theme =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#ListLast(data['theme'],'-')#"> 
          WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#">
        </CFQUERY>
      </cfif>
      <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblUser 
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#"> 
      </CFQUERY>
      <cfif qGetUser.RecordCount>
		<cfset data['userid'] = qGetUser.User_ID>
        <cfset data['forename'] = qGetUser.Forename>
        <cfset data['surname'] = qGetUser.Surname>
        <cfset data['salt'] = qGetUser.Salt>
        <cfset data['password'] = qGetUser.Password>
        <cfset data['authenticated'] = 1>
        <cfset data['cfid'] = qGetUser.Cfid>
        <cfset data['cftoken'] = qGetUser.Cftoken>
        <cfset data['signUpToken'] = qGetUser.SignUpToken>
        <cfset data['signUpValidated'] = qGetUser.SignUpValidated>
        <cfset data['avatarSrc'] = request.avatarbasesrc & qGetUser.Filename>
        <cfset data['emailNotification'] = qGetUser.Email_notification>
        <cfset data['theme'] = themeObj['stem'] & "-" & qGetUser.Theme>
        <cfset data['roleid'] = qGetUser.Role_ID>
        <cfset data['keeploggedin'] = data['keeploggedin']>
        <cfset data['submitArticleNotification'] = qGetUser.Submit_article_notification>
        <cfset data['cookieAcceptance'] = qGetUser.Cookie_acceptance>
        <cfset data['forgottenPasswordToken'] = qGetUser.ForgottenPasswordToken>
        <cfset data['forgottenPasswordValidated'] = qGetUser.ForgottenPasswordValidated>
        <cfset data['displayName'] = qGetUser.DisplayName>
        <cfset data['replyNotification'] = qGetUser.Reply_notification>
        <cfset data['createdAt'] = qGetUser.Submission_date>
      </cfif>
    </cfif>
    <cfset data['error'] = "">
  <cfelse>
    <CFQUERY NAME="qGetEmail" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUser 
      WHERE E_mail = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['email']#">
    </CFQUERY>
    <cfif qGetEmail.RecordCount>
      <cfset data['error'] = "User has registered but has not validated e-mail">
    <cfelse>
      <CFQUERY NAME="qGetEmail" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblUser 
        WHERE E_mail = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['email']#"> AND Suspend = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1">
      </CFQUERY>
      <cfif qGetEmail.RecordCount>
		<cfset data['error'] = "User's account has been temporarily suspended for security reasons">
      <cfelse>
		<cfset data['error'] = "User has not registered">
      </cfif>
    </cfif>
  </cfif>
<cfelseif Len(Trim(data['commentToken'])) AND NOT isForgottenPasswordValidated>
  <CFQUERY NAME="qGetComment" DATASOURCE="#request.domain_dsn#">
    SELECT * 
    FROM tblComment 
    WHERE Token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['commentToken']#"> 
  </CFQUERY>
  <cfif qGetComment.RecordCount>
    <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUser INNER JOIN tblFile ON tblUser.User_ID = tblFile.User_ID
      WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetComment.File_uuid#"> AND Suspend = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0">
    </CFQUERY>
    <cfif qGetUser.RecordCount>
      <CFQUERY NAME="qGetUserID" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblUserToken 
        WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['userToken']#">
      </CFQUERY>
      <cfif NOT qGetUserID.RecordCount AND Len(Trim(data['userToken']))>
		<CFQUERY DATASOURCE="#request.domain_dsn#">
          INSERT INTO tblUserToken (User_ID,User_token) 
          VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['userToken']#">)
        </CFQUERY>
        <cfset data['usertokenmatch'] = "no user token match, so new one was inserted">
	  <cfelse>
        <cfif qGetUser.User_ID NEQ qGetUserID.User_ID>
		  <cfset data['userToken'] = LCase(CreateUUID())>
          <CFQUERY NAME="qUpdateUserToken" DATASOURCE="#request.domain_dsn#">
            UPDATE tblUserToken
            SET User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['userToken']#"> 
            WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#">
          </CFQUERY>
          <cfset data['usertokenmatch'] = "user token match, but belonged to different user, so old token updated with new token">
        <cfelse>
		  <cfset data['usertokenmatch'] = "user token match">
        </cfif>
      </cfif>
      <cfif Len(Trim(data['theme']))>
        <CFQUERY NAME="qUpdateUser" DATASOURCE="#request.domain_dsn#">
          UPDATE tblUser
          SET Theme =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#ListLast(data['theme'],'-')#"> 
          WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#">
        </CFQUERY>
      </cfif>
      <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblUser 
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#"> 
      </CFQUERY>
      <cfif qGetUser.RecordCount>
		<cfset data['userid'] = qGetUser.User_ID>
        <cfset data['forename'] = qGetUser.Forename>
        <cfset data['surname'] = qGetUser.Surname>
        <cfset data['email'] = qGetUser.E_mail>
        <cfset data['salt'] = qGetUser.Salt>
        <cfset data['password'] = qGetUser.Password>
        <cfset data['authenticated'] = 1>
        <cfset data['cfid'] = qGetUser.Cfid>
        <cfset data['cftoken'] = qGetUser.Cftoken>
        <cfset data['signUpToken'] = qGetUser.SignUpToken>
        <cfset data['signUpValidated'] = qGetUser.SignUpValidated>
        <cfset data['avatarSrc'] = request.avatarbasesrc & qGetUser.Filename>
        <cfset data['emailNotification'] = qGetUser.Email_notification>
        <cfset data['theme'] = themeObj['stem'] & "-" & qGetUser.Theme>
        <cfset data['roleid'] = qGetUser.Role_ID>
        <cfset data['keeploggedin'] = qGetUser.Keep_logged_in>
        <cfset data['submitArticleNotification'] = qGetUser.Submit_article_notification>
        <cfset data['commentid'] = qGetComment.Comment_ID>
        <cfset data['fileUuid'] = qGetComment.File_uuid>
        <cfset data['cookieAcceptance'] = qGetUser.Cookie_acceptance>
        <cfset data['forgottenPasswordToken'] = qGetUser.ForgottenPasswordToken>
        <cfset data['forgottenPasswordValidated'] = qGetUser.ForgottenPasswordValidated>
        <cfset data['displayName'] = qGetUser.DisplayName>
        <cfset data['replyNotification'] = qGetUser.Reply_notification>
        <cfset data['createdAt'] = qGetUser.Submission_date>
        <cfset data['error'] = "">
      </cfif>
    </cfif>
  </cfif>
<cfelseif isForgottenPasswordValidated>
  <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
    SELECT * 
    FROM tblUser 
    WHERE ForgottenPasswordToken = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['forgottenPasswordToken']#"> AND ForgottenPasswordValidated = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"> AND Suspend = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0">
  </CFQUERY>
  <cfif qGetUser.RecordCount>
    <CFQUERY DATASOURCE="#request.domain_dsn#">
      UPDATE tblUser
      SET ForgottenPasswordToken = <cfqueryparam cfsqltype="cf_sql_varchar" value="">, ForgottenPasswordValidated = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0">
      WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#">
    </CFQUERY>
    <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUser 
      WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#">
    </CFQUERY>
    <cfif qGetUser.RecordCount>
      <CFQUERY NAME="qGetUserID" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblUserToken 
        WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['userToken']#">
      </CFQUERY>
      <cfif NOT qGetUserID.RecordCount AND Len(Trim(data['userToken']))>
        <CFQUERY DATASOURCE="#request.domain_dsn#">
          INSERT INTO tblUserToken (User_ID,User_token) 
          VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['userToken']#">)
        </CFQUERY>
        <cfset data['usertokenmatch'] = "no user token match, so new one was inserted">
      <cfelse>
        <cfif qGetUser.User_ID NEQ qGetUserID.User_ID>
          <cfset data['userToken'] = LCase(CreateUUID())>
          <CFQUERY DATASOURCE="#request.domain_dsn#">
            UPDATE tblUserToken
            SET User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['userToken']#"> 
            WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#">
          </CFQUERY>
          <cfset data['usertokenmatch'] = "user token match, but belonged to different user, so old token updated with new token">
        </cfif>
        <cfset data['usertokenmatch'] = "user token match">
      </cfif>
      <cfif Len(Trim(data['theme']))>
        <CFQUERY DATASOURCE="#request.domain_dsn#">
          UPDATE tblUser
          SET Theme =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#ListLast(data['theme'],'-')#">  
          WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#">
        </CFQUERY>
      </cfif>
      <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblUser 
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#"> 
      </CFQUERY>
      <cfif qGetUser.RecordCount>
        <cfset data['userid'] = qGetUser.User_ID>
        <cfset data['forename'] = qGetUser.Forename>
        <cfset data['surname'] = qGetUser.Surname>
        <cfset data['email'] = qGetUser.E_mail>
        <cfset data['salt'] = qGetUser.Salt>
        <cfset data['password'] = qGetUser.Password>
        <cfset data['authenticated'] = 1>
        <cfset data['cfid'] = qGetUser.Cfid>
        <cfset data['cftoken'] = qGetUser.Cftoken>
        <cfset data['signUpToken'] = qGetUser.SignUpToken>
        <cfset data['signUpValidated'] = qGetUser.SignUpValidated>
        <cfset data['avatarSrc'] = request.avatarbasesrc & qGetUser.Filename>
        <cfset data['emailNotification'] = qGetUser.Email_notification>
        <cfset data['theme'] = themeObj['stem'] & "-" & qGetUser.Theme>
        <cfset data['roleid'] = qGetUser.Role_ID>
        <cfset data['keeploggedin'] = qGetUser.Keep_logged_in>
        <cfset data['submitArticleNotification'] = qGetUser.Submit_article_notification>
        <cfset data['commentid'] = qGetComment.Comment_ID>
        <cfset data['fileUuid'] = qGetComment.File_uuid>
        <cfset data['cookieAcceptance'] = qGetUser.Cookie_acceptance>
        <cfset data['forgottenPasswordToken'] = qGetUser.ForgottenPasswordToken>
        <cfset data['forgottenPasswordValidated'] = qGetUser.ForgottenPasswordValidated>
        <cfset data['isForgottenPasswordValidated'] = 1>
        <cfset data['displayName'] = qGetUser.DisplayName>
        <cfset data['replyNotification'] = qGetUser.Reply_notification>
        <cfset data['createdAt'] = qGetUser.Submission_date>
        <cfset data['error'] = "">
      </cfif>
    </cfif>
  </cfif>
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>