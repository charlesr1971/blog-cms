
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type,Authorization,userToken" />

<cfparam name="uploadfolder" default="#request.uploadfolder#" />
<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset data = StructNew()>
<cfset data['userid'] = 0>
<cfset data['error'] = "">

<cfset requestBody = toString(getHttpRequestData().content)>
<cfset requestBody = Trim(requestBody)>
<cftry>
  <cfset requestBody = DeserializeJSON(requestBody)>
  <cfif StructKeyExists(requestBody,"userid")>
  	<cfset data['userid'] = Trim(requestBody['userid'])>
  </cfif>
  <cfcatch>
    <cftry>
      <cfset requestBody = REReplaceNoCase(requestBody,"[\s+]"," ","ALL")>
      <cfset requestBody = DeserializeJSON(requestBody)>
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
<cfswitch expression="#request.userAccountDeleteSchema#">
  <cfcase value="1">
    <cfif qGetUser.RecordCount>
      <CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblFile 
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['userid']#">
      </CFQUERY>
      <cfloop query="qGetFile">
        <cfset timestamp = DateFormat(Now(),'yyyymmdd') & TimeFormat(Now(),'HHmmss')>
        <cfset sourceimagepath = ReplaceNoCase(qGetFile.ImagePath,"/","\","ALL")>
        <cfset source = request.filepath & "\" & sourceimagepath>
        <cfif FileExists(source)>
          <cflock name="delete_file_#timestamp#" type="exclusive" timeout="30">
            <cffile action="delete"  file="#source#" />
          </cflock>
          <cfset mediumImagePathName = getImageCopyName(path=source,suffix=imageMediumSuffix)>
		  <cfif FileExists(mediumImagePathName)>
            <cflock name="delete_file_#timestamp#" type="exclusive" timeout="30">
              <cffile action="delete"  file="#mediumImagePathName#" />
            </cflock>
          </cfif>
        </cfif>
        <cfset source = request.filepath & "\user-avatars\" & qGetUser.Filename>
        <cfif FileExists(source)>
          <cflock name="delete_file_#timestamp#" type="exclusive" timeout="30">
            <cffile action="delete"  file="#source#" />
          </cflock>
        </cfif>
        <cfset directory = request.filepath & "\article-images\" & qGetFile.File_ID>
        <cfdirectory action="list" directory="#directory#" name="qGetArticleImages" type="file" recurse="no" />
        <cfif qGetArticleImages.RecordCount>
          <cfif DirectoryExists(directory)>
            <cfset _directory = directory>
            <cfloop query="qGetArticleImages">
              <cfset source = _directory & "\" & qGetArticleImages.Name>
              <cflock name="delete_file_#timestamp#" type="exclusive" timeout="30">
                <cffile action="delete"  file="#source#" />
              </cflock>
            </cfloop>
            <cftry>
              <cflock name="delete_file_directory_#timestamp#" type="exclusive" timeout="30">
                <cfdirectory action="delete" directory="#directory#">
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
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['userid']#">
      </CFQUERY>
      <CFQUERY DATASOURCE="#request.domain_dsn#">
        DELETE 
        FROM tblUsertoken
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['userid']#">
      </CFQUERY>
      <CFQUERY DATASOURCE="#request.domain_dsn#">
        DELETE 
        FROM tblFile
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['userid']#">
      </CFQUERY>
      <CFQUERY DATASOURCE="#request.domain_dsn#">
        DELETE 
        FROM tblFileUser
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['userid']#">
      </CFQUERY>
      <CFQUERY DATASOURCE="#request.domain_dsn#">
        DELETE
        FROM tblComment
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['userid']#">
      </CFQUERY>
      <cfset data['error'] = "">
    <cfelse>
      <cfset data['error'] = "User is not registered">
    </cfif>
  </cfcase>
  <cfcase value="2">
    <cfif qGetUser.RecordCount>
      <cftransaction>
        <CFQUERY DATASOURCE="#request.domain_dsn#">
          INSERT INTO tblUserArchive (User_ID,Role_ID,Salt,Password,E_mail,Forename,Surname,Cfid,Cftoken,SignUpToken,SignUpValidated,Clientfilename,Filename,Email_notification,Keep_logged_in,Submit_article_notification,Cookie_acceptance,Theme,ForgottenPasswordToken,ForgottenPasswordValidated,Suspend) 
          VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#">,<cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.Role_ID#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetUser.Salt#" null="#yesNoFormat(NOT len(trim(qGetUser.Salt)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetUser.Password#" null="#yesNoFormat(NOT len(trim(qGetUser.Password)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetUser.E_mail#" null="#yesNoFormat(NOT len(trim(qGetUser.E_mail)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetUser.Forename#" null="#yesNoFormat(NOT len(trim(qGetUser.Forename)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetUser.Surname#" null="#yesNoFormat(NOT len(trim(qGetUser.Surname)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetUser.Cfid#" null="#yesNoFormat(NOT len(trim(qGetUser.Cfid)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetUser.Cftoken#" null="#yesNoFormat(NOT len(trim(qGetUser.Cftoken)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetUser.SignUpToken#" null="#yesNoFormat(NOT len(trim(qGetUser.SignUpToken)))#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#qGetUser.SignUpValidated#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetUser.Clientfilename#" null="#yesNoFormat(NOT len(trim(qGetUser.Clientfilename)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetUser.Filename#" null="#yesNoFormat(NOT len(trim(qGetUser.Filename)))#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#qGetUser.Email_notification#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#qGetUser.Keep_logged_in#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#qGetUser.Submit_article_notification#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#qGetUser.Cookie_acceptance#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetUser.Theme#" null="#yesNoFormat(NOT len(trim(qGetUser.Theme)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetUser.ForgottenPasswordToken#" null="#yesNoFormat(NOT len(trim(qGetUser.ForgottenPasswordToken)))#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#qGetUser.ForgottenPasswordValidated#" null="#yesNoFormat(NOT len(trim(qGetUser.ForgottenPasswordValidated)))#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#qGetUser.Suspend#" null="#yesNoFormat(NOT len(trim(qGetUser.Suspend)))#">)
        </CFQUERY>
        <CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
          SELECT * 
          FROM tblFile 
          WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['userid']#">
        </CFQUERY>
        <cfloop query="qGetFile">
          <CFQUERY DATASOURCE="#request.domain_dsn#">
            INSERT INTO tblFileArchive (File_ID,User_ID,File_uuid,Category,Clientfilename,Filename,ImagePath,Author,Title,Description,Article,Size,Likes,Cfid,Cftoken,Tags,Publish_article_date,Approved,Approved_previous,FileToken,Submission_date) 
            VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#qGetFile.File_ID#">,<cfqueryparam cfsqltype="cf_sql_integer" value="#qGetFile.User_ID#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetFile.File_uuid#" null="#yesNoFormat(NOT len(trim(qGetFile.File_uuid)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetFile.Category#" null="#yesNoFormat(NOT len(trim(qGetFile.Category)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetFile.Clientfilename#" null="#yesNoFormat(NOT len(trim(qGetFile.Clientfilename)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetFile.Filename#" null="#yesNoFormat(NOT len(trim(qGetFile.Filename)))#">,<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#qGetFile.ImagePath#" null="#yesNoFormat(NOT len(trim(qGetFile.ImagePath)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetFile.Author#" null="#yesNoFormat(NOT len(trim(qGetFile.Author)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetFile.Title#" null="#yesNoFormat(NOT len(trim(qGetFile.Title)))#">,<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#qGetFile.Description#" null="#yesNoFormat(NOT len(trim(qGetFile.Description)))#">,<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#qGetFile.Article#" null="#yesNoFormat(NOT len(trim(qGetFile.Article)))#">,<cfqueryparam cfsqltype="cf_sql_integer" value="#qGetFile.Size#">,<cfqueryparam cfsqltype="cf_sql_integer" value="0">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetFile.Cfid#" null="#yesNoFormat(NOT len(trim(qGetFile.Cfid)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetFile.Cftoken#" null="#yesNoFormat(NOT len(trim(qGetFile.Cftoken)))#">,<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#qGetFile.Tags#" null="#yesNoFormat(NOT len(trim(qGetFile.Tags)))#">,<cfqueryparam cfsqltype="cf_sql_timestamp" value="#qGetFile.Publish_article_date#" null="#yesNoFormat(NOT len(trim(qGetFile.Publish_article_date)))#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#qGetFile.Approved#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#qGetFile.Approved_previous#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetFile.FileToken#" null="#yesNoFormat(NOT len(trim(qGetFile.FileToken)))#">,<cfqueryparam cfsqltype="cf_sql_timestamp" value="#qGetFile.Submission_date#">)
          </CFQUERY>
        </cfloop>
        <CFQUERY DATASOURCE="#request.domain_dsn#">
          DELETE 
          FROM tblUser
          WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['userid']#">
        </CFQUERY>
        <CFQUERY DATASOURCE="#request.domain_dsn#">
          DELETE 
          FROM tblUsertoken
          WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['userid']#">
        </CFQUERY>
        <CFQUERY DATASOURCE="#request.domain_dsn#">
          DELETE 
          FROM tblFile
          WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['userid']#">
        </CFQUERY>
        <CFQUERY DATASOURCE="#request.domain_dsn#">
          DELETE 
          FROM tblFileUser
          WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['userid']#">
        </CFQUERY>
        <CFQUERY DATASOURCE="#request.domain_dsn#">
          DELETE
          FROM tblComment
          WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['userid']#">
        </CFQUERY>
      </cftransaction>
      <cfset data['error'] = "">
    <cfelse>
      <cfset data['error'] = "User is not registered">
    </cfif>
  </cfcase>
</cfswitch>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>