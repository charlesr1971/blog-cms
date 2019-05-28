
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfif StructKeyExists(getHttpRequestData().headers,"upload-type")>
  <cfheader name="Access-Control-Allow-Headers" value="fileUuid,file-name,image-path,name,title,description,article,tags,publish-article-date,tinymce-article-deleted-images,file-extension,user-token,content-type,cfid,cftoken,upload-type,imageAccreditation,imageOrientation,Authorization,userToken" />
<cfelse>
  <cfheader name="Access-Control-Allow-Headers" value="content-type,Authorization,userToken" />
</cfif>

<cfparam name="maxcontentlength" default="#request.maxcontentlength#" />
<cfparam name="imagePath" default="" />
<cfparam name="imageNewFilePath" default="" /> 
<cfparam name="extensions" default="gif,png,jpg,jpeg" />
<cfparam name="oldimagePath" default="" />
<cfparam name="uploadfolder" default="#request.uploadfolder#" />
<cfparam name="tags" default="" />
<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="submissiondate" default="#Now()#" />
<cfparam name="emailsubject" default="Image post update notification e-mail from #request.title#" />
<cfparam name="fileid" default="#LCase(CreateUUID())#" />
<cfparam name="filetoken" default="#LCase(CreateUUID())#" />
<cfparam name="roleid" default="0" />
<cfparam name="source" default="" />
<cfparam name="isAdmin" default="false" />
<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset emailtemplateheaderbackground = getMaterialThemePrimaryColour(theme=request.theme)>
<cfset emailtemplatemessage = "">

<cfset punctuationSubsetPattern = request.punctuationSubsetPattern>
<cfset styleAttributePattern = '[\s]*style=".*?"'>
<cfset spaceInsideParagraphPattern = "<p>&nbsp;<\/p>">

<cfset data = StructNew()>
<cfset data['fileid'] = 0>
<cfset data['clientfileName'] = "">
<cfset data['fileUuid'] = "">
<cfset data['imagePath'] = "">
<cfset data['name'] = "">
<cfset data['title'] = "">
<cfset data['description'] = "">
<cfset data['article'] =  "">
<cfset data['tags'] = "">
<cfset data['publishArticleDate'] = Now()>
<cfset data['tinymceArticleDeletedImages'] = ArrayNew(1)>
<cfset data['fileExtension'] = "">
<cfset data['selectedFile'] = "">
<cfset data['success'] = false>
<cfset data['content_length'] = 0>
<cfset data['tinymceArticleImageCount'] = 0>
<cfset data['submitArticleNotification'] = 1>
<cfset data['uploadType'] = "">
<cfset data['imageAccreditation'] = "">
<cfset data['imageOrientation'] = "landscape">
<cfset data['emailSent'] = 0>
<cfset data['error'] = "">

<cfif StructKeyExists(getHttpRequestData().headers,"upload-type")>

  <cftry>
	<cfif StructKeyExists(getHttpRequestData().headers,"fileUuid")>
      <cfset data['fileUuid'] = getHttpRequestData().headers['fileUuid']>
    </cfif>
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
    <cfif StructKeyExists(getHttpRequestData().headers,"imageAccreditation")>
      <cfset data['imageAccreditation'] = getHttpRequestData().headers['imageAccreditation']>
    </cfif>
    <cfif StructKeyExists(getHttpRequestData().headers,"imageOrientation")>
      <cfset data['imageOrientation'] = getHttpRequestData().headers['imageOrientation']>
    </cfif>
    <cfcatch>
      <cfset data['error'] = cfcatch.message>
    </cfcatch>
  </cftry>

<cfelse>

  <cfset requestBody = toString(getHttpRequestData().content)>
  <cfset requestBody = Trim(requestBody)>
  <cftry>
    <cfset requestBody = DeserializeJSON(requestBody)>
    <cfif StructKeyExists(requestBody,"fileUuid")>
      <cfset data['fileUuid'] = Trim(requestBody['fileUuid'])>
    </cfif>
    <cfif StructKeyExists(requestBody,"imagePath")>
      <cfset data['imagePath'] = Trim(requestBody['imagePath'])>
    </cfif>
    <cfif StructKeyExists(requestBody,"name")>
      <cfset data['name'] =  Trim(requestBody['name'])>
    </cfif>
    <cfif StructKeyExists(requestBody,"title")>
      <cfset data['title'] =  Trim(requestBody['title'])>
    </cfif>
    <cfif StructKeyExists(requestBody,"description")>
      <cfset data['description'] =  Trim(requestBody['description'])>
    </cfif>
    <cfif StructKeyExists(requestBody,"article")>
      <cfset data['article'] =  Trim(requestBody['article'])>
    </cfif>
    <cfif StructKeyExists(requestBody,"tags")>
      <cfset data['tags'] =  Trim(requestBody['tags'])>
    </cfif>
    <cfif StructKeyExists(requestBody,"publishArticleDate")>
      <cfset data['publishArticleDate'] =  Trim(requestBody['publishArticleDate'])>
    </cfif>
    <cfif StructKeyExists(requestBody,"tinymceArticleDeletedImages")>
      <cfset data['tinymceArticleDeletedImages'] =  Trim(requestBody['tinymceArticleDeletedImages'])>
    </cfif>
    <cfif StructKeyExists(requestBody,"submitArticleNotification")>
      <cfset data['submitArticleNotification'] =  Trim(requestBody['submitArticleNotification'])>
    </cfif>
    <cfif StructKeyExists(requestBody,"imageAccreditation")>
      <cfset data['imageAccreditation'] =  Trim(requestBody['imageAccreditation'])>
    </cfif>
    <cfif StructKeyExists(requestBody,"imageOrientation")>
      <cfset data['imageOrientation'] =  Trim(requestBody['imageOrientation'])>
    </cfif>
    <cfcatch>
      <cftry>
        <cfset requestBody = REReplaceNoCase(requestBody,"[\s+]"," ","ALL")>
        <cfset requestBody = DeserializeJSON(requestBody)>
        <cfif StructKeyExists(requestBody,"fileUuid")>
          <cfset data['fileUuid'] = Trim(requestBody['fileUuid'])>
        </cfif>
        <cfif StructKeyExists(requestBody,"imagePath")>
          <cfset data['imagePath'] = Trim(requestBody['imagePath'])>
        </cfif>
        <cfif StructKeyExists(requestBody,"name")>
          <cfset data['name'] =  Trim(requestBody['name'])>
        </cfif>
        <cfif StructKeyExists(requestBody,"title")>
          <cfset data['title'] =  Trim(requestBody['title'])>
        </cfif>
        <cfif StructKeyExists(requestBody,"description")>
          <cfset data['description'] =  Trim(requestBody['description'])>
        </cfif>
        <cfif StructKeyExists(requestBody,"article")>
          <cfset data['article'] =  Trim(requestBody['article'])>
        </cfif>
        <cfif StructKeyExists(requestBody,"tags")>
          <cfset data['tags'] =  Trim(requestBody['tags'])>
        </cfif>
        <cfif StructKeyExists(requestBody,"publishArticleDate")>
          <cfset data['publishArticleDate'] =  Trim(requestBody['publishArticleDate'])>
        </cfif>
        <cfif StructKeyExists(requestBody,"tinymceArticleDeletedImages")>
          <cfset data['tinymceArticleDeletedImages'] =  Trim(requestBody['tinymceArticleDeletedImages'])>
        </cfif>
        <cfif StructKeyExists(requestBody,"submitArticleNotification")>
          <cfset data['submitArticleNotification'] =  Trim(requestBody['submitArticleNotification'])>
        </cfif>
        <cfif StructKeyExists(requestBody,"imageAccreditation")>
		  <cfset data['imageAccreditation'] =  Trim(requestBody['imageAccreditation'])>
        </cfif>
        <cfif StructKeyExists(requestBody,"imageOrientation")>
		  <cfset data['imageOrientation'] =  Trim(requestBody['imageOrientation'])>
        </cfif>
        <cfcatch>
          <cfset data['error'] = cfcatch.message>
        </cfcatch>
      </cftry>
    </cfcatch>
  </cftry>
  
</cfif>

<cfset emailpassword = Decrypt(request.emailPassword,request.emailSalt,request.crptographyalgorithm,request.crptographyencoding)>

<CFQUERY NAME="qGetUserTokenRoleId" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblUser INNER JOIN tblUsertoken ON tblUser.User_ID = tblUsertoken.User_ID
  WHERE tblUsertoken.User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['userToken']#">
</CFQUERY>
<cfif qGetUserTokenRoleId.RecordCount AND qGetUserTokenRoleId.Role_ID GTE 6>
  <cfset isAdmin = true>
</cfif>

<CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblFile  
  WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['fileUuid']#"> 
</CFQUERY>
<cfif qGetFile.RecordCount>
  <cfset oldimagePath = qGetFile.ImagePath>
  <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
    SELECT * 
    FROM tblUser 
    WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetFile.User_ID#">
  </CFQUERY>
  <cfif qGetUser.RecordCount>
    <cfset roleid = qGetUser.Role_ID>
  </cfif>
</cfif>
<cfset imageSystemDirectoryPath = "">
<cfif qGetFile.RecordCount AND Len(Trim(data['imagePath']))>
  <cfset data['fileid'] = qGetFile.File_ID>
  <cfset imagePath = REReplaceNoCase(data['imagePath'],"[/]+","/","ALL")>
  <cfset imageSystemPath = ReplaceNoCase(imagePath,"/","\","ALL")>
  <cfset imageSystemDirectoryPath = request.filepath & "\" & imageSystemPath>
  <cfset imageSystemPath = request.filepath & imageSystemPath & "\" & qGetFile.Filename>
  <cfset imagePath = REReplaceNoCase(imagepath,"^[/]+","")>
  <cfset imagepath = imagePath & "/" & qGetFile.Filename>
  <cfset category = ListLast(data['imagePath'],"/")>
  <cfset sourceimagepath = ReplaceNoCase(qGetFile.ImagePath,"/","\","ALL")>
  <cfset source = request.filepath & "\" & sourceimagepath>
  <cfif CompareNoCase(qGetFile.ImagePath,imagepath) NEQ 0>
    <cfif FileExists(source)>
      <cflock name="move_file_#timestamp#" type="exclusive" timeout="30">
        <cffile action="move" source="#source#" destination="#imageSystemPath#" />
      </cflock>
      <cfset mediumImagePathNameSource = getImageCopyName(path=source,suffix=request.imageMediumSuffix)>
	  <cfset mediumImagePathNameDestination = getImageCopyName(path=imageSystemPath,suffix=request.imageMediumSuffix)>
      <cfif FileExists(mediumImagePathNameSource)>
        <cflock name="move_file_#timestamp#" type="exclusive" timeout="30">
          <cffile action="move" source="#mediumImagePathNameSource#" destination="#mediumImagePathNameDestination#" />
        </cflock>
      </cfif>
    </cfif>
  </cfif>
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
  <cfset author = REReplaceNoCase(data['name'],"[[:punct:]]","","ALL")>
  <cfset author = REReplaceNoCase(author,"[\s]+"," ","ALL")>
  <cfset author = Trim(author)>
  <cfset author = FormatTitle(author)>
  <cfset author = Trim(author)>
  <cfset title = REReplaceNoCase(data['title'],"#punctuationSubsetPattern#","","ALL")>
  <cfset title = REReplaceNoCase(title,"[\s]+"," ","ALL")>
  <cfset title = Trim(title)>
  <cfset title = CapFirstAll(title)>
  <cfset article = REReplaceNoCase(data['article'],"#styleAttributePattern#","","ALL")>
  <cfset article = REReplaceNoCase(article,"#spaceInsideParagraphPattern#","","ALL")>
  <cfset approved = ListFindNoCase("6,7",roleid) OR isAdmin ? 1 : 0> 
  <CFQUERY NAME="qUpdateFile" DATASOURCE="#request.domain_dsn#">
    UPDATE tblFile
    SET Category = <cfqueryparam cfsqltype="cf_sql_varchar" value="#category#">,ImagePath = <cfqueryparam cfsqltype="cf_sql_varchar" value="#imagepath#">,Author =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#author#">,Title =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#title#">,Description =  <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#CapFirstSentence(data['description'],true)#">,Tags =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#tags#">,Article =  <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#article#">,Publish_article_date = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#publishArticleDate#">,Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#approved#">,FileToken = <cfqueryparam cfsqltype="cf_sql_varchar" value="#filetoken#">,ImageAccreditation = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['imageAccreditation']#">,ImageOrientation = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['imageOrientation']#">
    WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['fileUuid']#"> 
  </CFQUERY>
  <cfif IsjSON(data['tinymceArticleDeletedImages'])>
	<cfset tinymceArticleDeletedImages = DeserializeJSON(data['tinymceArticleDeletedImages'])>
	<cfif IsArray(tinymceArticleDeletedImages)>
      <cfset RemoveTinymceArticleImage(tinymceArticleDeletedImages)>
    </cfif>
  </cfif>
  <cfset RemoveTinymceArticleOrphanImage(data['article'],qGetFile.File_ID)>
  <cfdirectory action="list" directory="#request.filepath#\article-images\#qGetFile.File_ID#" name="qGetArticleImages" type="file" recurse="no" />
  <cfset data['tinymceArticleImageCount'] = qGetArticleImages.RecordCount>
  <cfset data['publishArticleDate'] = publishArticleDate>
  <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
    SELECT * 
    FROM tblUser 
    WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetFile.User_ID#">
  </CFQUERY>
  <cfif qGetUser.RecordCount>
    <CFQUERY NAME="qUpdateUser" DATASOURCE="#request.domain_dsn#">
      UPDATE tblUser
      SET Submit_article_notification = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#data['submitArticleNotification']#">
      WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetFile.User_ID#">
    </CFQUERY>
  </cfif>
  <cfset data['success'] = true>
  <cfset imageNewFilePath = imagePath>
  <cfset data['error'] = "">
<cfelse>
  <cfset data['error'] = "Record for this file cannot be found">
</cfif>

<cfif data['success'] AND Len(Trim(data['imagePath'])) AND Len(Trim(data['fileExtension'])) AND ListFindNoCase(extensions,data['fileExtension']) AND IsBinary(data['selectedFile']) AND IsNumeric(data['content_length'])>
  <cfif data['content_length'] LT maxcontentlength>
    <cfset data['success'] = false>
    <cfif DirectoryExists(imageSystemDirectoryPath)>
      <cfset newfilename = data['fileUuid'] & "." & data['fileExtension']>
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
      <cfif FileExists(imageSystemSecureFilePath) AND DirectoryExists(imageSystemDirectoryPath)>
        <cfset isWebImageFile = IsWebImageFile(path=imageSystemSecureFilePath)>
        <cfif NOT isWebImageFile>
          <cflock name="delete_file_#timestamp#" type="exclusive" timeout="30">
            <cffile action="delete"  file="#imageSystemSecureFilePath#" />
          </cflock>
          <cfset data['success'] = false>
        <cfelse>
          <cflock name="move_file_#timestamp#" type="exclusive" timeout="30">
            <cffile action="move" source="#imageSystemSecureFilePath#" destination="#imageSystemDirectoryPath#">
          </cflock>
          <cfset mediumImageSystemFilePath = imageSystemDirectoryPath & "\" & ListLast(imageSystemSecureFilePath,"\")>
		  <cfif FileExists(mediumImageSystemFilePath)>
            <cfset mediumImagePathName = createImageCopy(path=mediumImageSystemFilePath,suffix=request.imageMediumSuffix,width=request.imageMediumWidth)>
          </cfif>
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
      <cfset filename = data['fileUuid'] & "." & data['fileExtension']>
      <cfset imagePath = REReplaceNoCase(data['imagePath'],"[/]+","/","ALL")>
      <cfset imagePath = REReplaceNoCase(imagePath,"^[/]+","")>
      <cfset imagePath = imagePath & "/" & filename>
      <cfif CompareNoCase(Trim(LCase(imagePath)),Trim(LCase(oldimagePath))) NEQ 0 AND FileExists(source)>
        <cflock name="delete_file_#timestamp#" type="exclusive" timeout="30">
          <cffile action="delete" file="#source#" />
        </cflock>
        <cfset mediumImagePathName = getImageCopyName(path=source,suffix=request.imageMediumSuffix)>
		<cfif FileExists(mediumImagePathName)>
          <cflock name="delete_file_#timestamp#" type="exclusive" timeout="30">
            <cffile action="delete"  file="#mediumImagePathName#" />
          </cflock>
        </cfif>
      </cfif>
      <CFQUERY DATASOURCE="#request.domain_dsn#">
        UPDATE tblFile
        SET Clientfilename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['clientfileName']#">,Filename = <cfqueryparam cfsqltype="cf_sql_varchar" value="#filename#">,ImagePath = <cfqueryparam cfsqltype="cf_sql_varchar" value="#imagePath#">,Size = <cfqueryparam cfsqltype="cf_sql_integer" value="#Val(data['content_length'])#"> 
        WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['fileUuid']#"> 
      </CFQUERY>
      <cfset imageNewFilePath = imagePath>
    <cfelse>
      <cfset data['error'] = "The image uploaded was not the correct file type">
    </cfif>
  <cfelse>
    <cfset maxcontentlengthInMb = NumberFormat(maxcontentlength/1000000,".__")>
    <cfset data['error'] = "The image uploaded must be less than " & maxcontentlengthInMb & "MB">
  </cfif>
</cfif>

<cfif NOT ListFindNoCase("6,7",roleid)>
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
  <cfif NOT Len(Trim(data['error'])) AND qGetAdmin.RecordCount AND Len(Trim(qGetAdmin.E_mail)) AND FindNoCase("@",qGetAdmin.E_mail) AND qGetFileAuthor.RecordCount>
    <cfset salutation = CapFirst(LCase(qGetAdmin.Forename))>
    <cfsavecontent variable="emailtemplatemessage">
      <cfoutput>
        <h1>Hi<cfif Len(Trim(salutation))> #salutation#</cfif></h1>
        <table cellpadding="0" cellspacing="0" border="0" width="100%">
          <tr valign="middle">
            <td width="10" bgcolor="##DDDDDD"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="10" height="1" /></td>
            <td width="20"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="20" height="1" /></td>
            <td style="font-size:16px;">
              <strong>The following post, entitled '#data['title']#', has been updated</strong><br /><br />
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
          <cfif Len(Trim(tags))>
            <tr>
              <td colspan="3">
                <p><strong>Tags:</strong></p>
                #tags#<br />
              </td>
            </tr>
          </cfif>
          <tr>
            <td colspan="3">
              <img src="#uploadfolder#/#qGetFileAuthor.ImagePath#" style="width:100%" border="0" /><br />
            </td>
          </tr>
          <cfif Len(Trim(data['article']))>
            <tr>
              <td colspan="3">
                <p><strong>Article:</strong></p>
                #data['article']#<br />
              </td>
            </tr>
          </cfif>
          <cfif Len(Trim(publishArticleDate))>
            <tr>
              <td colspan="3">
                <p><strong>Publish Article Date:</strong></p>
                #publishArticleDate#<br />
              </td>
            </tr>
          </cfif>
          <tr>
            <td colspan="3">
              <p><strong>To approve the updates, please follow the link below</strong></p>
              <a href="#uploadfolder#/index.cfm?fileToken=#filetoken#" style="display:block;width:200px;margin:20px auto 0px;text-align:center;padding:20px 30px;border-radius:4px;background:#emailtemplateheaderbackground#;color:##ffffff;text-decoration:none;font-weight:bold;">Approve Updates</a>
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
</cfif>

<cfset data['imagePath'] = imageNewFilePath> 
<cfif IsBinary(data['selectedFile'])>
  <cfset data['selectedFile'] = ToBase64(ToString(data['selectedFile']),"utf-8")>
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>