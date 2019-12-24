
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type,Authorization,userToken" />

<cfparam name="uploadfolder" default="#request.uploadfolder#" />
<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset data = StructNew()>
<cfset data['commentid'] = 0>
<cfset data['error'] = "">

<cfset requestBody = toString(getHttpRequestData().content)>
<cfset requestBody = Trim(requestBody)>
<cftry>
  <cfset requestBody = DeserializeJSON(requestBody)>
  <cfif StructKeyExists(requestBody,"commentid")>
	<cfset data['commentid'] = Trim(requestBody['commentid'])>
  </cfif>
  <cfcatch>
    <cftry>
      <cfset requestBody = REReplaceNoCase(requestBody,"[\s+]"," ","ALL")>
      <cfset requestBody = DeserializeJSON(requestBody)>
      <cfif StructKeyExists(requestBody,"commentid")>
		<cfset data['commentid'] = Trim(requestBody['commentid'])>
      </cfif>
      <cfcatch>
		<cfset data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
  </cfcatch>
</cftry>

<cftry>
  <cfif Val(data['commentid'])>
    <CFQUERY DATASOURCE="#request.domain_dsn#">
      DELETE
      FROM tblComment
      WHERE Comment_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['commentid']#"> 
    </CFQUERY>
    <CFQUERY DATASOURCE="#request.domain_dsn#">
      DELETE
      FROM tblComment
      WHERE Reply_to_comment_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#data['commentid']#"> 
    </CFQUERY>
    <cfset data['error'] = "">
  </cfif>
  <cfcatch>
    <cfset data['error'] = "Record for this comment cannot be found">
  </cfcatch>
</cftry>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>