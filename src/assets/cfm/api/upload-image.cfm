
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="file-name,image-path,name,title,description,article,tags,publish-article-date,tinymce-article-deleted-images,file-extension,user-token,content-type,cfid,cftoken,upload-type,Authorization,userToken" />

<cfparam name="uploadfolder" default="#request.uploadfolder#" />
<cfparam name="extensions" default="gif,png,jpg,jpeg" />
<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="submissiondate" default="#Now()#" />
<cfparam name="emailsubject" default="Image post creation notification e-mail from #request.title#" />
<cfparam name="fileid" default="#LCase(CreateUUID())#" />
<cfparam name="filetoken" default="#LCase(CreateUUID())#" />
<cfparam name="filename" default="" />
<cfparam name="maxcontentlength" default="#request.maxcontentlength#" />
<cfparam name="submissiondate" default="#Now()#" />

<cfinclude template="../functions.cfm">

<cfset emailtemplateheaderbackground = getMaterialThemePrimaryColour(theme=request.theme)>

<cfset data = StructNew()>
<cfset data['clientfileName'] = "">
<cfset data['imagePath'] = "">
<cfset data['name'] = "">
<cfset data['title'] = "">
<cfset data['description'] = "">
<cfset data['article'] = "">
<cfset data['tags'] = "">
<cfset data['publishArticleDate'] = Now()>
<cfset data['tinymceArticleDeletedImages'] = ArrayNew(1)>
<cfset data['fileExtension'] = "">
<cfset data['selectedFile'] = "">
<cfset data['success'] = false>
<cfset data['error'] = "">
<cfset data['content_length'] = 0>
<cfset data['fileUuid'] = fileid>
<cfset data['userToken'] = "">
<cfset data['userId'] = 0>
<cfset data['cfid'] = cookie.cfid>
<cfset data['cftoken'] = cookie.cftoken>
<cfset data['uploadType'] = "">
<cfset data['avatarSrc'] = "">
<cfset data['emailSent'] = 0>

<cftry>
  <cfif StructKeyExists(getHttpRequestData().headers,"file-name")>
	<cfset data['clientfileName'] = getHttpRequestData().headers['file-name']>
  </cfif>
  <cfif StructKeyExists(getHttpRequestData().headers,"image-path")>
  	<cfset data['imagePath'] = getHttpRequestData().headers['image-path']>
  </cfif>
  <cfif StructKeyExists(getHttpRequestData().headers,"name")>
  	<cfset data['name'] = getHttpRequestData().headers['name']>
  </cfif>
  <cfif StructKeyExists(getHttpRequestData().headers,"title")>
  	<cfset data['title'] = getHttpRequestData().headers['title']>
  </cfif>
  <cfif StructKeyExists(getHttpRequestData().headers,"description")>
  	<cfset data['description'] = getHttpRequestData().headers['description']>
  </cfif>
  <cfif StructKeyExists(getHttpRequestData().headers,"article")>
  	<cfset data['article'] = getHttpRequestData().headers['article']>
  </cfif>
  <cfif StructKeyExists(getHttpRequestData().headers,"tags")>
  	<cfset data['tags'] = getHttpRequestData().headers['tags']>
  </cfif>
  <cfif StructKeyExists(getHttpRequestData().headers,"publish-article-date")>
  	<cfset data['publishArticleDate'] = getHttpRequestData().headers['publish-article-date']>
  </cfif>
  <cfif StructKeyExists(getHttpRequestData().headers,"tinymce-article-deleted-images")>
  	<cfset data['tinymceArticleDeletedImages'] = getHttpRequestData().headers['tinymce-article-deleted-images']>
  </cfif>
  <cfif StructKeyExists(getHttpRequestData().headers,"file-extension")>
  	<cfset data['fileExtension'] = getHttpRequestData().headers['file-extension']>
  </cfif>
  <cfset data['selectedFile'] = getHttpRequestData().content>
  <cfif StructKeyExists(getHttpRequestData().headers,"content-length")>
  	<cfset data['content_length'] = getHttpRequestData().headers['content-length']>
  </cfif>
  <cfif StructKeyExists(getHttpRequestData().headers,"user-token")>
  	<cfset data['userToken'] = getHttpRequestData().headers['user-token']>
  </cfif>
  <cfif StructKeyExists(getHttpRequestData().headers,"cfid")>
  	<cfset data['cfid'] = getHttpRequestData().headers['cfid']>
  </cfif>
  <cfif StructKeyExists(getHttpRequestData().headers,"cftoken")>
  <cfset data['cftoken'] = getHttpRequestData().headers['cftoken']>
  </cfif>
  <cfif StructKeyExists(getHttpRequestData().headers,"upload-type")>
  	<cfset data['uploadType'] = getHttpRequestData().headers['upload-type']>
  </cfif>
  <cfcatch>
	<cfset data['error'] = cfcatch.message>
  </cfcatch>
</cftry>

<cfset emailpassword = Decrypt(request.emailPassword,request.emailSalt,request.crptographyalgorithm,request.crptographyencoding)>

<CFQUERY NAME="qGetUserID" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblUserToken 
  WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['userToken']#">
</CFQUERY>

<cfif qGetUserID.RecordCount>
  <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
    SELECT * 
    FROM tblUser 
    WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUserID.User_ID#">
  </CFQUERY>
  <cfif qGetUser.RecordCount>
    <cfset data['userId'] = qGetUser.User_ID>
  </cfif>
</cfif>

<cfif CompareNoCase(data['uploadType'],"gallery") EQ 0 AND Len(Trim(data['imagePath'])) AND Len(Trim(data['fileExtension'])) AND ListFindNoCase(extensions,data['fileExtension']) AND IsBinary(data['selectedFile']) AND IsNumeric(data['content_length']) AND Val(data['userId']) AND Len(Trim(data['name'])) AND Len(Trim(data['title'])) AND Len(Trim(data['description']))>
  <cfif data['content_length'] LT maxcontentlength>
    <cfset imagePath = REReplaceNoCase(data['imagePath'],"[/]+","/","ALL")>
    <cfset imageSystemPath = ReplaceNoCase(imagePath,"/","\","ALL")>
    <cfset imageSystemPath = request.filepath & imageSystemPath>
    <cfset author = REReplaceNoCase(data['name'],"[[:punct:]]","","ALL")>
	<cfset author = REReplaceNoCase(author,"[\s]+"," ","ALL")>
    <cfset author = Trim(author)>
    <cfset author = FormatTitle(author)>
    <cfset title = REReplaceNoCase(data['title'],"[[:punct:]]","","ALL")>
	<cfset title = REReplaceNoCase(title,"[\s]+"," ","ALL")>
    <cfset title = Trim(title)>
    <cfset title = FormatTitle(title)>
    <cfif DirectoryExists(imageSystemPath)>
      <cfset newfilename = fileid & "." & data['fileExtension']>
	  <cfset secureRandomSystemSecurePath = request.securefilepath & "\" & LCase(CreateUUID())>
      <cfset imageSystemSecureFilePath = secureRandomSystemSecurePath & "\" & newfilename>
      <cfif NOT DirectoryExists(secureRandomSystemSecurePath)>
        <cflock name="create_directory_#timestamp#" type="exclusive" timeout="30">
          <cfdirectory action="create" directory="#secureRandomSystemSecurePath#" />
        </cflock>
        <cflock name="write_file_#timestamp#" type="exclusive" timeout="30">
          <cffile action="write" file="#imageSystemSecureFilePath#" output="#data['selectedFile']#" />
        </cflock>
      </cfif>
      <cfif FileExists(imageSystemSecureFilePath) AND DirectoryExists(imageSystemPath)>
        <cfset imagePath = REReplaceNoCase(imagePath,"^/","")>
        <cfset data['imagePath'] = imagePath & "/" & fileid & "." & data['fileExtension']>           
        <cfset isWebImageFile = IsWebImageFile(path=imageSystemSecureFilePath)>
        <cfif NOT isWebImageFile>
          <cflock name="delete_file_#timestamp#" type="exclusive" timeout="30">
            <cffile action="delete"  file="#imageSystemSecureFilePath#" />
          </cflock>
          <cfset data['success'] = false>
        <cfelse>
          <cflock name="move_file_#timestamp#" type="exclusive" timeout="30">
            <cffile action="move" source="#imageSystemSecureFilePath#" destination="#imageSystemPath#">
          </cflock>
          <cfset data['success'] = true>
        </cfif>
      <cfelse>
        <cfset data['success'] = false>
      </cfif>
      <cfif DirectoryExists(secureRandomSystemSecurePath)>
        <cflock name="delete_directory_#timestamp#" type="exclusive" timeout="30">
          <cfdirectory action="delete" directory="#secureRandomSystemSecurePath#" recurse="yes" />
        </cflock>
      </cfif>
    </cfif>
    <cfif data['success']>
	  <cfset filename = fileid & "." & data['fileExtension']>
      <cfset tags = FormatTags(data['tags'])>
      <cfset data['article'] = FormatTextForDatabase(data['article'])>
      <cftry>
        <cfset publishArticleDate = CreateDateTimeFromMomentDate(data['publishArticleDate'])>
        <cfif NOT ISDATE(publishArticleDate)>
          <cfset publishArticleDate = Now()>
        </cfif>
        <cfcatch>
          <cfset publishArticleDate = Now()>
        </cfcatch>
      </cftry>
      <CFQUERY DATASOURCE="#request.domain_dsn#" result="queryInsertResult">
        INSERT INTO tblFile (User_ID,File_uuid,Category,Clientfilename,Filename,ImagePath,Author,Title,Description,Article,Size,Cfid,Cftoken,Tags,Publish_article_date,Approved,FileToken,Submission_date) 
        VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#data['userId']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#LCase(fileid)#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#ListLast(imagePath,'/')#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['clientfileName']#">,<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#filename#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['imagePath']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#author#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#title#">,<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#CapFirstSentence(data['description'],true)#">,<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#data['article']#">,<cfqueryparam cfsqltype="cf_sql_integer" value="#Val(data['content_length'])#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['cfid']#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#data['cftoken']#">,<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#tags#">,<cfqueryparam cfsqltype="cf_sql_timestamp" value="#publishArticleDate#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="0">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#filetoken#">,<cfqueryparam cfsqltype="cf_sql_timestamp" value="#submissiondate#">)
      </CFQUERY>
      <cfset data['fileid'] = queryInsertResult.generatedkey>
      <cfif IsArray(data['tinymceArticleDeletedImages'])>
        <cfset RemoveTinymceArticleImage(data['tinymceArticleDeletedImages'])>
      </cfif>
      <cfset data['publishArticleDate'] = publishArticleDate>
      <cfset data['error'] = "">
    <cfelse>
	  <cfset data['error'] = "The image uploaded was not the correct file type">
    </cfif>
  <cfelse>
	<cfset maxcontentlengthInMb = NumberFormat(maxcontentlength/1000000,".__")>
    <cfset data['error'] = "The image uploaded must be less than " & maxcontentlengthInMb & "MB">
  </cfif>
<cfelseif CompareNoCase(data['uploadType'],"avatar") EQ 0>  
  <cfif data['content_length'] LT maxcontentlength>
	<cfset imageSystemPath = request.filepath & "\user-avatars">
	<cfif DirectoryExists(imageSystemPath)>
      <cfif qGetUserID.RecordCount>
        <cfif qGetUser.RecordCount>
		  <cfif Len(Trim(qGetUser.Filename))>
            <cfset source = imageSystemPath & "\" & qGetUser.Filename>
            <cfif FileExists(source)>
              <cflock name="delete_file_#timestamp#" type="exclusive" timeout="30">
                <cffile action="delete"  file="#source#" />
              </cflock>
            </cfif>
          </cfif>
        </cfif>
      </cfif>
      <cfset newfilename = fileid & "." & data['fileExtension']>
	  <cfset secureRandomSystemSecurePath = request.securefilepath & "\" & LCase(CreateUUID())>
      <cfset imageSystemSecureFilePath = secureRandomSystemSecurePath & "\" & newfilename>
      <cfif NOT DirectoryExists(secureRandomSystemSecurePath)>
        <cflock name="create_directory_#timestamp#" type="exclusive" timeout="30">
          <cfdirectory action="create" directory="#secureRandomSystemSecurePath#" />
        </cflock>
        <cflock name="write_file_#timestamp#" type="exclusive" timeout="30">
          <cffile action="write" file="#imageSystemSecureFilePath#" output="#data['selectedFile']#" />
        </cflock>
      </cfif>
      <cfif FileExists(imageSystemSecureFilePath) AND DirectoryExists(imageSystemPath)>
        <cfset isWebImageFile = IsWebImageFile(path=imageSystemSecureFilePath)>
        <cfif NOT isWebImageFile>
          <cflock name="delete_file_#timestamp#" type="exclusive" timeout="30">
            <cffile action="delete"  file="#imageSystemSecureFilePath#" />
          </cflock>
          <cfset data['success'] = false>
        <cfelse>
          <cflock name="move_file_#timestamp#" type="exclusive" timeout="30">
            <cffile action="move" source="#imageSystemSecureFilePath#" destination="#imageSystemPath#">
          </cflock>
          <cfset data['success'] = true>
        </cfif>
      <cfelse>
        <cfset data['success'] = false>
      </cfif>
      <cfif DirectoryExists(secureRandomSystemSecurePath)>
        <cflock name="delete_directory_#timestamp#" type="exclusive" timeout="30">
          <cfdirectory action="delete" directory="#secureRandomSystemSecurePath#" recurse="yes" />
        </cflock>
      </cfif>
    </cfif>
    <cfif data['success']>
	  <cfset filename = fileid & "." & data['fileExtension']>
      <CFQUERY NAME="qUpdateUser" DATASOURCE="#request.domain_dsn#">
        UPDATE tblUser
        SET Clientfilename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['clientfileName']#">,Filename = <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#filename#">
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['userId']#">
      </CFQUERY>
      <cfset data['avatarSrc'] = request.avatarbasesrc & filename>
      <cfset data['error'] = "">
    <cfelse>
	  <cfset data['error'] = "The image uploaded was not the correct file type">
    </cfif>
  <cfelse>
	<cfset maxcontentlengthInMb = NumberFormat(maxcontentlength/1000000,".__")>
    <cfset data['error'] = "The image uploaded must be less than " & maxcontentlengthInMb & "MB">
  </cfif>
<cfelse>
  <cfset data['error'] = "Data uploaded was insufficient to complete the submission">
</cfif>

<cfset adminuserid = GetRandomAdminUserID(roleid="6,7")>

<CFQUERY NAME="qGetAdmin" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblUser 
  WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#adminuserid#">
</CFQUERY>
<CFQUERY NAME="qGetFileAuthor" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblUser INNER JOIN tblFile ON tblUser.User_ID = tblFile.User_ID
  WHERE tblFile.File_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['fileid']#">
</CFQUERY>
<cfif NOT Len(Trim(data['error'])) AND CompareNoCase(data['uploadType'],"gallery") EQ 0 AND qGetAdmin.RecordCount AND Len(Trim(qGetAdmin.E_mail)) AND FindNoCase("@",qGetAdmin.E_mail) AND qGetFileAuthor.RecordCount>
  <cfset salutation = CapFirst(LCase(qGetAdmin.Forename))>
  <cfsavecontent variable="emailtemplatemessage">
    <cfoutput>
      <h1>Hi<cfif Len(Trim(salutation))> #salutation#</cfif></h1>
      <table cellpadding="0" cellspacing="0" border="0" width="100%">
        <tr valign="middle">
          <td width="10" bgcolor="##DDDDDD"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="10" height="1" /></td>
          <td width="20"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="20" height="1" /></td>
          <td style="font-size:16px;">
            <strong>The following post has been created, entitled '#FormatTitle(data['title'])#'</strong><br /><br />
            #CapFirstSentence(data['description'],true)#
          </td>
        </tr>
        <tr>
          <td colspan="3">
            <p><strong>Author:</strong></p>
            #CapFirst(LCase(qGetFileAuthor.Forename))# #CapFirst(LCase(qGetFileAuthor.Surname))#<br />
            <em>#DateFormat(submissiondate,"medium")# #TimeFormat(submissiondate,"medium")#</em>
          </td>
        </tr>
        <tr>
          <td colspan="3">
            <p><strong>Name:</strong></p>
            #data['name']#<br />
          </td>
        </tr>
        <cfif Len(Trim(imagePath))>
          <tr>
            <td colspan="3">
              <p><strong>Image Path:</strong></p>
              #imagePath#
            </td>
          </tr>
        </cfif>
        <tr>
          <td colspan="3">
            <img src="#uploadfolder#/#qGetFileAuthor.ImagePath#" style="width:100%" border="0" /><br />
          </td>
        </tr>
        <tr>
          <td colspan="3">
            <p><strong>To approve the post, please follow the link below</strong></p>
            <a href="#uploadfolder#/index.cfm?fileToken=#filetoken#" style="display:block;width:200px;margin:20px auto 0px;text-align:center;padding:20px 30px;border-radius:4px;background:#emailtemplateheaderbackground#;color:##ffffff;text-decoration:none;font-weight:bold;">Approve Post</a>
          </td>
        </tr>
      </table>
    </cfoutput>
  </cfsavecontent>
  <cfmail to="#qGetAdmin.E_mail#" from="#request.email#" server="#request.emailServer#" username="#request.emailUsername#" password="#emailpassword#" port="#request.emailPort#" useSSL="#request.emailUseSsl#" useTLS="#request.emailUseTls#" subject="#emailsubject#" type="html">
    <cfinclude template="../../../../email-template.cfm">
  </cfmail>
  <cfset data['emailSent'] = 1>
</cfif>

<cfif IsBinary(data['selectedFile'])>
  <cfset data['selectedFile'] = ToBase64(ToString(data['selectedFile']),"utf-8")>
</cfif>

<cfoutput>
#SerializeJson(data)#
</cfoutput>