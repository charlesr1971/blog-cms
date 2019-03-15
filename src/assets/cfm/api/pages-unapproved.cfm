
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="Authorization,userToken" />

<cfparam name="page" default="1" />
<cfparam name="startrow" default="1" />
<cfparam name="endrow" default="#request.filebatch#" />

<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="userToken" default="" />
<cfparam name="userid" default="0" />
<cfparam name="data" default="#StructNew()#" />

<cfinclude template="../functions.cfm">

<cfset data['pages'] = 0>
<cfset data['pagestitles'] = ArrayNew(1)>
<cfset data['pagesnumeric'] = ArrayNew(1)>
<cfset data['currentrow'] = ArrayNew(1)>
<cfset data['alphahits'] = ArrayNew(1)>

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
  WHERE Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#">
</CFQUERY>

<cfif qGetFile.RecordCount>
  <cfset data['pages'] = Ceiling(qGetFile.RecordCount/request.filebatch)>
  <cfloop from="1" to="#data['pages']#" index="page">
	<cfset startalpha = "">
	<cfset endalpha = "">
	<cfif Val(page) AND Val(request.filebatch)>
      <cfif page GT 1>
        <cfset startrow = Int((page - 1) * request.filebatch) + 1>
        <cfset endrow = (startrow + request.filebatch) - 1>
      <cfelse>
        <cfset endrow = (startrow + request.filebatch) - 1>
      </cfif>
    </cfif>
    <CFQUERY NAME="qGetFileTitles" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblFile 
      WHERE Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#">
      ORDER BY Title ASC
    </CFQUERY>
    <cfif qGetFileTitles.RecordCount>
      <cfloop query="qGetFileTitles" startrow="#startrow#" endrow="#endrow#">
        <cfif qGetFileTitles.CurrentRow EQ Val(Trim(startrow))>
		  <cfset startalpha = Mid(Trim(qGetFileTitles.Title),1,1)>
          <cfset ArrayAppend(data['alphahits'],"startalpha: " & startrow)>
        </cfif>
        <cfif qGetFileTitles.RecordCount LT Val(Trim(endrow))>
		  <cfset endrow = qGetFileTitles.RecordCount>
          <cfset ArrayAppend(data['alphahits'],"endalpha: " & endrow)>
        </cfif>
        <cfif qGetFileTitles.CurrentRow EQ Val(Trim(endrow))>
		  <cfset endalpha = Mid(Trim(qGetFileTitles.Title),1,1)>
          <cfset ArrayAppend(data['alphahits'],"endalpha: " & endrow)>
        </cfif>
        <cfset ArrayAppend(data['currentrow'],page & " : " & qGetFileTitles.CurrentRow)>
      </cfloop>
    </cfif>
    <cfset pagetitle = UCase(startalpha) & " - " & UCase(endalpha)>
    <cfset pagetitle = Trim(pagetitle)>
    <cfif Len(Trim(pagetitle)) AND CompareNoCase(pagetitle,"-") NEQ 0>
	  <cfset ArrayAppend(data['pagestitles'],pagetitle)>
    </cfif>
    <cfset ArrayAppend(data['pagesnumeric'],startrow & " - " & endrow)>
  </cfloop>
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>