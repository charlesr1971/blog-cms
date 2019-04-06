
<cfcomponent extends="taffy.core.resource" taffy_uri="/image/{fileUuid}">

  <cffunction name="get">
    <cfargument name="fileUuid" type="string" required="yes" />
    <cfargument name="fileid" type="numeric" required="no" default="0" />
    <cfargument name="commentid" type="numeric" required="no" default="0" />
    <cfset var local = StructNew()>
    <cfset local['userToken'] = "">
    <cfset local['userid'] = 0>
    <cfset local.data = StructNew()>
    <cfset local.data['error'] = "">
    <cfset local.requestBody = getHttpRequestData().headers>
    <cftry>
	  <cfif StructKeyExists(local.requestBody,"userToken")>
      	<cfset local['userToken'] = Trim(local.requestBody['userToken'])>
      </cfif>
      <cfcatch>
        <cfset local.data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
    <CFQUERY NAME="local.qGetUserID" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUserToken 
      WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local['userToken']#">
    </CFQUERY>
    <cfif local.qGetUserID.RecordCount>
	  <cfset local['userid'] = local.qGetUserID.User_ID>
    </cfif>
    <CFQUERY NAME="local.qGetFile" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblFile 
      WHERE <cfif NOT Val(arguments.fileid)>File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fileUuid#"><cfelse>File_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fileid#"></cfif> AND (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(local['userid'])> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local['userid']#">)</cfif>)  
    </CFQUERY>
    <cfif local.qGetFile.RecordCount>
      <cfset local.data['userid'] = local.qGetFile.User_ID>
      <cfset local.data['fileid'] = local.qGetFile.File_ID>
      <cfset local.data['category'] = local.qGetFile.Category>
      <cfset local.data['src'] = local.qGetFile.ImagePath>
      <cfset local.data['fileUuid'] = local.qGetFile.File_uuid>
      <cfset local.data['author'] = request.utils.FormatTitle(local.qGetFile.Author)>
      <cfset local.data['title'] = request.utils.FormatTitle(local.qGetFile.Title)>
      <cfset local.data['description'] = local.qGetFile.Description>
      <cfset local.data['article'] = local.qGetFile.Article>
      <cfset local.data['size'] = local.qGetFile.Size>
      <cfset local.data['likes'] = local.qGetFile.Likes>
      <cfset local.data['imagePath'] = local.qGetFile.ImagePath>
      <cfset local.data['tags'] = local.qGetFile.Tags>
      <cfset local.data['commentid'] = arguments.commentid>
      <cfset local.data['publishArticleDate'] = local.qGetFile.Publish_article_date>
      <cfset local.data['approved'] = local.qGetFile.Approved>
      <cfdirectory action="list" directory="#request.filepath#\article-images\#local.qGetFile.File_ID#" name="local.qGetArticleImages" type="file" recurse="no" />
      <cfset local.data['tinymceArticleImageCount'] = local.qGetArticleImages.RecordCount>
      <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblUser 
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetFile.User_ID#">
      </CFQUERY>
      <cfif local.qGetUser.RecordCount>
        <cfset local.data['submitArticleNotification'] = local.qGetUser.Submit_article_notification>
      </cfif>
      <cfset local.data['createdAt'] = local.qGetFile.Submission_date>
    <cfelse>
	  <cfset local.data['error'] = "Record could not be found">
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>
  
  <cffunction name="post">
    <cfargument name="fileUuid" type="string" required="yes" />
    <cfargument name="data" type="any" required="no" default="" />
    <cfset var emailtemplateheaderbackground = request.utils.getMaterialThemePrimaryColour(theme=request.theme)>
    <cfset var emailtemplatemessage = "">
    <cfset var local = StructNew()>
    <cfset local.imagePath = "">
    <cfset local.uploadfolder = request.uploadfolder>
    <cfset local.extensions = "gif,png,jpg,jpeg">
    <cfset local.timestamp = DateFormat(Now(),'yyyymmdd') & TimeFormat(Now(),'HHmmss')>
    <cfset local.fileid = LCase(CreateUUID())>
    <cfset local.filetoken = LCase(CreateUUID())>
    <cfset local.filename = "">
    <cfset local.maxcontentlength = request.maxcontentlength>
    <cfset local.submissiondate = Now()>
    <cfset local.emailsubject = "Image post creation notification e-mail from " & request.title>
    <cfset local.jwtString = "">
    <cfset local.data = StructNew()>
    <cfset local.data['fileid'] = 0>
    <cfset local.data['clientfileName'] = "">
    <cfset local.data['imagePath'] = "">
    <cfset local.data['name'] = "">
    <cfset local.data['title'] = "">
    <cfset local.data['description'] = "">
    <cfset local.data['article'] = "">
    <cfset local.data['tags'] = "">
    <cfset local.data['publishArticleDate'] = Now()>
    <cfset local.data['tinymceArticleDeletedImages'] = ArrayNew(1)>
    <cfset local.data['fileExtension'] = "">
    <cfset local.data['selectedFile'] = "">
    <cfset local.data['success'] = false>
    <cfset local.data['content_length'] = 0>
    <cfset local.data['fileUuid'] = local.fileid>
    <cfset local.data['userId'] = 0>
    <cfset local.data['cfid'] = "">
    <cfset local.data['cftoken'] = "">
    <cfset local.data['uploadType'] = "">
    <cfset local.data['avatarSrc'] = "">
    <cfset local.data['emailSent'] = 0>
    <cfset local.data['userToken'] = "">
    <cfset local.data['jwtObj'] = StructNew()>
    <cfset local.data['error'] = "">
    <cfset local.requestBody = getHttpRequestData().headers>
    <cftry>
	  <cfif StructKeyExists(local.requestBody,"file-name")>
		<cfset local.data['clientfileName'] = Trim(local.requestBody['file-name'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"image-path")>
		<cfset local.data['imagePath'] = Trim(local.requestBody['image-path'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"name")>
		<cfset local.data['name'] = Trim(local.requestBody['name'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"title")>
		<cfset local.data['title'] = Trim(local.requestBody['title'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"description")>
		<cfset local.data['description'] = Trim(local.requestBody['description'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"article")>
		<cfset local.data['article'] = Trim(local.requestBody['article'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"tags")>
		<cfset local.data['tags'] = Trim(local.requestBody['tags'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"publish-article-date")>
		<cfset local.data['publishArticleDate'] = Trim(local.requestBody['publish-article-date'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"tinymce-article-deleted-images")>
		<cfset local.data['tinymceArticleDeletedImages'] = Trim(local.requestBody['tinymce-article-deleted-images'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"file-extension")>
		<cfset local.data['fileExtension'] = Trim(local.requestBody['file-extension'])>
      </cfif>
      <cfset local.data['selectedFile'] = getHttpRequestData().content>
      <cfif StructKeyExists(local.requestBody,"content-length")>
		<cfset local.data['content_length'] = Trim(local.requestBody['content-length'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"user-token")>
      	<cfset local.data['userToken'] = Trim(local.requestBody['user-token'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"cfid")>
      	<cfset local.data['cfid'] = Trim(local.requestBody['cfid'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"cftoken")>
      	<cfset local.data['cftoken'] = Trim(local.requestBody['cftoken'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"upload-type")>
      	<cfset local.data['uploadType'] = Trim(local.requestBody['upload-type'])>
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
    <cfset local.emailpassword = Decrypt(request.emailPassword,request.emailSalt,request.crptographyalgorithm,request.crptographyencoding)>
    <CFQUERY NAME="local.qGetUserID" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUserToken 
      WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['userToken']#">
    </CFQUERY>
    <cfif local.qGetUserID.RecordCount>
      <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblUser 
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUserID.User_ID#">
      </CFQUERY>
      <cfif local.qGetUser.RecordCount>
        <cfset local.data['userId'] = local.qGetUser.User_ID>
      </cfif>
    </cfif>
    <cfif CompareNoCase(local.data['uploadType'],"gallery") EQ 0 AND Len(Trim(local.data['imagePath'])) AND Len(Trim(local.data['fileExtension'])) AND ListFindNoCase(local.extensions,local.data['fileExtension']) AND IsBinary(local.data['selectedFile']) AND IsNumeric(local.data['content_length']) AND Val(local.data['userId']) AND Len(Trim(local.data['name'])) AND Len(Trim(local.data['title'])) AND Len(Trim(local.data['description']))>
      <cfif local.data['content_length'] LT local.maxcontentlength>
        <cfset local.imagePath = REReplaceNoCase(local.data['imagePath'],"[/]+","/","ALL")>
        <cfset local.imageSystemPath = ReplaceNoCase(local.imagePath,"/","\","ALL")>
        <cfset local.imageSystemPath = request.filepath & local.imageSystemPath>
        <cfset local.author = REReplaceNoCase(local.data['name'],"[[:punct:]]","","ALL")>
        <cfset local.author = REReplaceNoCase(local.author,"[\s]+"," ","ALL")>
        <cfset local.author = Trim(local.author)>
        <cfset local.author = request.utils.FormatTitle(local.author)>
        <cfset local.title = REReplaceNoCase(local.data['title'],"[[:punct:]]","","ALL")>
        <cfset local.title = REReplaceNoCase(local.title,"[0-9]+","","ALL")>
        <cfset local.title = REReplaceNoCase(local.title,"[\s]+"," ","ALL")>
        <cfset local.title = Trim(local.title)>
        <cfset local.title = request.utils.FormatTitle(local.title)>
        <cfif DirectoryExists(local.imageSystemPath)>
          <cfset local.newfilename = local.fileid & "." & local.data['fileExtension']>
		  <cfset local.secureRandomSystemSecurePath = request.securefilepath & "\" & LCase(CreateUUID())>
          <cfset local.imageSystemSecureFilePath = local.secureRandomSystemSecurePath & "\" & local.newfilename>
          <cfif NOT DirectoryExists(local.secureRandomSystemSecurePath)>
            <cflock name="create_directory_#local.timestamp#" type="exclusive" timeout="30">
              <cfdirectory action="create" directory="#local.secureRandomSystemSecurePath#" />
            </cflock>
            <cflock name="write_file_#local.timestamp#" type="exclusive" timeout="30">
              <cffile action="write" file="#local.imageSystemSecureFilePath#" output="#local.data['selectedFile']#" />
            </cflock>
          </cfif>
          <cfif FileExists(local.imageSystemSecureFilePath) AND DirectoryExists(local.imageSystemPath)>
			<cfset local.imagePath = REReplaceNoCase(local.imagePath,"^/","")>
            <cfset local.data['imagePath'] = local.imagePath & "/" & local.fileid & "." & local.data['fileExtension']>           
            <cfset local.isWebImageFile = request.utils.IsWebImageFile(path=local.imageSystemSecureFilePath)>
            <cfif NOT local.isWebImageFile>
              <cflock name="delete_file_#local.timestamp#" type="exclusive" timeout="30">
                <cffile action="delete"  file="#local.imageSystemSecureFilePath#" />
              </cflock>
              <cfset local.data['success'] = false>
            <cfelse>
              <cflock name="move_file_#local.timestamp#" type="exclusive" timeout="30">
                <cffile action="move" source="#local.imageSystemSecureFilePath#" destination="#local.imageSystemPath#">
              </cflock>
              <cfset local.data['success'] = true>
            </cfif>
          <cfelse>
            <cfset local.data['success'] = false>
          </cfif>
          <cfif DirectoryExists(local.secureRandomSystemSecurePath)>
            <cflock name="delete_directory_#local.timestamp#" type="exclusive" timeout="30">
              <cfdirectory action="delete" directory="#local.secureRandomSystemSecurePath#" recurse="yes" />
            </cflock>
          </cfif>
        </cfif>
        <cfif local.data['success']>
		  <cfset local.filename = local.fileid & "." & local.data['fileExtension']>
          <cfset local.tags = request.utils.FormatTags(local.data['tags'])>
          <cfset local.data['article'] = request.utils.FormatTextForDatabase(local.data['article'])>
          <cftry>
            <cfset local.publishArticleDate = request.utils.CreateDateTimeFromMomentDate(local.data['publishArticleDate'])>
            <cfif NOT ISDATE(local.publishArticleDate)>
              <cfset local.publishArticleDate = Now()>
            </cfif>
            <cfcatch>
              <cfset local.publishArticleDate = Now()>
            </cfcatch>
          </cftry>
          <CFQUERY DATASOURCE="#request.domain_dsn#" result="local.queryInsertResult">
            INSERT INTO tblFile (User_ID,File_uuid,Category,Clientfilename,Filename,ImagePath,Author,Title,Description,Article,Size,Cfid,Cftoken,Tags,Publish_article_date,Approved,FileToken,Submission_date) 
            VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.data['userId']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#LCase(local.fileid)#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#ListLast(local.imagePath,'/')#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['clientfileName']#">,<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#local.filename#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['imagePath']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.author#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.title#">,<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#request.utils.CapFirstSentence(local.data['description'],true)#">,<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#local.data['article']#">,<cfqueryparam cfsqltype="cf_sql_integer" value="#Val(local.data['content_length'])#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['cfid']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['cftoken']#">,<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#local.tags#">,<cfqueryparam cfsqltype="cf_sql_timestamp" value="#local.publishArticleDate#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="0">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.filetoken#">,<cfqueryparam cfsqltype="cf_sql_timestamp" value="#local.submissiondate#">)
          </CFQUERY>
          <cfset local.data['fileid'] = local.queryInsertResult.generatedkey>
          <cfif IsArray(local.data['tinymceArticleDeletedImages'])>
            <cfset request.utils.RemoveTinymceArticleImage(local.data['tinymceArticleDeletedImages'])>
          </cfif>
          <cfset local.data['publishArticleDate'] = local.publishArticleDate>
          <cfset local.data['error'] = "">
        <cfelse>
		  <cfset local.data['error'] = "The image uploaded was not the correct file type">
        </cfif>
      <cfelse>
        <cfset local.maxcontentlengthInMb = NumberFormat(local.maxcontentlength/1000000,".__")>
        <cfset local.data['error'] = "The image uploaded must be less than " & local.maxcontentlengthInMb & "MB">
      </cfif>
    <cfelseif CompareNoCase(local.data['uploadType'],"avatar") EQ 0>  
      <cfif local.data['content_length'] LT local.maxcontentlength>
        <cfset local.imageSystemPath = request.filepath & "\user-avatars">
        <cfif DirectoryExists(local.imageSystemPath)>
          <cfif local.qGetUserID.RecordCount>
            <cfif local.qGetUser.RecordCount>
              <cfif Len(Trim(local.qGetUser.Filename))>
                <cfset local.source = local.imageSystemPath & "\" & local.qGetUser.Filename>
                <cfif FileExists(local.source)>
                  <cflock name="delete_file_#local.timestamp#" type="exclusive" timeout="30">
                    <cffile action="delete"  file="#local.source#" />
                  </cflock>
                </cfif>
              </cfif>
            </cfif>
          </cfif>
          <cfset local.newfilename = local.fileid & "." & local.data['fileExtension']>
		  <cfset local.secureRandomSystemSecurePath = request.securefilepath & "\" & LCase(CreateUUID())>
          <cfset local.imageSystemSecureFilePath = local.secureRandomSystemSecurePath & "\" & local.newfilename>
          <cfif NOT DirectoryExists(local.secureRandomSystemSecurePath)>
            <cflock name="create_directory_#local.timestamp#" type="exclusive" timeout="30">
              <cfdirectory action="create" directory="#local.secureRandomSystemSecurePath#" />
            </cflock>
            <cflock name="write_file_#local.timestamp#" type="exclusive" timeout="30">
              <cffile action="write" file="#local.imageSystemSecureFilePath#" output="#local.data['selectedFile']#" />
            </cflock>
          </cfif>
          <cfif FileExists(local.imageSystemSecureFilePath) AND DirectoryExists(local.imageSystemPath)>
            <cfset local.isWebImageFile = request.utils.IsWebImageFile(path=local.imageSystemSecureFilePath)>
            <cfif NOT local.isWebImageFile>
              <cflock name="delete_file_#local.timestamp#" type="exclusive" timeout="30">
                <cffile action="delete"  file="#local.imageSystemSecureFilePath#" />
              </cflock>
              <cfset local.data['success'] = false>
            <cfelse>
              <cflock name="move_file_#local.timestamp#" type="exclusive" timeout="30">
                <cffile action="move" source="#local.imageSystemSecureFilePath#" destination="#local.imageSystemPath#">
              </cflock>
              <cfset local.data['success'] = true>
            </cfif>
          <cfelse>
            <cfset local.data['success'] = false>
          </cfif>
          <cfif DirectoryExists(local.secureRandomSystemSecurePath)>
            <cflock name="delete_directory_#local.timestamp#" type="exclusive" timeout="30">
              <cfdirectory action="delete" directory="#local.secureRandomSystemSecurePath#" recurse="yes" />
            </cflock>
          </cfif>
        </cfif>
        <cfif local.data['success']>
		  <cfset local.filename = local.fileid & "." & local.data['fileExtension']>
          <CFQUERY DATASOURCE="#request.domain_dsn#">
            UPDATE tblUser
            SET Clientfilename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['clientfileName']#">,Filename = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#local.filename#">
            WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.data['userId']#">
          </CFQUERY>
          <cfset local.data['avatarSrc'] = request.avatarbasesrc & local.filename>
          <cfset local.data['error'] = "">
        <cfelse>
		  <cfset local.data['error'] = "The image uploaded was not the correct file type">
        </cfif>
      <cfelse>
        <cfset local.maxcontentlengthInMb = NumberFormat(local.maxcontentlength/1000000,".__")>
        <cfset local.data['error'] = "The image uploaded must be less than " & local.maxcontentlengthInMb & "MB">
      </cfif>
    <cfelse>
      <cfset local.data['error'] = "Data uploaded was insufficient to complete the submission">
    </cfif>
    <cfset local.adminuserid = request.utils.GetRandomAdminUserID(roleid="6,7")>
    <CFQUERY NAME="local.qGetAdmin" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUser 
      WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.adminuserid#">
    </CFQUERY>
    <CFQUERY NAME="local.qGetFileAuthor" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUser INNER JOIN tblFile ON tblUser.User_ID = tblFile.User_ID
      WHERE tblFile.File_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.data['fileid']#">
    </CFQUERY>
    <cfif NOT Len(Trim(local.data['error'])) AND CompareNoCase(local.data['uploadType'],"gallery") EQ 0 AND local.qGetAdmin.RecordCount AND Len(Trim(local.qGetAdmin.E_mail)) AND FindNoCase("@",local.qGetAdmin.E_mail) AND local.qGetFileAuthor.RecordCount>
      <cfset local.salutation = request.utils.CapFirst(LCase(local.qGetAdmin.Forename))>
      <cfsavecontent variable="emailtemplatemessage">
        <cfoutput>
          <h1>Hi<cfif Len(Trim(local.salutation))> #local.salutation#</cfif></h1>
          <table cellpadding="0" cellspacing="0" border="0" width="100%">
            <tr valign="middle">
              <td width="10" bgcolor="##DDDDDD"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="10" height="1" /></td>
              <td width="20"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="20" height="1" /></td>
              <td style="font-size:16px;">
                <strong>The following post, entitled '#request.utils.FormatTitle(local.data['title'])#', has been created</strong><br /><br />
                #request.utils.CapFirstSentence(local.data['description'],true)#
              </td>
            </tr>
            <tr>
              <td colspan="3">
                <p><strong>Author:</strong></p>
                #request.utils.CapFirst(LCase(local.qGetFileAuthor.Forename))# #request.utils.CapFirst(LCase(local.qGetFileAuthor.Surname))#<br />
                <em>#DateFormat(local.submissiondate,"medium")# #TimeFormat(local.submissiondate,"medium")#</em>
              </td>
            </tr>
            <tr>
              <td colspan="3">
                <p><strong>Name:</strong></p>
                #local.data['name']#<br />
              </td>
            </tr>
            <cfif Len(Trim(local.imagePath))>
              <tr>
                <td colspan="3">
                  <p><strong>Image Path:</strong></p>
                  #local.imagePath#
                </td>
              </tr>
            </cfif>
            <tr>
              <td colspan="3">
                <p>
                  <img src="#local.uploadfolder#/#local.qGetFileAuthor.ImagePath#" style="width:100%" border="0" />
                </p>
              </td>
            </tr>
            <tr>
              <td colspan="3">
                <p><strong>To approve the post, please follow the link below</strong></p>
                <a href="#local.uploadfolder#/index.cfm?fileToken=#local.filetoken#" style="display:block;width:200px;margin:20px auto 0px;text-align:center;padding:20px 30px;border-radius:4px;background:#emailtemplateheaderbackground#;color:##ffffff;text-decoration:none;font-weight:bold;">Approve Post</a>
              </td>
            </tr>
          </table>
        </cfoutput>
      </cfsavecontent>
      <cfmail to="#local.qGetAdmin.E_mail#" from="#request.email#" server="#request.emailServer#" username="#request.emailUsername#" password="#local.emailpassword#" port="#request.emailPort#" useSSL="#request.emailUseSsl#" useTLS="#request.emailUseTls#" subject="#local.emailsubject#" type="html">
        <cfinclude template="../../../../email-template.cfm">
      </cfmail>
      <cfset local.data['emailSent'] = 1>
    </cfif>
    <cfif IsBinary(local.data['selectedFile'])>
      <cfset local.data['selectedFile'] = "">
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

  <cffunction name="put">
    <cfargument name="fileUuid" type="string" required="yes" />
    <cfset var emailtemplateheaderbackground = request.utils.getMaterialThemePrimaryColour(theme=request.theme)>
    <cfset var emailtemplatemessage = "">
    <cfset var local = StructNew()>
    <cfset local.imagePath = "">
    <cfset local.uploadfolder = request.uploadfolder>
    <cfset local.tags = "">
    <cfset local.timestamp = DateFormat(Now(),'yyyymmdd') & TimeFormat(Now(),'HHmmss')>
    <cfset local.filetoken = LCase(CreateUUID())>
    <cfset local.submissiondate = Now()>
    <cfset local.emailsubject = "Image post update notification e-mail from " & request.title>
    <cfset local.jwtString = "">
    <cfset local.authorized = true>
    <cfset local.data = StructNew()>
    <cfset local.data['fileid'] = 0>
	<cfset local.data['fileUuid'] = arguments.fileUuid>
    <cfset local.data['imagePath'] = "">
    <cfset local.data['name'] = "">
    <cfset local.data['title'] = "">
    <cfset local.data['description'] = "">
    <cfset local.data['article'] =  "">
    <cfset local.data['tags'] = "">
    <cfset local.data['publishArticleDate'] = Now()>
    <cfset local.data['tinymceArticleDeletedImages'] = ArrayNew(1)>
    <cfset local.data['tinymceArticleImageCount'] = 0>
    <cfset local.data['submitArticleNotification'] = 1>
    <cfset local.data['emailSent'] = 0>
    <cfset local.data['userToken'] = "">
    <cfset local.data['jwtObj'] = StructNew()>
    <cfset local.data['error'] = "">
    <cfset local.requestBody = getHttpRequestData().headers>
    <cftry>
	  <cfif StructKeyExists(local.requestBody,"imagePath")>
		<cfset local.data['imagePath'] = Trim(local.requestBody['imagePath'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"name")>
		<cfset local.data['name'] =  Trim(local.requestBody['name'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"title")>
		<cfset local.data['title'] =  Trim(local.requestBody['title'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"description")>
		<cfset local.data['description'] =  Trim(local.requestBody['description'])>
      </cfif>
      <cfset local.data['article'] =  DeserializeJSON(Trim(ToString(getHttpRequestData().content)))>
      <cfif StructKeyExists(local.data['article'],"article")>
		<cfset local.data['article'] =  local.data['article']['article']>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"tags")>
		<cfset local.data['tags'] =  Trim(local.requestBody['tags'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"publishArticleDate")>
		<cfset local.data['publishArticleDate'] =  ReplaceNoCase(Trim(local.requestBody['publishArticleDate']),'"',"","ALL")>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"tinymceArticleDeletedImages")>
		<cfset local.data['tinymceArticleDeletedImages'] =  Trim(local.requestBody['tinymceArticleDeletedImages'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"submitArticleNotification")>
		<cfset local.data['submitArticleNotification'] =  Trim(local.requestBody['submitArticleNotification'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"userToken")>
		<cfset local.data['userToken'] =  Trim(local.requestBody['userToken'])>
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
    <cfset local.imagemembersecurityusertoken = "">
    <cfif StructKeyExists(local.data['jwtObj'],"userToken") AND Len(Trim(local.data['jwtObj']['userToken']))>
	  <cfset local.imagemembersecurityusertoken = local.data['jwtObj']['userToken']>
    </cfif>
    <cfset local.imagemembersecurityfileuuid = arguments.fileUuid>
    <cfinclude template="../../../../file-security.cfm">
	<cfif NOT local.authorized>
      <cfreturn representationOf(local.data).withStatus(403,"Not Authorized") />
    </cfif>
    <cfset local.emailpassword = Decrypt(request.emailPassword,request.emailSalt,request.crptographyalgorithm,request.crptographyencoding)>
    <CFQUERY NAME="local.qGetFile" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblFile 
      WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['fileUuid']#"> 
    </CFQUERY>
    <cfif local.qGetFile.RecordCount AND Len(Trim(local.data['imagePath']))>
	  <cfset local.data['fileid'] = local.qGetFile.File_ID>
      <cfset local.imagePath = REReplaceNoCase(local.data['imagePath'],"[/]+","/","ALL")>
      <cfset local.imageSystemPath = ReplaceNoCase(local.imagePath,"/","\","ALL")>
      <cfset local.imageSystemPath = request.filepath & local.imageSystemPath & "\" & local.qGetFile.Filename>
      <cfset local.imagePath = REReplaceNoCase(local.imagePath,"^[/]+","")>
      <cfset local.imagePath = local.imagePath & "/" & local.qGetFile.Filename>
      <cfset local.category = ListLast(local.data['imagePath'],"/")>
      <cfif CompareNoCase(local.qGetFile.ImagePath,local.imagePath) NEQ 0>
        <cfset local.sourceimagepath = ReplaceNoCase(local.qGetFile.ImagePath,"/","\","ALL")>
        <cfset local.source = request.filepath & "\" & local.sourceimagepath>
        <cfif FileExists(local.source)>
          <cflock name="move_file_#local.timestamp#" type="exclusive" timeout="30">
            <cffile action="move" source="#local.source#" destination="#local.imageSystemPath#" />
          </cflock>
        </cfif>
      </cfif>
      <cfset local.tags = request.utils.FormatTags(local.data['tags'])>
      <cfset local.data['article'] = request.utils.FormatTextForDatabase(local.data['article'])>
      <cftry>
        <cfset local.publishArticleDate = request.utils.CreateDateTimeFromMomentDate(local.data['publishArticleDate'])>
        <cfif NOT ISDATE(local.publishArticleDate)>
          <cfset local.publishArticleDate = Now()>
        </cfif>
        <cfcatch>
          <cfset local.publishArticleDate = Now()>
        </cfcatch>
      </cftry>
	  <cfset local.title = REReplaceNoCase(local.data['title'],"[[:punct:]]","","ALL")>
      <cfset local.title = REReplaceNoCase(local.title,"[0-9]+","","ALL")>
      <cfset local.title = REReplaceNoCase(local.title,"[\s]+"," ","ALL")>
      <cfset local.title = Trim(local.title)>
      <cfset local.title = request.utils.FormatTitle(local.title)>
      <CFQUERY DATASOURCE="#request.domain_dsn#">
        UPDATE tblFile
        SET Category = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.category#">,ImagePath = <cfqueryparam cfsqltype="cf_sql_varchar" value="#imagepath#">,Author =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['name']#">,Title =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.title#">,Description =  <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#request.utils.CapFirstSentence(local.data['description'],true)#">,Tags =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.tags#">,Article =  <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#local.data['article']#">,Publish_article_date = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#local.publishArticleDate#">,Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0">,FileToken = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.filetoken#">
        WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['fileUuid']#"> 
      </CFQUERY>
      <cfif IsjSON(local.data['tinymceArticleDeletedImages'])>
        <cfset local.tinymceArticleDeletedImages = DeserializeJSON(local.data['tinymceArticleDeletedImages'])>
        <cfif IsArray(local.tinymceArticleDeletedImages)>
          <cfset request.utils.RemoveTinymceArticleImage(local.tinymceArticleDeletedImages)>
        </cfif>
      </cfif>
      <cfset request.utils.RemoveTinymceArticleOrphanImage(local.data['article'],local.qGetFile.File_ID)>
      <cfdirectory action="list" directory="#request.filepath#\article-images\#local.qGetFile.File_ID#" name="local.qGetArticleImages" type="file" recurse="no" />
      <cfset local.data['tinymceArticleImageCount'] = local.qGetArticleImages.RecordCount>
      <cfset local.data['publishArticleDate'] = local.publishArticleDate>
      <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblUser 
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetFile.User_ID#">
      </CFQUERY>
      <cfif local.qGetUser.RecordCount>
        <CFQUERY DATASOURCE="#request.domain_dsn#">
          UPDATE tblUser
          SET Submit_article_notification = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#local.data['submitArticleNotification']#">
          WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetFile.User_ID#">
        </CFQUERY>
      </cfif>
      <cfset local.data['error'] = "">
    <cfelse>
      <cfset local.data['error'] = "Record for this file cannot be found">
    </cfif>
    <cfset local.adminuserid = request.utils.GetRandomAdminUserID(roleid="6,7")>
    <CFQUERY NAME="local.qGetAdmin" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUser 
      WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.adminuserid#">
    </CFQUERY>
    <CFQUERY NAME="local.qGetFileAuthor" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUser INNER JOIN tblFile ON tblUser.User_ID = tblFile.User_ID
      WHERE tblFile.File_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.data['fileid']#">
    </CFQUERY>
    <cfif NOT Len(Trim(local.data['error'])) AND local.qGetAdmin.RecordCount AND Len(Trim(local.qGetAdmin.E_mail)) AND FindNoCase("@",local.qGetAdmin.E_mail) AND local.qGetFileAuthor.RecordCount>
      <cfset local.salutation = request.utils.CapFirst(LCase(local.qGetAdmin.Forename))>
      <cfsavecontent variable="emailtemplatemessage">
        <cfoutput>
          <h1>Hi<cfif Len(Trim(local.salutation))> #local.salutation#</cfif></h1>
          <table cellpadding="0" cellspacing="0" border="0" width="100%">
            <tr valign="middle">
              <td width="10" bgcolor="##DDDDDD"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="10" height="1" /></td>
              <td width="20"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="20" height="1" /></td>
              <td style="font-size:16px;">
                <strong>The following post, entitled '#request.utils.FormatTitle(local.data['title'])#', has been updated</strong><br /><br />
                #request.utils.CapFirstSentence(local.data['description'],true)#
              </td>
            </tr>
            <tr>
              <td colspan="3">
                <p><strong>Author:</strong></p>
                #request.utils.CapFirst(LCase(local.qGetFileAuthor.Forename))# #request.utils.CapFirst(LCase(local.qGetFileAuthor.Surname))#<br />
                <em>#DateFormat(local.submissiondate,"medium")# #TimeFormat(local.submissiondate,"medium")#</em>
              </td>
            </tr>
            <tr>
              <td colspan="3">
                <p><strong>Name:</strong></p>
                #local.data['name']#<br />
              </td>
            </tr>
            <cfif Len(Trim(local.imagePath))>
              <tr>
                <td colspan="3">
                  <p><strong>Image Path:</strong></p>
                  #local.imagePath#<br />
                </td>
              </tr>
            </cfif>
            <cfif Len(Trim(local.tags))>
              <tr>
                <td colspan="3">
                  <p><strong>Tags:</strong></p>
                  #local.tags#<br />
                </td>
              </tr>
            </cfif>
            <tr>
              <td colspan="3">
                <p>
                  <img src="#local.uploadfolder#/#local.qGetFileAuthor.ImagePath#" style="width:100%" border="0" />
                </p>
              </td>
            </tr>
            <cfif Len(Trim(local.data['article']))>
              <tr>
                <td colspan="3">
                  <p><strong>Article:</strong></p>
                  #local.data['article']#<br />
                </td>
              </tr>
            </cfif>
            <cfif Len(Trim(local.publishArticleDate))>
              <tr>
                <td colspan="3">
                  <p><strong>Publish Article Date:</strong></p>
                  #local.publishArticleDate#<br />
                </td>
              </tr>
            </cfif>
            <tr>
              <td colspan="3">
                <p><strong>To approve the updates, please follow the link below</strong></p>
                <a href="#local.uploadfolder#/index.cfm?fileToken=#local.filetoken#" style="display:block;width:200px;margin:20px auto 0px;text-align:center;padding:20px 30px;border-radius:4px;background:#emailtemplateheaderbackground#;color:##ffffff;text-decoration:none;font-weight:bold;">Approve Updates</a>
              </td>
            </tr>
          </table>
        </cfoutput>
      </cfsavecontent>
      <cfmail to="#local.qGetAdmin.E_mail#" from="#request.email#" server="#request.emailServer#" username="#request.emailUsername#" password="#local.emailpassword#" port="#request.emailPort#" useSSL="#request.emailUseSsl#" useTLS="#request.emailUseTls#" subject="#local.emailsubject#" type="html">
        <cfinclude template="../../../../email-template.cfm">
      </cfmail>
      <cfset local.data['emailSent'] = 1>
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>
  
  <cffunction name="delete">
    <cfargument name="fileUuid" type="string" required="yes" />
	<cfset var local = StructNew()>
    <cfset local.timestamp = DateFormat(Now(),'yyyymmdd') & TimeFormat(Now(),'HHmmss')>
    <cfset local.jwtString = "">
    <cfset local.authorized = true>
    <cfset local.data = StructNew()>
	<cfset local.data['fileUuid'] = arguments.fileUuid>
    <cfset local.data['userToken'] = "">
    <cfset local.data['jwtObj'] = StructNew()>
	<cfset local.data['error'] = "">
    <cfset local.requestBody = getHttpRequestData().headers>
    <cftry>
      <cfif StructKeyExists(local.requestBody,"userToken")>
		<cfset local.data['userToken'] =  Trim(local.requestBody['userToken'])>
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
    <cfset local.imagemembersecurityusertoken = "">
    <cfif StructKeyExists(local.data['jwtObj'],"userToken") AND Len(Trim(local.data['jwtObj']['userToken']))>
	  <cfset local.imagemembersecurityusertoken = local.data['jwtObj']['userToken']>
    </cfif>
    <cfset local.imagemembersecurityfileuuid = arguments.fileUuid>
    <cfinclude template="../../../../file-security.cfm">
	<cfif NOT local.authorized>
      <cfreturn representationOf(local.data).withStatus(403,"Not Authorized") />
    </cfif>
    <CFQUERY NAME="local.qGetFile" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblFile 
      WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['fileUuid']#"> 
    </CFQUERY>
    <cfif local.qGetFile.RecordCount>
      <cfset local.sourceimagepath = ReplaceNoCase(local.qGetFile.ImagePath,"/","\","ALL")>
      <cfset local.source = request.filepath & "\" & local.sourceimagepath>
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
      <CFQUERY DATASOURCE="#request.domain_dsn#">
        DELETE
        FROM tblFile
        WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['fileUuid']#"> 
      </CFQUERY>
      <CFQUERY DATASOURCE="#request.domain_dsn#">
        DELETE
        FROM tblFileUser
        WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['fileUuid']#"> 
      </CFQUERY>
      <CFQUERY DATASOURCE="#request.domain_dsn#">
        DELETE
        FROM tblComment
        WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['fileUuid']#"> 
      </CFQUERY>
      <cfset local.data['error'] = "">
    <cfelse>
      <cfset local.data['error'] = "Record for this file cannot be found">
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>