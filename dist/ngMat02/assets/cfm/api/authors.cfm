
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="Authorization,userToken" />

<cfparam name="uploadfolder" default="#request.uploadfolder#" />
<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="userToken" default="" />
<cfparam name="type" default="" />
<cfparam name="userid" default="0" />
<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset data = StructNew()>
<cfset data['authors'] = ArrayNew(1)>

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

<CFQUERY NAME="qGetAuthors" DATASOURCE="#request.domain_dsn#">
  SELECT tblUser.User_ID, Forename, Surname, tblUser.Submission_date, Author  
  FROM tblFile INNER JOIN tblUser ON tblFile.User_ID = tblUser.User_ID 
  WHERE Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(userid)> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND tblUser.User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#">)</cfif>
  GROUP BY tblUser.User_ID 
  ORDER BY tblUser.Submission_date DESC
</CFQUERY>

<cfif qGetAuthors.RecordCount>
  <cfif CompareNoCase(type,"author") EQ 0>
    <cfloop query="qGetAuthors">
      <CFQUERY NAME="qGetAuthor" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblFile 
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetAuthors.User_ID#"> AND (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(userid)> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#">)</cfif>)
      </CFQUERY>
      <cfif qGetAuthor.RecordCount>
        <cfset authors = ListRemoveDuplicates(ValueList(qGetAuthor.Author))>
        <cfloop list="#authors#" index="authorName">
          <cfset obj = StructNew()>
          <cfset obj['userid'] = qGetAuthors.User_ID>
          <cfset obj['forename'] = qGetAuthors.Forename>
          <cfset obj['surname'] = qGetAuthors.Surname>
          <cfset obj['createdAt'] = qGetAuthors.Submission_date>
          <CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
            SELECT * 
            FROM tblFile 
            WHERE Author = <cfqueryparam cfsqltype="cf_sql_varchar" value="#authorName#"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetAuthors.User_ID#"> AND (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(userid)> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#">)</cfif>)
          </CFQUERY>
          <cfset obj['author'] = "">
		  <cfif qGetFile.RecordCount>
            <cfset obj['author'] = qGetFile.Author>
          </cfif>
          <cfset obj['pages'] = Ceiling(qGetFile.RecordCount/request.filebatch)>
          <cfset ArrayAppend(data['authors'],obj)>
        </cfloop>
      </cfif>
    </cfloop>
  </cfif>
    <cfloop query="qGetAuthors">
      <cfset obj = StructNew()>
      <cfset obj['userid'] = qGetAuthors.User_ID>
      <cfset obj['forename'] = qGetAuthors.Forename>
      <cfset obj['surname'] = qGetAuthors.Surname>
      <cfset obj['author'] = qGetAuthors.Author>
      <cfset obj['createdAt'] = qGetAuthors.Submission_date>
      <CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblFile  
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetAuthors.User_ID#"> AND (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(userid)> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#">)</cfif>)
      </CFQUERY>
      <cfset obj['pages'] = Ceiling(qGetFile.RecordCount/request.filebatch)>
      <cfset ArrayAppend(data['authors'],obj)>
    </cfloop>
  </cfif>
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>