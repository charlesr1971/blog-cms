
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type,Authorization,userToken" />

<cfparam name="uploadfolder" default="#request.tinymcearticleuploadfolder#" />
<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="userToken" default="" />
<cfparam name="userid" default="0" />
<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset data = StructNew()>
<cfset data['fileid'] = 0>
<cfset data['tinymceArticleImageCount'] = 0>
<cfset data['tinymceArticleImages'] = ArrayNew(1)>
<cfset data['tinymceArticle'] = "">
<cfset data['checkDirectory'] = false>
<cfset data['error'] = "">

<cfset requestBody = toString(getHttpRequestData().content)>
<cfset requestBody = Trim(requestBody)>
<cftry>
  <cfset requestBody = DeserializeJSON(requestBody)>
  <cfif StructKeyExists(requestBody,"fileid")>
  	<cfset data['fileid'] = Trim(requestBody['fileid'])>
  </cfif>
  <cfif StructKeyExists(requestBody,"checkDirectory")>
	<cfset data['checkDirectory'] =  Trim(requestBody['checkDirectory'])>
  </cfif>
  <cfcatch>
    <cftry>
      <cfset requestBody = REReplaceNoCase(requestBody,"[\s+]"," ","ALL")>
      <cfset requestBody = DeserializeJSON(requestBody)>
      <cfif StructKeyExists(requestBody,"fileid")>
		<cfset data['fileid'] = Trim(requestBody['fileid'])>
      </cfif>
      <cfif StructKeyExists(requestBody,"checkDirectory")>
		<cfset data['checkDirectory'] =  Trim(requestBody['checkDirectory'])>
      </cfif>
      <cfcatch>
		<cfset data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
  </cfcatch>
</cftry>

<cfset requestBody = getHttpRequestData().headers>
<cftry>
  <cfif StructKeyExists(requestBody,"userToken")>
	<cfset userToken = Trim(requestBody['userToken'])>
  </cfif>
  <cfcatch>
  </cfcatch>
</cftry>

<CFQUERY NAME="qGetUserID" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblUserToken 
  WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#userToken#">
</CFQUERY>
<cfif qGetUserID.RecordCount>
  <cfset userid = qGetUserID.User_ID>
</cfif>

<CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblFile 
  WHERE File_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['fileid']#"> AND (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(userid)> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#">)</cfif>)
</CFQUERY>
<cfif qGetFile.RecordCount AND Len(Trim(qGetFile.Article))>
  <cfset data['tinymceArticleImages'] = TinymceArticleImages(qGetFile.Article)>
  <cfset data['tinymceArticle'] = qGetFile.Article>
</cfif>

<cfif Val(data['fileid'])>
  <cfif NOT ArrayLen(data['tinymceArticleImages']) OR data['checkDirectory']>
    <cfdirectory action="list" directory="#request.filepath#\article-images\#data['fileid']#" name="qGetArticleImages" type="file" recurse="no" />
    <cfif qGetArticleImages.RecordCount>
	  <cfset data['tinymceArticleImages'] = ArrayNew(1)>
      <cfloop query="qGetArticleImages">
        <cfset ArrayAppend(data['tinymceArticleImages'],qGetArticleImages.Name)>
      </cfloop>
    </cfif>
  </cfif>
</cfif>

<cfif Val(data['fileid'])>
  <cfdirectory action="list" directory="#request.filepath#\article-images\#data['fileid']#" name="qGetArticleImages" type="file" recurse="no" />
  <cfset data['tinymceArticleImageCount'] = qGetArticleImages.RecordCount>
<cfelse>
  <cfset data['error'] = "The fileid for the file submitted is zero">
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>