
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type,Authorization,userToken" />

<cfparam name="uploadfolder" default="#request.tinymcearticleuploadfolder#" />
<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset data = StructNew()>
<cfset data['fileid'] = 0>
<cfset data['filename'] = "">
<cfset data['error'] = "">

<cfset requestBody = toString(getHttpRequestData().content)>
<cfset requestBody = Trim(requestBody)>
<cftry>
  <cfset requestBody = DeserializeJSON(requestBody)>
  <cfif StructKeyExists(requestBody,"fileid")>
  	<cfset data['fileid'] = Trim(requestBody['fileid'])>
  </cfif>
  <cfif StructKeyExists(requestBody,"filename")>
  	<cfset data['filename'] = Trim(requestBody['filename'])>
  </cfif>
  <cfcatch>
    <cftry>
      <cfset requestBody = REReplaceNoCase(requestBody,"[\s+]"," ","ALL")>
      <cfset requestBody = DeserializeJSON(requestBody)>
      <cfif StructKeyExists(requestBody,"fileid")>
		<cfset data['fileid'] = Trim(requestBody['fileid'])>
      </cfif>
      <cfif StructKeyExists(requestBody,"filename")>
        <cfset data['filename'] = Trim(requestBody['filename'])>
      </cfif>
      <cfcatch>
		<cfset data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
  </cfcatch>
</cftry>


<cfif Len(Trim(data['filename'])) AND Val(data['fileid'])>
  <cfset source = request.filepath & "\article-images\" & data['fileid'] & "\" & data['filename']>
  <cfif FileExists(source)>
    <cflock name="delete_file_#timestamp#" type="exclusive" timeout="30">
      <cffile action="delete"  file="#source#" />
    </cflock>
  <cfelse>
	<cfset data['error'] = "The file submitted does not exist">
  </cfif>
<cfelse>
  <cfset data['error'] = "The filename for the file submitted is empty">
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>