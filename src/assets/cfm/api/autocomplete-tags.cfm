
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type,Authorization,userToken" />

<cfparam name="term" default="" />
<cfparam name="useTerm" default="true" />

<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="userToken" default="" />
<cfparam name="userid" default="0" />
<cfparam name="data" default="#StructNew()#" />

<cfinclude template="../functions.cfm">

<cfset data = ArrayNew(1)>

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
  WHERE Tags IS NOT NULL OR Tags <> <cfqueryparam cfsqltype="cf_sql_longvarchar" value=""> AND (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(userid)> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#">)</cfif>)
  GROUP BY Tags
</CFQUERY>

<cfset tagList = "">
<cfset alphabet = "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z">
<cfset tagListLimitRandomised = "">

<cfif qGetFile.RecordCount>
  <cfloop query="qGetFile">
    <cfset tagList = ListAppend(tagList,TagsToList(qGetFile.Tags))>
  </cfloop>
</cfif>

<cfset tagList = ListRemoveDuplicates(tagList,",",true)>
<cfset tagList = ListSort(tagList,"textnocase","asc")>
<cfset alphaListLimitLength = 5>

<cfset tagListTerm = "">

<cfset term = URLDecode(term)>

<cfloop list="#tagList#" index="tag">
  <cfif FindNoCase(term,tag)>
	<cfset tagListTerm = ListAppend(tagListTerm,tag)>
  </cfif>
</cfloop>

<cfif useTerm>
  <cfset tagList = tagListTerm>
</cfif>

<cfloop list="#alphabet#" index="alpha">
  <cfset alphaList = "">
  <cfloop list="#tagList#" index="tag">
    <cfif CompareNoCase(Mid(tag,1,1),alpha) EQ 0>
      <cfset alphaList = ListAppend(alphaList,tag)>
    </cfif>
  </cfloop>
  <cfif Len(Trim(alphaList))>
	<cfset alphaListLimit = "">
    <cfset alphaListPosition = "">
    <cfloop condition="ListLen(alphaListLimit) LT alphaListLimitLength">
	  <cfset alphaPosition = RandRange(1,ListLen(alphaList))>
      <cfif NOT ListFindNoCase(alphaListPosition,alphaPosition)>
		<cfset alphaListPosition = ListAppend(alphaListPosition,alphaPosition)>
      </cfif>
      <cfset alphaListLimitItem = ListGetAt(alphaList,alphaPosition)>
      <cfif NOT ListFindNoCase(alphaListLimit,alphaListLimitItem) OR ListLen(alphaListPosition) EQ ListLen(alphaList)>
        <cfset alphaListLimit = ListAppend(alphaListLimit,alphaListLimitItem)>
      </cfif>
    </cfloop>
    <cfset alphaListLimit = ListRemoveDuplicates(alphaListLimit,",",true)>
    <cfset alphaListLimit = ListSort(alphaListLimit,"textnocase","asc")>
    <cfset tagListLimitRandomised = ListAppend(tagListLimitRandomised,alphaListLimit)>
  </cfif>
</cfloop>

<cfloop list="#tagListLimitRandomised#" index="tag">
  <cfset obj = StructNew()>
  <cfset obj['display'] = tag>
  <cfset obj['value'] = tag>
  <cfset ArrayAppend(data,obj)>
</cfloop>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>