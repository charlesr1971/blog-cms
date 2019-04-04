
<cfcomponent extends="taffy.core.resource" taffy_uri="/tinymcearticleimage/{fileid}">

  <cffunction name="get">
    <cfargument name="fileid" type="numeric" required="yes" />
    <cfset var local = StructNew()>
    <cfset local['userToken'] = "">
    <cfset local['userid'] = 0>
    <cfset local.data = StructNew()>
    <cfset local.data['fileid'] = arguments.fileid>
	<cfset local.data['tinymceArticleImageCount'] = 0>
    <cfset local.data['tinymceArticleImages'] = ArrayNew(1)>
    <cfset local.data['tinymceArticle'] = "">
    <cfset local.data['checkDirectory'] = false>
    <cfset local.data['error'] = "">
    <cfset local.requestBody = getHttpRequestData().headers>
    <cftry>
      <cfif StructKeyExists(local.requestBody,"checkDirectory")>
		<cfset local.data['checkDirectory'] =  Trim(local.requestBody['checkDirectory'])>
      </cfif>
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
      WHERE File_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.data['fileid']#"> AND (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(local['userid'])> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local['userid']#">)</cfif>) 
    </CFQUERY>
    <cfif local.qGetFile.RecordCount AND Len(Trim(local.qGetFile.Article))>
      <cfset local.data['tinymceArticleImages'] = request.utils.TinymceArticleImages(local.qGetFile.Article)>
      <cfset local.data['tinymceArticle'] = local.qGetFile.Article>
    </cfif>
    <cfif Val(local.data['fileid'])>
	  <cfif NOT ArrayLen(local.data['tinymceArticleImages']) OR local.data['checkDirectory']>
        <cfdirectory action="list" directory="#request.filepath#\article-images\#local.data['fileid']#" name="local.qGetArticleImages" type="file" recurse="no" />
        <cfif local.qGetArticleImages.RecordCount>
		  <cfset local.data['tinymceArticleImages'] = ArrayNew(1)>
          <cfloop query="local.qGetArticleImages">
            <cfset ArrayAppend(local.data['tinymceArticleImages'],local.qGetArticleImages.Name)>
          </cfloop>
        </cfif>
      </cfif>
    </cfif>
    <cfif Val(local.data['fileid'])>
      <cfdirectory action="list" directory="#request.filepath#\article-images\#local.data['fileid']#" name="local.qGetArticleImages" type="file" recurse="no" />
      <cfset local.data['tinymceArticleImageCount'] = local.qGetArticleImages.RecordCount>
    <cfelse>
      <cfset local.data['error'] = "The fileid for the file submitted is zero">
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>
  
  <cffunction name="post">
    <cfargument name="fileid" type="numeric" required="yes" />
    <cfset var local = StructNew()>
    <cfset local.uploadfolder = request.tinymcearticleuploadfolder>
    <cfset local.extensions = "gif,png,jpg,jpeg">
    <cfset local.timestamp = DateFormat(Now(),'yyyymmdd') & TimeFormat(Now(),'HHmmss')>
    <cfset local.newfileid = LCase(CreateUUID())>
    <cfset local.newfilename = "">
    <cfset local.fileid = arguments.fileid>
    <cfset local.filename = "">
    <cfset local.maxcontentlength = request.maxcontentlength>
    <cfset local.jwtString = "">
    <cfset local.authorized = true>
    <cfset local.data = StructNew()>
    <cfset local.data['success'] = false>
	<cfset local.data['content'] = "">
    <cfset local.data['content-type'] = "">
    <cfset local.data['content-disposition'] = "">
    <cfset local.data['mime-type'] = "">
    <cfset local.data['content-length'] = 0>
    <cfset local.data['filename'] = "">
    <cfset local.data['extension'] = "">
    <cfset local.data['userToken'] = "">
    <cfset local.data['jwtObj'] = StructNew()>
    <cfset local.data['error'] = "">
    <cfset local.filename = "">
    <cfset local.success = local.data['success']>
    <cfset local.requestData = GetHttpRequestData()>
    <cfset local.requestBody = local.requestData.headers>
    <!---<cfdump var="#local.requestData#" />--->
    <cftry>
      <cfset local.data['content'] = local.requestData.content>
      <cfloop collection = "#local.requestData.headers#" item="http_item">
        <cfset local.data[http_item] = StructFind(local.requestData.headers,http_item)>
        <cfset local.data[http_item] = Trim(local.data[http_item])>
      </cfloop>
      <cfif StructKeyExists(local.data,"Authorization") AND Len(Trim(local.data['Authorization']))>
        <cfset local.jwtString = request.utils.GetJwtString(Trim(local.data['Authorization']))>
        <cfset StructDelete(local.data,"Authorization")>
      </cfif>
      <cfset local.data['filename'] = Trim(URLDecode(local.data['filename']))>
      <cfset local.data['extension'] = Trim(ListLast(local.data['filename'],"."))>
      <cfset local.data['content-type'] = ListToArray(local.data['content-type'],";")>
      <cfset local.filename = local.data['filename']>
      <cfcatch>
		<cfset local.data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
    <!---<cfdump var="#local.data#" output="C:\Users\Charles Robertson\Desktop\debugXXX.htm" format="html" />--->
    <cfinclude template="../../../../jwt-decrypt.cfm">
	<cfif StructKeyExists(local.data['jwtObj'],"jwtAuthenticated") AND NOT local.data['jwtObj']['jwtAuthenticated']>
      <cfreturn representationOf(local.data).withStatus(403,"Not Authorized") />
    </cfif>
    <cfset local.imagemembersecurityusertoken = "">
    <cfif StructKeyExists(local.data['jwtObj'],"userToken") AND Len(Trim(local.data['jwtObj']['userToken']))>
	  <cfset local.imagemembersecurityusertoken = local.data['jwtObj']['userToken']>
    </cfif>
    <!---<cfdump var="#local.data['jwtObj']#" abort />--->
    <cfset local.imagemembersecurityfileuuid = arguments.fileid>
    <cfinclude template="../../../../file-security.cfm">
	<cfif NOT local.authorized>
      <cfreturn representationOf(local.data).withStatus(403,"Not Authorized") />
    </cfif>
    <!---<cfdump var="#local.data#" abort />--->
    <cfif Len(Trim(local.data['filename'])) AND IsBinary(local.data['content']) AND IsNumeric(local.data['content-length']) AND Val(local.fileid)>
      <cfif ListFindNoCase(locaL.extensions,local.data['extension'])>
        <cfif local.data['content-length'] LT local.maxcontentlength>
          <cfset local.imageSystemPath = request.filepath & "\article-images\" & local.fileid>
          <cfif NOT DirectoryExists(local.imageSystemPath)>
            <cflock name="create_directory_#local.timestamp#" type="exclusive" timeout="30">
              <cfdirectory action="create" directory="#local.imageSystemPath#" />
            </cflock>
          </cfif>
          <cfif DirectoryExists(local.imageSystemPath)>
			<cfset local.newfilename = local.newfileid & "." & local.data['extension']>
            <cfset local.imageSystemFilePath = local.imageSystemPath & "\" & local.newfilename>
            <cflock name="write_file_#local.timestamp#" type="exclusive" timeout="30">
              <cffile action="write" file="#local.imageSystemFilePath#" output="#local.data['content']#" />
            </cflock>
            <cfset local.data['success'] = true>
            <cfset local.isWebImageFile = request.utils.IsWebImageFile(path=local.imageSystemFilePath)>
            <cfif NOT local.isWebImageFile>
              <cflock name="delete_file_#local.timestamp#" type="exclusive" timeout="30">
                <cffile action="delete"  file="#local.imageSystemFilePath#" />
              </cflock>
              <cfset local.data['success'] = false>
            </cfif>
          </cfif>
        <cfelse>
          <cfset local.maxcontentlengthInMb = NumberFormat(local.maxcontentlength/1000000,".__")>
          <cfset local.data['error'] = "The image uploaded must be less than " & local.maxcontentlengthInMb & "MB">
        </cfif>
      <cfelse>
        <cfset local.data['error'] = "The image uploaded did not have the correct file extension">
      </cfif>
    <cfelse>
      <cfset local.data['error'] = "Data uploaded was insufficient to complete the submission">
    </cfif>
    <cfset local.success = local.data['success']>
    <cfset local.data = StructNew()>
    <cfset local.data['location'] = "">
    <cfset local.data['disableImageUpload'] = 0>
    <cfdirectory action="list" directory="#request.filepath#\article-images\#local.fileid#" name="local.qGetArticleImages" type="file" recurse="no" />
    <cfif local.qGetArticleImages.RecordCount GT request.tinymcearticlemaximages>
      <cfset local.data['disableImageUpload'] = 1>
    </cfif>
    <cfif local.success>
      <cfset local.data['location'] = local.uploadfolder & "/" & local.fileid & "/" & local.newfilename>
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>
  
  <cffunction name="delete">
    <cfargument name="fileid" type="numeric" required="yes" />
    <cfset var local = StructNew()>
    <cfset local.uploadfolder = request.tinymcearticleuploadfolder>
    <cfset local.timestamp = DateFormat(Now(),'yyyymmdd') & TimeFormat(Now(),'HHmmss')>
    <cfset local.jwtString = "">
    <cfset local.authorized = true>
    <cfset local.data = StructNew()>
	<cfset local.data['fileid'] = arguments.fileid>
	<cfset local.data['filename'] = "">
    <cfset local.data['userToken'] = "">
    <cfset local.data['jwtObj'] = StructNew()>
    <cfset local.data['error'] = "">
    <cfset local.requestBody = getHttpRequestData().headers>
    <cftry>
	  <cfif StructKeyExists(local.requestBody,"filename")>
        <cfset local.data['filename'] = Trim(URLDecode(local.requestBody['filename']))>
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
    <cfset local.imagemembersecurityfileuuid = arguments.fileid>
    <cfinclude template="../../../../file-security.cfm">
	<cfif NOT local.authorized>
      <cfreturn representationOf(local.data).withStatus(403,"Not Authorized") />
    </cfif>
    <cfif Len(Trim(local.data['filename'])) AND Val(local.data['fileid'])>
      <cfset local.source = request.filepath & "\article-images\" & local.data['fileid'] & "\" & local.data['filename']>
      <cfif FileExists(local.source)>
        <cflock name="delete_file_#local.timestamp#" type="exclusive" timeout="30">
          <cffile action="delete"  file="#local.source#" />
        </cflock>
      <cfelse>
        <cfset local.data['error'] = "The file submitted does not exist">
      </cfif>
    <cfelse>
      <cfset local.data['error'] = "The filename for the file submitted is empty">
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>