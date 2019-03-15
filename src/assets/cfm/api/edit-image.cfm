
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type,Authorization,userToken" />

<cfparam name="uploadfolder" default="#request.uploadfolder#" />
<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="submissiondate" default="#Now()#" />
<cfparam name="emailsubject" default="Image post update notification e-mail from #request.title#" />
<cfparam name="filetoken" default="#LCase(CreateUUID())#" />
<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset emailtemplateheaderbackground = getMaterialThemePrimaryColour(theme=request.theme)>

<cfset data = StructNew()>
<cfset data['fileid'] = 0>
<cfset data['fileUuid'] = "">
<cfset data['imagePath'] = "">
<cfset data['name'] = "">
<cfset data['title'] = "">
<cfset data['description'] = "">
<cfset data['article'] =  "">
<cfset data['tags'] = "">
<cfset data['publishArticleDate'] = Now()>
<cfset data['tinymceArticleDeletedImages'] = ArrayNew(1)>
<cfset data['tinymceArticleImageCount'] = 0>
<cfset data['submitArticleNotification'] = 1>
<cfset data['emailSent'] = 0>
<cfset data['error'] = "">

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
      <cfcatch>
		<cfset data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
  </cfcatch>
</cftry>

<cfset emailpassword = Decrypt(request.emailPassword,request.emailSalt,request.crptographyalgorithm,request.crptographyencoding)>

<CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblFile 
  WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['fileUuid']#"> 
</CFQUERY>
<cfif qGetFile.RecordCount AND Len(Trim(data['imagePath']))>
  <cfset data['fileid'] = qGetFile.File_ID>
  <cfset imagePath = REReplaceNoCase(data['imagePath'],"[/]+","/","ALL")>
  <cfset imageSystemPath = ReplaceNoCase(imagePath,"/","\","ALL")>
  <cfset imageSystemPath = request.filepath & imageSystemPath & "\" & qGetFile.Filename>
  <cfset imagePath = REReplaceNoCase(imagepath,"^[/]+","")>
  <cfset imagepath = imagePath & "/" & qGetFile.Filename>
  <cfset category = ListLast(data['imagePath'],"/")>
  <cfif CompareNoCase(qGetFile.ImagePath,imagepath) NEQ 0>
	<cfset sourceimagepath = ReplaceNoCase(qGetFile.ImagePath,"/","\","ALL")>
	<cfset source = request.filepath & "\" & sourceimagepath>
    <cfif FileExists(source)>
      <cflock name="move_file_#timestamp#" type="exclusive" timeout="30">
        <cffile action="move" source="#source#" destination="#imageSystemPath#" />
      </cflock>
    </cfif>
  </cfif>
  <cfset tags = FormatTags(data['tags'])>
  <!---<cfdump var="#data['article']#" format="html" output="C:\Users\Charles Robertson\Desktop\edit-image-1.htm" />--->
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
  <CFQUERY NAME="qUpdateFile" DATASOURCE="#request.domain_dsn#">
    UPDATE tblFile
    SET Category = <cfqueryparam cfsqltype="cf_sql_varchar" value="#category#">,ImagePath = <cfqueryparam cfsqltype="cf_sql_varchar" value="#imagepath#">,Author =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['name']#">,Title =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['title']#">,Description =  <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#CapFirstSentence(data['description'],true)#">,Tags =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#tags#">,Article =  <cfqueryparam cfsqltype="cf_sql_longvarchar" value="#data['article']#">,Publish_article_date = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#publishArticleDate#">
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
  <cfset data['error'] = "">
<cfelse>
  <cfset data['error'] = "Record for this file cannot be found">
</cfif>

<cfset adminuserid = getRandomAdminUserID(roleid="6,7")>

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
            <strong>The following post, entitled '#FormatTitle(data['title'])#', has been updated</strong><br /><br />
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

<cfoutput>
#SerializeJSON(data)#
</cfoutput>