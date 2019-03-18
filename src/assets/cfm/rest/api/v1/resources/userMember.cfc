
<cfcomponent extends="taffy.core.resource" taffy_uri="/user/{usertoken}">

  <cffunction name="get">
    <cfargument name="usertoken" type="string" required="yes" />
    <cfargument name="userid" type="numeric" required="no" default="0" />
	<cfset var local = StructNew()>
    <cfset local.themeObj = request.utils.createTheme(request.theme)>
    <cfset local.data = StructNew()>
	<cfset local.data['userid'] = arguments.userid>
    <cfset local.data['forename'] = "">
    <cfset local.data['surname'] = "">
    <cfset local.data['email'] = "">
    <cfset local.data['salt'] = "">
    <cfset local.data['password'] = "">
    <cfset local.data['usertoken'] = arguments.usertoken EQ 'empty' ? '' : arguments.usertoken>
    <cfset local.data['signuptoken'] = "">
    <cfset local.data['signUpValidated'] = 0>
    <cfset local.data['avatarSrc'] = "">
    <cfset local.data['emailNotification'] = 1>
    <cfset local.data['theme'] = local.themeObj['default']>
    <cfset local.data['roleid'] = 2>
    <cfset local.data['keeploggedin'] = 0>
    <cfset local.data['submitArticleNotification'] = 1>
    <cfset local.data['cookieAcceptance'] = 0>
    <cfset local.data['createdat'] = "">
    <cfset local.data['error'] = "">
    <CFQUERY NAME="local.qGetUserID" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUserToken 
      WHERE <cfif NOT Val(local.data['userid'])>User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['usertoken']#"><cfelse>User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.data['userid']#"></cfif>
    </CFQUERY>
    <cfif local.qGetUserID.RecordCount>
      <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblUser 
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUserID.User_ID#">
      </CFQUERY>
      <cfif local.qGetUser.RecordCount>
        <cfset local.data['userid'] = local.qGetUser.User_ID>
        <cfset local.data['forename'] = local.qGetUser.Forename>
        <cfset local.data['surname'] = local.qGetUser.Surname>
        <cfset local.data['email'] = local.qGetUser.E_mail>
        <cfset local.data['salt'] = local.qGetUser.Salt>
        <cfset local.data['password'] = local.qGetUser.Password>
        <cfset local.data['signuptoken'] = local.qGetUser.SignUpToken>
        <cfset local.data['signUpValidated'] = local.qGetUser.SignUpValidated>
        <cfset local.data['avatarSrc'] = request.avatarbasesrc & local.qGetUser.Filename>
        <cfset local.data['emailNotification'] = local.qGetUser.Email_notification>
        <cfset local.data['theme'] = local.themeObj['stem'] & "-" & local.qGetUser.Theme>
        <cfset local.data['roleid'] = local.qGetUser.Role_ID>
        <cfset local.data['keeploggedin'] = local.qGetUser.Keep_logged_in>
        <cfset local.data['submitArticleNotification'] = local.qGetUser.Submit_article_notification>
        <cfset local.data['cookieAcceptance'] = local.qGetUser.Cookie_acceptance>
        <cfset local.data['createdat'] = local.qGetUser.Submission_date>
      </cfif>
      <cfset local.data['error'] = "">
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

  <cffunction name="post">
    <cfargument name="usertoken" type="string" required="yes" />
	<cfset var local = StructNew()>
    <cfset var emailtemplateheaderbackground = request.utils.getMaterialThemePrimaryColour(theme=request.theme)>
    <cfset var emailtemplatemessage = "">
	<cfset local.uploadfolder = request.uploadfolder>
    <cfset local.signuptoken = LCase(CreateUUID())>
    <cfset local.emailsubject = "Validate e-mail from " & request.title>
    <cfset local.data = StructNew()>
	<cfset local.data['userid'] = 0>
    <cfset local.data['forename'] = "">
    <cfset local.data['surname'] = "">
    <cfset local.data['email'] = "">
    <cfset local.data['salt'] = request.crptographykey>
    <cfset local.data['password'] = "">
    <cfset local.data['usertoken'] = arguments.usertoken EQ 'empty' ? '' : arguments.usertoken>
    <cfset local.data['cfid'] = "">
    <cfset local.data['cftoken'] = "">
    <cfset local.data['signuptoken'] = local.signuptoken>
    <cfset local.data['signUpValidated'] = 0>
    <cfset local.data['roleid'] = 2>
    <cfset local.data['createdat'] = "">
    <cfset local.data['testEmail'] = false>
    <cfset local.data['cookieAcceptance'] = 0>
    <cfset local.data['error'] = "">
    <cfset local.requestBody = getHttpRequestData().headers>
    <cftry>
	  <cfif StructKeyExists(local.requestBody,"forename")>
		<cfset local.data['forename'] = Trim(local.requestBody['forename'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"surname")>
		<cfset local.data['surname'] = Trim(local.requestBody['surname'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"email")>
		<cfset local.data['email'] = Trim(local.requestBody['email'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"password")>
      	<cfset local.data['password'] = Trim(local.requestBody['password'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"cfid")>
      	<cfset local.data['cfid'] = Trim(local.requestBody['cfid'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"cftoken")>
      	<cfset local.data['cftoken'] = Trim(local.requestBody['cftoken'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"testEmail")>
      	<cfset local.data['testEmail'] = Trim(local.requestBody['testEmail'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"cookieAcceptance")>
      	<cfset local.data['cookieAcceptance'] = Trim(local.requestBody['cookieAcceptance'])>
      </cfif>
      <cfcatch>
		  <cfset local.data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
    <cfset local.emailpassword = Decrypt(request.emailPassword,request.emailSalt,request.crptographyalgorithm,request.crptographyencoding)>
    <cfif local.data['testEmail']>
      <cfset local.salutation = "Charlie">
      <cfsavecontent variable="emailtemplatemessage">
        <cfoutput>
          <h1>Hi<cfif Len(Trim(local.salutation))> #local.salutation#</cfif></h1>
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
                <a href="#local.uploadfolder#/index.cfm?signUpToken=#local.data['signuptoken']#">Validate E-mail</a>
              </td>
            </tr>
          </table>
        </cfoutput>
      </cfsavecontent>
      <cfmail to="#request.email#" from="#request.email#" server="#request.emailServer#" username="#request.emailUsername#" password="#local.emailpassword#" port="#request.emailPort#" useSSL="#request.emailUseSsl#" useTLS="#request.emailUseTls#" subject="#local.emailsubject#" type="html">
        <cfinclude template="../../../../email-template.cfm">
      </cfmail>
      <cfabort />
    </cfif>
    <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUser 
      WHERE E_mail = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['email']#">
    </CFQUERY>
    <cfif NOT local.qGetUser.RecordCount AND Len(Trim(local.data['email'])) AND FindNoCase("@",local.data['email']) AND Len(Trim(local.data['password']))>
      <cfset local.encryptedstring = request.utils.Encrypts(local.data['password'],local.data['salt'])>
      <cfset local.data['password'] = request.utils.Hashed(local.encryptedstring,request.lckbcryptlib)>
      <cfset local.forename = request.utils.CapFirst(local.data['forename'])>
      <cfset local.surname = request.utils.CapFirst(local.data['surname'])>
      <CFQUERY DATASOURCE="#request.domain_dsn#" result="local.queryInsertResult">
        INSERT INTO tblUser (Salt,Password,E_mail,Forename,Surname,Cfid,Cftoken,SignUpToken,Cookie_acceptance) 
        VALUES (<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['salt']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['password']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['email']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.forename#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.surname#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['cfid']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['cftoken']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['signuptoken']#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#local.data['cookieAcceptance']#">)
      </CFQUERY>
      <cfset local.data['userid'] = local.queryInsertResult.generatedkey>
      <CFQUERY NAME="local.qGetUserID" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblUserToken 
        WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['usertoken']#">
      </CFQUERY>
      <cfif NOT local.qGetUserID.RecordCount>
        <CFQUERY DATASOURCE="#request.domain_dsn#">
          INSERT INTO tblUserToken (User_ID,User_token) 
          VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.data['userid']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['usertoken']#">)
        </CFQUERY>
      </cfif>
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
                <strong>#request.title# would like to welcome you to our community</strong><br /><br />
                Thank you for taking an interest.<br />
                To complete the sign up process, please follow the link below:
              </td>
            </tr>
            <tr>
              <td colspan="3">
                <p>Please validate e-mail:</p>
                <a href="#local.uploadfolder#/index.cfm?signUpToken=#local.data['signuptoken']#">Validate E-mail</a>
              </td>
            </tr>
          </table>
        </cfoutput>
      </cfsavecontent>
      <cfmail to="#local.data['email']#" from="#request.email#" server="#request.emailServer#" username="#request.emailUsername#" password="#local.emailpassword#" port="#request.emailPort#" useSSL="#request.emailUseSsl#" useTLS="#request.emailUseTls#" subject="#local.emailsubject#" type="html">
        <cfinclude template="../../../../email-template.cfm">
      </cfmail>
      <cfset local.data['error'] = "">
    <cfelse>
      <cfset local.data['error'] = "User already registered">
    </cfif>
	<cfreturn representationOf(local.data) />
  </cffunction>
  
  <cffunction name="put">
    <cfargument name="usertoken" type="string" required="yes" />
	<cfset var local = StructNew()>
    <cfset local.themeObj = request.utils.createTheme(request.theme)>
    <cfset local.jwtString = "">
    <cfset local.data = StructNew()>
	<cfset local.data['userid'] = 0>
    <cfset local.data['forename'] = "">
    <cfset local.data['surname'] = "">
    <cfset local.data['email'] = "">
    <cfset local.data['salt'] = "">
    <cfset local.data['password'] = "">
    <cfset local.data['usertoken'] = arguments.usertoken EQ 'empty' ? '' : arguments.usertoken>
    <cfset local.data['cfid'] = "">
    <cfset local.data['cftoken'] = "">
    <cfset local.data['signUpToken'] = "">
    <cfset local.data['signUpValidated'] = 0>
    <cfset local.data['avatarSrc'] = "">
    <cfset local.data['emailNotification'] = 1>
    <cfset local.data['theme'] = local.themeObj['default']>
    <cfset local.data['roleid'] = 2>
    <cfset local.data['keeploggedin'] = 0>
    <cfset local.data['submitArticleNotification'] = 1>
    <cfset local.data['cookieAcceptance'] = 0>
    <cfset local.data['createdAt'] = "">
    <cfset local.data['jwtObj'] = StructNew()>
    <cfset local.data['error'] = "">
    <cfset local.requestBody = getHttpRequestData().headers>
    <cftry>
	  <cfif StructKeyExists(local.requestBody,"forename")>
      	<cfset local.data['forename'] = Trim(local.requestBody['forename'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"surname")>
      	<cfset local.data['surname'] = Trim(local.requestBody['surname'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"password")>
      	<cfset local.data['password'] = Trim(local.requestBody['password'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"emailNotification")>
      	<cfset local.data['emailNotification'] = Trim(local.requestBody['emailNotification'])>
        <cfset local.data['emailNotification'] = local.data['emailNotification'] ? 1 : 0>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"theme")>
      	<cfset local.data['theme'] = Trim(local.requestBody['theme'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"userid")>
      	<cfset local.data['userid'] = Trim(local.requestBody['userid'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"Authorization")>
        <cfset local.jwtString = request.utils.GetJwtString(Trim(local.requestBody['Authorization']))>
      </cfif>
      <cfcatch>
		<cfset local.data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
    <!---<cfdump var="#local.data#" output="C:\Users\Charles Robertson\Desktop\cfdump1.htm" format="html" />--->
    <!---<cfdump var="#getHttpRequestData().headers#" abort />--->
    <cfinclude template="../../../../jwt-decrypt.cfm">
	<cfif StructKeyExists(local.data['jwtObj'],"jwtAuthenticated") AND NOT local.data['jwtObj']['jwtAuthenticated']>
      <cfreturn representationOf(local.data).withStatus(403,"Not Authorized") />
    </cfif>
    <CFQUERY NAME="local.qGetUserID" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUserToken 
      WHERE <cfif NOT Val(local.data['userid'])>User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['usertoken']#"><cfelse>User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.data['userid']#"></cfif>
    </CFQUERY>
    <cfif local.qGetUserID.RecordCount>
	  <cfset local.data['userid'] = local.qGetUserID.User_ID>
    </cfif>
    <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUser 
      WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.data['userid']#">
    </CFQUERY>
    <cfif local.qGetUser.RecordCount>
      <cfif Len(Trim(local.data['password']))>
        <cftry>
          <cfset local.encryptedstring = request.utils.Encrypts(local.data['password'],local.qGetUser.Salt)>
          <cfcatch>
            <cfset local.encryptedstring = "">
          </cfcatch>
        </cftry>
      <cfelse>
        <cfset local.encryptedstring = "">
      </cfif>
      <cfif Len(Trim(local.encryptedstring))>
        <cfset local.data['password'] = request.utils.Hashed(local.encryptedstring,request.lckbcryptlib)>
      <cfelse>
        <cfset local.data['password'] = "">
      </cfif>
      <CFQUERY DATASOURCE="#request.domain_dsn#">
        UPDATE tblUser
        SET <cfif Len(Trim(local.data['password']))>Password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['password']#">,</cfif>Forename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.utils.CapFirst(local.data['forename'])#">,Surname =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.utils.CapFirst(local.data['surname'])#">,Email_notification =  <cfqueryparam cfsqltype="cf_sql_tinyint" value="#local.data['emailNotification']#">,Theme = <cfqueryparam cfsqltype="cf_sql_varchar" value="#ListLast(local.data['theme'],'-')#"> 
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.data['userid']#">
      </CFQUERY>
      <cfset local.data['password'] = local.qGetUser.Password>
      <cfset local.data['email'] = local.qGetUser.E_mail>
      <cfset local.data['salt'] = local.qGetUser.Salt>
      <cfset local.data['cfid'] = local.qGetUser.Cfid>
      <cfset local.data['cftoken'] = local.qGetUser.Cftoken>
      <cfset local.data['signUpToken'] = local.qGetUser.SignUpToken>
      <cfset local.data['signUpValidated'] = local.qGetUser.SignUpValidated>
      <cfset local.data['avatarSrc'] = request.avatarbasesrc & local.qGetUser.Filename>
      <cfset local.data['roleid'] = local.qGetUser.Role_ID>
      <cfset local.data['keeploggedin'] = local.qGetUser.Keep_logged_in>
      <cfset local.data['submitArticleNotification'] = local.qGetUser.Submit_article_notification>
      <cfset local.data['cookieAcceptance'] = local.qGetUser.Cookie_acceptance>
      <cfset local.data['createdAt'] = local.qGetUser.Submission_date>
      <cfset local.data['error'] = "">
    <cfelse>
      <cfset local.data['error'] = "User is not registered">
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>
  
  <cffunction name="delete">
    <cfargument name="usertoken" type="string" required="yes" />
	<cfset var local = StructNew()>
    <cfset local.jwtString = "">
    <cfset local.data = StructNew()>
	<cfset local.data['userid'] = 0>
    <cfset local.data['usertoken'] = arguments.usertoken EQ 'empty' ? '' : arguments.usertoken>
    <cfset local.data['jwtObj'] = StructNew()>
    <cfset local.data['error'] = "">
    <cfset local.requestBody = getHttpRequestData().headers>
    <cftry>
	  <cfif StructKeyExists(local.requestBody,"userid")>
		<cfset local.data['userid'] = Trim(local.requestBody['userid'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"Authorization")>
        <cfset local.jwtString = request.utils.GetJwtString(Trim(local.requestBody['Authorization']))>
      </cfif>
      <cfcatch>
		<cfset local.data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
    <cfinclude template="../../../../jwt-decrypt.cfm">
	<cfif StructKeyExists(local.data['jwtObj'],"jwtAuthenticated") AND NOT local.data['jwtObj']['jwtAuthenticated']>
      <cfreturn representationOf(local.data).withStatus(403,"Not Authorized") />
    </cfif>
    <CFQUERY NAME="local.qGetUserID" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUserToken 
      WHERE <cfif NOT Val(local.data['userid'])>User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['usertoken']#"><cfelse>User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.data['userid']#"></cfif>
    </CFQUERY>
    <cfif local.qGetUserID.RecordCount>
	  <cfset local.data['userid'] = local.qGetUserID.User_ID>
    </cfif>
    <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUser 
      WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.data['userid']#">
    </CFQUERY>
    <cfif local.qGetUser.RecordCount>
      <CFQUERY NAME="local.qGetFile" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblFile 
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.data['userid']#">
      </CFQUERY>
      <cfloop query="local.qGetFile">
        <cfset local.timestamp = DateFormat(Now(),'yyyymmdd') & TimeFormat(Now(),'HHmmss')>
        <cfset local.sourceimagepath = ReplaceNoCase(local.qGetFile.ImagePath,"/","\","ALL")>
        <cfset local.source = request.filepath & "\" & local.sourceimagepath>
        <cfif FileExists(local.source)>
          <cflock name="delete_file_#local.timestamp#" type="exclusive" timeout="30">
            <cffile action="delete"  file="#local.source#" />
          </cflock>
        </cfif>
        <cfset local.source = request.filepath & "\user-avatars\" & local.qGetUser.Filename>
        <cfif FileExists(local.source)>
          <cflock name="delete_file_#local.timestamp#" type="exclusive" timeout="30">
            <cffile action="delete"  file="#local.source#" />
          </cflock>
        </cfif>
        <cfset local.directory = request.filepath & "\article-images\" & local.qGetFile.File_ID>
        <cfdirectory action="list" directory="#local.directory#" name="local.qGetArticleImages" type="file" recurse="no" />
        <cfif local.qGetArticleImages.RecordCount>
          <cfif DirectoryExists(local.directory)>
			<cfset local._directory = local.directory>
            <cfloop query="local.qGetArticleImages">
			  <cfset local.source = local._directory & "\" & local.qGetArticleImages.Name>
              <cflock name="delete_file_#local.timestamp#" type="exclusive" timeout="30">
                <cffile action="delete"  file="#local.source#" />
              </cflock>
            </cfloop>
            <cftry>
              <cflock name="delete_file_directory_#local.timestamp#" type="exclusive" timeout="30">
                <cfdirectory action="delete" directory="#local.directory#">
              </cflock>
              <cfcatch>
              </cfcatch>
            </cftry>
          </cfif>
        </cfif>
      </cfloop>
      <CFQUERY DATASOURCE="#request.domain_dsn#">
        DELETE 
        FROM tblUser
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.data['userid']#">
      </CFQUERY>
      <CFQUERY DATASOURCE="#request.domain_dsn#">
        DELETE 
        FROM tblUsertoken
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.data['userid']#">
      </CFQUERY>
      <CFQUERY DATASOURCE="#request.domain_dsn#">
        DELETE 
        FROM tblFile
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.data['userid']#">
      </CFQUERY>
      <CFQUERY DATASOURCE="#request.domain_dsn#">
        DELETE 
        FROM tblFileUser
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.data['userid']#">
      </CFQUERY>
      <CFQUERY DATASOURCE="#request.domain_dsn#">
        DELETE
        FROM tblComment
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.data['userid']#">
      </CFQUERY>
      <cfset local.data['error'] = "">
    <cfelse>
      <cfset local.data['error'] = "User is not registered">
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>