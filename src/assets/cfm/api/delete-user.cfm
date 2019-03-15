
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
  <CFQUERY NAME="qDeleteUser" DATASOURCE="#request.domain_dsn#">
    DELETE 
    FROM tblUser
    WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['userid']#">
  </CFQUERY>
  <CFQUERY DATASOURCE="#request.domain_dsn#">
    DELETE 
    FROM tblUsertoken
    WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['userid']#">
  </CFQUERY>
  <CFQUERY NAME="qDeleteFile" DATASOURCE="#request.domain_dsn#">
    DELETE 
    FROM tblFile
    WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['userid']#">
  </CFQUERY>
  <CFQUERY NAME="qDeleteFileUser" DATASOURCE="#request.domain_dsn#">
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

<cfoutput>
#SerializeJSON(data)#
</cfoutput>