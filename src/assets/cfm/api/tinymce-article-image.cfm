
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="form-data,content-type,content-disposition,content-length,Authorization,userToken" />

<cfparam name="filename" default="" />
<cfparam name="fileid" default="0" />
<cfparam name="newfileid" default="#LCase(CreateUUID())#" />
<cfparam name="newfilename" default="" />
<cfparam name="uploadfolder" default="#request.tinymcearticleuploadfolder#" />
<cfparam name="extensions" default="gif,png,jpg,jpeg" />
<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="fileid" default="#LCase(CreateUUID())#" />
<cfparam name="maxcontentlength" default="#request.maxcontentlength#" />

<cfinclude template="../functions.cfm">

<cfset data = StructNew()>
<cfset data['success'] = false>
<cfset data['content'] = "">
<cfset data['content-type'] = "">
<cfset data['content-disposition'] = "">
<cfset data['mime-type'] = "">
<cfset data['content-length'] = 0>
<cfset data['filename'] = Trim(URLDecode(filename))>
<cfset data['extension'] = Trim(ListLast(data['filename'],"."))>
<cfset filename = data['filename']>
<cfset success = data['success']>

<cfset requestData = GetHttpRequestData()>

<!---<cfdump var="#requestData#" />--->

<cftry>
  <cfset data['content'] = requestData.content>
  <cfloop collection = "#requestData.headers#" item="http_item">
    <cfset data[http_item] = StructFind(requestData.headers,http_item)>
  </cfloop>
  <cfset data['content-type'] = ListToArray(data['content-type'],";")>
  <cfcatch>
	<cfset data['error'] = cfcatch.message>
  </cfcatch>
</cftry>

<!---<cfdump var="#data#" abort />--->

<cfif Len(Trim(data['filename'])) AND IsBinary(data['content']) AND IsNumeric(data['content-length']) AND Val(fileid)>
  <cfif ListFindNoCase(extensions,data['extension'])>
    <cfif data['content-length'] LT maxcontentlength>
      <cfset imageSystemPath = request.filepath & "\article-images\" & fileid>
      <cfif NOT DirectoryExists(imageSystemPath)>
        <cflock name="create_directory_#timestamp#" type="exclusive" timeout="30">
          <cfdirectory action="create" directory="#imageSystemPath#" />
        </cflock>
      </cfif>
      <cfif DirectoryExists(imageSystemPath)>
        <cflock name="write_file_#timestamp#" type="exclusive" timeout="30">
		  <cfset newfilename = newfileid & "." & data['extension']>
          <cfset imageSystemFilePath = imageSystemPath & "\" & newfilename>
          <cffile action="write" file="#imageSystemFilePath#" output="#data['content']#" />
        </cflock>
        <cfset data['success'] = true>
        <cfset _isWebImageFile = IsWebImageFile(path=imageSystemFilePath)>
		<cfif NOT _isWebImageFile>
          <cflock name="delete_file_#timestamp#" type="exclusive" timeout="30">
            <cffile action="delete"  file="#imageSystemFilePath#" />
          </cflock>
          <cfset data['success'] = false>
        </cfif>
      </cfif>
    <cfelse>
      <cfset maxcontentlengthInMb = NumberFormat(maxcontentlength/1000000,".__")>
      <cfset data['error'] = "The image uploaded must be less than " & maxcontentlengthInMb & "MB">
    </cfif>
  <cfelse>
	<cfset data['error'] = "The image uploaded did not have the correct file extension">
  </cfif>
<cfelse>
  <cfset data['error'] = "Data uploaded was insufficient to complete the submission">
</cfif>

<cfset success = data['success']>

<cfset data = StructNew()>
<cfset data['location'] = "">
<cfset data['disableImageUpload'] = 0>
<cfdirectory action="list" directory="#request.filepath#\article-images\#fileid#" name="qGetArticleImages" type="file" recurse="no" />
<cfif qGetArticleImages.RecordCount GT request.tinymcearticlemaximages>
  <cfset data['disableImageUpload'] = 1>
</cfif>
<cfif success>
  <cfset data['location'] = uploadfolder & "/" & fileid & "/" & local.newfilename>
</cfif>

<cfoutput>
#SerializeJson(data)#
</cfoutput>