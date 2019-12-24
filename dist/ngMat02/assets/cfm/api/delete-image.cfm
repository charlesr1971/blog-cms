
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type,Authorization,userToken" />

<cfparam name="uploadfolder" default="#request.uploadfolder#" />
<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset data = StructNew()>
<cfset data['fileUuid'] = "">
<cfset data['error'] = "">

<cfset requestBody = toString(getHttpRequestData().content)>
<cfset requestBody = Trim(requestBody)>
<cftry>
  <cfset requestBody = DeserializeJSON(requestBody)>
  <cfif StructKeyExists(requestBody,"fileUuid")>
	<cfset data['fileUuid'] = Trim(requestBody['fileUuid'])>
  </cfif>
  <cfcatch>
    <cftry>
      <cfset requestBody = REReplaceNoCase(requestBody,"[\s+]"," ","ALL")>
      <cfset requestBody = DeserializeJSON(requestBody)>
      <cfif StructKeyExists(requestBody,"fileUuid")>
		<cfset data['fileUuid'] = Trim(requestBody['fileUuid'])>
      </cfif>
      <cfcatch>
		<cfset data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
  </cfcatch>
</cftry>

<CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblFile  
  WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['fileUuid']#"> 
</CFQUERY>
<cfif qGetFile.RecordCount>
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
  <CFQUERY DATASOURCE="#request.domain_dsn#">
    DELETE
    FROM tblFile
    WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['fileUuid']#"> 
  </CFQUERY>
  <CFQUERY DATASOURCE="#request.domain_dsn#">
    DELETE
    FROM tblFileUser
    WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['fileUuid']#"> 
  </CFQUERY>
  <CFQUERY DATASOURCE="#request.domain_dsn#">
    DELETE
    FROM tblComment
    WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#data['fileUuid']#"> 
  </CFQUERY>
  <cfset data['error'] = "">
<cfelse>
  <cfset data['error'] = "Record for this file cannot be found">
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>