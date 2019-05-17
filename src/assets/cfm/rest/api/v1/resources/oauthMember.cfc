
<cfcomponent extends="taffy.core.resource" taffy_uri="/oauth/{userToken}/{keeploggedin}">

  <cffunction name="post">
    <cfargument name="userToken" type="string" required="yes" />
    <cfargument name="keeploggedin" type="numeric" required="yes" hint="tinyInt" />
    <cfset var local = StructNew()>
    <cfset local.jwtid = LCase(CreateUUID())>
    <cfset local.themeObj = request.utils.createTheme(request.theme)>
    <cfset local.data = StructNew()>
	<cfset local.data['userid'] = 0>
    <cfset local.data['forename'] = "">
    <cfset local.data['surname'] = "">
    <cfset local.data['email'] = "">
    <cfset local.data['salt'] = request.crptographykey>
    <cfset local.data['password'] = "">
    <cfset local.data['userToken'] = arguments.usertoken EQ 'empty' ? '' : arguments.usertoken>
    <cfset local.data['authenticated'] = 0>
    <cfset local.data['usertokenmatch'] = "">
    <cfset local.data['cfid'] = "">
    <cfset local.data['cftoken'] = "">
    <cfset local.data['signUpToken'] = "">
    <cfset local.data['signUpValidated'] = 0>
    <cfset local.data['avatarSrc'] = "">
    <cfset local.data['emailNotification'] = 1>
    <cfset local.data['theme'] = "">
    <cfset local.data['roleid'] = 2>
    <cfset local.data['keeploggedin'] = arguments.keeploggedin>
    <cfset local.data['submitArticleNotification'] = 1>
    <cfset local.data['commentToken'] = "">
    <cfset local.data['commentid'] = 0>
    <cfset local.data['fileUuid'] = "">
    <cfset local.data['cookieAcceptance'] = 0>
    <cfset local.data['forgottenPasswordToken'] = "">
    <cfset local.data['forgottenPasswordValidated'] = 0>
    <cfset local.data['isForgottenPasswordValidated'] = 0>
    <cfset local.data['displayName'] = "">
    <cfset local.data['replyNotification'] = 1>
    <cfset local.data['threadNotification'] = 1>
    <cfset local.data['createdAt'] = "">
    <cfset local.data['jwtToken'] = "">
    <cfset local.data['error'] = "">
    <cfset local.requestBody = getHttpRequestData().headers>
    <cftry>
      <cfif StructKeyExists(local.requestBody,"email")>
        <cfset local.data['email'] = Trim(local.requestBody['email'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"password")>
		<cfset local.data['password'] = Trim(local.requestBody['password'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"commentToken")>
		<cfset local.data['commentToken'] = Trim(local.requestBody['commentToken'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"forgottenPasswordToken")>
		<cfset local.data['forgottenPasswordToken'] = Trim(local.requestBody['forgottenPasswordToken'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"forgottenPasswordValidated")>
		<cfset local.data['forgottenPasswordValidated'] = Trim(local.requestBody['forgottenPasswordValidated'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"theme")>
		<cfset local.data['theme'] = Trim(local.requestBody['theme'])>
      </cfif>
      <cfcatch>
		<cfset local.data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
    <!---<cfdump var="#local.data#" abort />--->
    <!---<cfoutput>local.data['password']: #local.data['password']#</cfoutput>--->
    <cfset local.isForgottenPasswordValidated = false>
    <cfif Len(Trim(local.data['forgottenPasswordToken'])) AND Val(local.data['forgottenPasswordValidated'])>
	  <cfset local.isForgottenPasswordValidated = true>
    </cfif>
    <cfif NOT Len(Trim(local.data['commentToken'])) AND NOT local.isForgottenPasswordValidated>
    <!---x1x--->
      <CFQUERY NAME="local.qGetSalt" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblUser 
        WHERE E_mail = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['email']#"> AND SignUpValidated = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"> AND Suspend = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0">
      </CFQUERY>
      <cfif local.qGetSalt.RecordCount>
      <!---x2x--->
        <cfset local.salt = "">
        <cfset local.hashencryptedstring = "">
        <cfif local.qGetSalt.RecordCount>
          <cfset local.salt = local.qGetSalt.Salt>
          <cfset local.hashencryptedstring = local.qGetSalt.Password>
        </cfif>
        <cfif Len(Trim(local.data['password']))>
          <cftry>
            <cfset local.password = request.utils.Encrypts(local.data['password'],local.salt)>
            <cfcatch>
              <cfset local.password = "">
            </cfcatch>
          </cftry>
        <cfelse>
          <cfset local.password = "">
        </cfif>
        <cfset local.hashmatched = request.utils.HashMatched(local.password,local.hashencryptedstring,request.lckbcryptlib)>
        <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
          SELECT * 
          FROM tblUser 
          WHERE E_mail = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['email']#"> AND Salt = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.salt#">
        </CFQUERY>
        <!---<cfoutput>local.password: #local.password#</cfoutput>
        <cfoutput>local.hashmatched: #local.hashmatched#</cfoutput>--->
        <cfif local.qGetUser.RecordCount AND Len(Trim(local.data['password'])) AND local.hashmatched>
        <!---x3x--->
          <CFQUERY NAME="local.qGetUserID" DATASOURCE="#request.domain_dsn#">
            SELECT * 
            FROM tblUserToken 
            WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['userToken']#">
          </CFQUERY>
          <cfif NOT local.qGetUserID.RecordCount AND Len(Trim(local.data['userToken']))>
          <!---x4x--->
            <CFQUERY DATASOURCE="#request.domain_dsn#">
              INSERT INTO tblUserToken (User_ID,User_token) 
              VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUser.User_ID#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['userToken']#">)
            </CFQUERY>
            <cfset local.data['usertokenmatch'] = "No user token match, so new one was inserted">
          <cfelse>
          <!---x5x--->
            <cfif local.qGetUser.User_ID NEQ local.qGetUserID.User_ID>
            <!---x6x--->
              <cfset local.data['userToken'] = LCase(CreateUUID())>
              <CFQUERY NAME="qUpdateUserToken" DATASOURCE="#request.domain_dsn#">
                UPDATE tblUserToken
                SET User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['userToken']#"> 
                WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUser.User_ID#">
              </CFQUERY>
              <cfset local.data['usertokenmatch'] = "User token match, but belonged to different user, so old token updated with new token">
            <cfelse>
            <!---x7x--->
			  <cfset local.data['usertokenmatch'] = "User token match">
            </cfif>
          </cfif>
          <cfif Len(Trim(local.data['theme']))>
          <!---x8x--->
            <CFQUERY DATASOURCE="#request.domain_dsn#">
              UPDATE tblUser
              SET Keep_logged_in = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#local.data['keeploggedin']#">,Theme =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#ListLast(local.data['theme'],'-')#">  
              WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUser.User_ID#">
            </CFQUERY>
          </cfif>
          <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
            SELECT * 
            FROM tblUser 
            WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUser.User_ID#"> 
          </CFQUERY>
          <cfif local.qGetUser.RecordCount>
          <!---x9x--->
			<cfset local.data['userid'] = local.qGetUser.User_ID>
            <cfset local.data['forename'] = local.qGetUser.Forename>
            <cfset local.data['surname'] = local.qGetUser.Surname>
            <cfset local.data['salt'] = local.qGetUser.Salt>
            <cfset local.data['password'] = local.qGetUser.Password>
            <cfset local.data['authenticated'] = 1>
            <cfset local.data['cfid'] = local.qGetUser.Cfid>
            <cfset local.data['cftoken'] = local.qGetUser.Cftoken>
            <cfset local.data['signUpToken'] = local.qGetUser.SignUpToken>
            <cfset local.data['signUpValidated'] = local.qGetUser.SignUpValidated>
            <cfset local.data['avatarSrc'] = request.avatarbasesrc & local.qGetUser.Filename>
            <cfset local.data['emailNotification'] = local.qGetUser.Email_notification>
            <cfset local.data['theme'] = local.themeObj['stem'] & "-" & local.qGetUser.Theme>
            <cfset local.data['roleid'] = local.qGetUser.Role_ID>
            <cfset local.data['keeploggedin'] = local.data['keeploggedin']>
            <cfset local.data['submitArticleNotification'] = local.qGetUser.Submit_article_notification>
            <cfset local.data['cookieAcceptance'] = local.qGetUser.Cookie_acceptance>
            <cfset local.data['forgottenPasswordToken'] = local.qGetUser.ForgottenPasswordToken>
			<cfset local.data['forgottenPasswordValidated'] = local.qGetUser.ForgottenPasswordValidated>
            <cfset local.data['displayName'] = local.qGetUser.DisplayName>
            <cfset local.data['replyNotification'] = local.qGetUser.Reply_notification>
            <cfset local.data['threadNotification'] = local.qGetUser.Thread_notification>
            <cfset local.data['createdAt'] = local.qGetUser.Submission_date>
          </cfif>
        </cfif>
        <cfset local.data['error'] = "">
      <cfelse>
      <!---x10x--->
        <CFQUERY NAME="local.qGetEmail" DATASOURCE="#request.domain_dsn#">
          SELECT * 
          FROM tblUser 
          WHERE E_mail = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['email']#"> AND Suspend = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0">
        </CFQUERY>
        <cfif local.qGetEmail.RecordCount>
        <!---x11x--->
		  <cfset local.data['error'] = "User has registered but has not validated e-mail">
        <cfelse>
        <!---x12x--->
          <CFQUERY NAME="local.qGetEmail" DATASOURCE="#request.domain_dsn#">
            SELECT * 
            FROM tblUser 
            WHERE E_mail = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['email']#"> AND Suspend = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1">
          </CFQUERY>
          <cfif local.qGetEmail.RecordCount>
			<cfset local.data['error'] = "User's account has been temporarily suspended for security reasons">
          <cfelse>
			<cfset local.data['error'] = "User has not registered">
          </cfif>
        </cfif>
      </cfif>
    <cfelseif Len(Trim(local.data['commentToken'])) AND NOT local.isForgottenPasswordValidated>
      <CFQUERY NAME="local.qGetComment" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblComment 
        WHERE Token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['commentToken']#"> 
      </CFQUERY>
      <cfif local.qGetComment.RecordCount>
        <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
          SELECT * 
          FROM tblUser INNER JOIN tblFile ON tblUser.User_ID = tblFile.User_ID
          WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.qGetComment.File_uuid#"> AND Suspend = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0">
        </CFQUERY>
        <cfif local.qGetUser.RecordCount>
          <CFQUERY NAME="local.qGetUserID" DATASOURCE="#request.domain_dsn#">
            SELECT * 
            FROM tblUserToken 
            WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['userToken']#">
          </CFQUERY>
          <cfif NOT local.qGetUserID.RecordCount AND Len(Trim(local.data['userToken']))>
            <CFQUERY DATASOURCE="#request.domain_dsn#">
              INSERT INTO tblUserToken (User_ID,User_token) 
              VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUser.User_ID#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['userToken']#">)
            </CFQUERY>
            <cfset local.data['usertokenmatch'] = "no user token match, so new one was inserted">
          <cfelse>
            <cfif local.qGetUser.User_ID NEQ local.qGetUserID.User_ID>
              <cfset local.data['userToken'] = LCase(CreateUUID())>
              <CFQUERY DATASOURCE="#request.domain_dsn#">
                UPDATE tblUserToken
                SET User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['userToken']#"> 
                WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUser.User_ID#">
              </CFQUERY>
              <cfset local.data['usertokenmatch'] = "user token match, but belonged to different user, so old token updated with new token">
            </cfif>
            <cfset local.data['usertokenmatch'] = "user token match">
          </cfif>
          <cfif Len(Trim(local.data['theme']))>
            <CFQUERY DATASOURCE="#request.domain_dsn#">
              UPDATE tblUser
              SET Theme =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#ListLast(local.data['theme'],'-')#">  
              WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUser.User_ID#">
            </CFQUERY>
          </cfif>
          <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
            SELECT * 
            FROM tblUser 
            WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUser.User_ID#"> 
          </CFQUERY>
          <cfif local.qGetUser.RecordCount>
			<cfset local.data['userid'] = local.qGetUser.User_ID>
            <cfset local.data['forename'] = local.qGetUser.Forename>
            <cfset local.data['surname'] = local.qGetUser.Surname>
            <cfset local.data['email'] = local.qGetUser.E_mail>
            <cfset local.data['salt'] = local.qGetUser.Salt>
            <cfset local.data['password'] = local.qGetUser.Password>
            <cfset local.data['authenticated'] = 1>
            <cfset local.data['cfid'] = local.qGetUser.Cfid>
            <cfset local.data['cftoken'] = local.qGetUser.Cftoken>
            <cfset local.data['signUpToken'] = local.qGetUser.SignUpToken>
            <cfset local.data['signUpValidated'] = local.qGetUser.SignUpValidated>
            <cfset local.data['avatarSrc'] = request.avatarbasesrc & local.qGetUser.Filename>
            <cfset local.data['emailNotification'] = local.qGetUser.Email_notification>
            <cfset local.data['theme'] = local.themeObj['stem'] & "-" & local.qGetUser.Theme>
            <cfset local.data['roleid'] = local.qGetUser.Role_ID>
            <cfset local.data['keeploggedin'] = local.qGetUser.Keep_logged_in>
            <cfset local.data['submitArticleNotification'] = local.qGetUser.Submit_article_notification>
            <cfset local.data['commentid'] = local.qGetComment.Comment_ID>
            <cfset local.data['fileUuid'] = local.qGetComment.File_uuid>
            <cfset local.data['cookieAcceptance'] = local.qGetUser.Cookie_acceptance>
            <cfset local.data['forgottenPasswordToken'] = local.qGetUser.ForgottenPasswordToken>
			<cfset local.data['forgottenPasswordValidated'] = local.qGetUser.ForgottenPasswordValidated>
            <cfset local.data['displayName'] = local.qGetUser.DisplayName>
            <cfset local.data['replyNotification'] = local.qGetUser.Reply_notification>
            <cfset local.data['threadNotification'] = local.qGetUser.Thread_notification>
            <cfset local.data['createdAt'] = local.qGetUser.Submission_date>
            <cfset local.data['error'] = "">
          </cfif>
        </cfif>
      </cfif>
	<cfelseif local.isForgottenPasswordValidated>
      <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblUser 
        WHERE ForgottenPasswordToken = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['forgottenPasswordToken']#"> AND ForgottenPasswordValidated = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"> AND Suspend = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0">
      </CFQUERY>
      <cfif local.qGetUser.RecordCount>
        <CFQUERY DATASOURCE="#request.domain_dsn#">
          UPDATE tblUser
          SET ForgottenPasswordToken = <cfqueryparam cfsqltype="cf_sql_varchar" value="">, ForgottenPasswordValidated = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0">
          WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUser.User_ID#">
        </CFQUERY>
        <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
          SELECT * 
          FROM tblUser 
          WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUser.User_ID#">
        </CFQUERY>
        <cfif local.qGetUser.RecordCount>
          <CFQUERY NAME="local.qGetUserID" DATASOURCE="#request.domain_dsn#">
            SELECT * 
            FROM tblUserToken 
            WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['userToken']#">
          </CFQUERY>
          <cfif NOT local.qGetUserID.RecordCount AND Len(Trim(local.data['userToken']))>
            <CFQUERY DATASOURCE="#request.domain_dsn#">
              INSERT INTO tblUserToken (User_ID,User_token) 
              VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUser.User_ID#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['userToken']#">)
            </CFQUERY>
            <cfset local.data['usertokenmatch'] = "no user token match, so new one was inserted">
          <cfelse>
            <cfif local.qGetUser.User_ID NEQ local.qGetUserID.User_ID>
              <cfset local.data['userToken'] = LCase(CreateUUID())>
              <CFQUERY DATASOURCE="#request.domain_dsn#">
                UPDATE tblUserToken
                SET User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['userToken']#"> 
                WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUser.User_ID#">
              </CFQUERY>
              <cfset local.data['usertokenmatch'] = "user token match, but belonged to different user, so old token updated with new token">
            </cfif>
            <cfset local.data['usertokenmatch'] = "user token match">
          </cfif>
          <cfif Len(Trim(local.data['theme']))>
            <CFQUERY DATASOURCE="#request.domain_dsn#">
              UPDATE tblUser
              SET Theme =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#ListLast(local.data['theme'],'-')#">  
              WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUser.User_ID#">
            </CFQUERY>
          </cfif>
          <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
            SELECT * 
            FROM tblUser 
            WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUser.User_ID#"> 
          </CFQUERY>
          <cfif local.qGetUser.RecordCount>
			<cfset local.data['userid'] = local.qGetUser.User_ID>
            <cfset local.data['forename'] = local.qGetUser.Forename>
            <cfset local.data['surname'] = local.qGetUser.Surname>
            <cfset local.data['email'] = local.qGetUser.E_mail>
            <cfset local.data['salt'] = local.qGetUser.Salt>
            <cfset local.data['password'] = local.qGetUser.Password>
            <cfset local.data['authenticated'] = 1>
            <cfset local.data['cfid'] = local.qGetUser.Cfid>
            <cfset local.data['cftoken'] = local.qGetUser.Cftoken>
            <cfset local.data['signUpToken'] = local.qGetUser.SignUpToken>
            <cfset local.data['signUpValidated'] = local.qGetUser.SignUpValidated>
            <cfset local.data['avatarSrc'] = request.avatarbasesrc & local.qGetUser.Filename>
            <cfset local.data['emailNotification'] = local.qGetUser.Email_notification>
            <cfset local.data['theme'] = local.themeObj['stem'] & "-" & local.qGetUser.Theme>
            <cfset local.data['roleid'] = local.qGetUser.Role_ID>
            <cfset local.data['keeploggedin'] = local.qGetUser.Keep_logged_in>
            <cfset local.data['submitArticleNotification'] = local.qGetUser.Submit_article_notification>
            <cfset local.data['cookieAcceptance'] = local.qGetUser.Cookie_acceptance>
            <cfset local.data['forgottenPasswordToken'] = local.qGetUser.ForgottenPasswordToken>
			<cfset local.data['forgottenPasswordValidated'] = local.qGetUser.ForgottenPasswordValidated>
            <cfset local.data['isForgottenPasswordValidated'] = 1>
            <cfset local.data['displayName'] = local.qGetUser.DisplayName>
            <cfset local.data['replyNotification'] = local.qGetUser.Reply_notification>
            <cfset local.data['threadNotification'] = local.qGetUser.Thread_notification>
            <cfset local.data['createdAt'] = local.qGetUser.Submission_date>
            <cfset local.data['error'] = "">
          </cfif>
        </cfif>
      </cfif>
    </cfif>
	<cfset local.data['jwtToken'] = request.utils.EncryptJwt(usertoken=local.data['userToken'],jwtid=local.jwtid,data=local.data)>
    <!---<cfabort />--->
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>