
<cfcomponent extends="taffy.core.resource" taffy_uri="/autocompleteTags/{term}/{useTerm}">

  <cffunction name="get">
    <cfargument name="term" type="string" required="yes" />
    <cfargument name="useTerm" type="boolean" required="yes" />
	<cfset var local = StructNew()>
    <cfset local['userToken'] = "">
    <cfset local['userid'] = 0>
    <cfset local.data = ArrayNew(1)>
    <cfset local.requestBody = getHttpRequestData().headers>
    <cftry>
	  <cfif StructKeyExists(local.requestBody,"userToken")>
      	<cfset local['userToken'] = Trim(local.requestBody['userToken'])>
      </cfif>
      <cfcatch>
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
      WHERE Tags IS NOT NULL OR Tags <> <cfqueryparam cfsqltype="cf_sql_longvarchar" value=""> AND (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(local['userid'])> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local['userid']#">)</cfif>)
      GROUP BY Tags
    </CFQUERY>
    <cfset local.tagList = "">
    <cfset local.alphabet = "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z">
    <cfset local.tagListLimitRandomised = "">
    <cfif local.qGetFile.RecordCount>
      <cfloop query="local.qGetFile">
        <cfset local.tagList = ListAppend(local.tagList,request.utils.TagsToList(local.qGetFile.Tags))>
      </cfloop>
    </cfif>
    <cfset local.tagList = ListRemoveDuplicates(local.tagList,",",true)>
    <cfset local.tagList = ListSort(local.tagList,"textnocase","asc")>
    <cfset local.alphaListLimitLength = 5>
    <cfset local.tagListTerm = "">
    <cfset arguments.term = URLDecode(arguments.term)>
    <cfloop list="#local.tagList#" index="local.tag">
      <cfif FindNoCase(arguments.term,local.tag)>
        <cfset local.tagListTerm = ListAppend(local.tagListTerm,local.tag)>
      </cfif>
    </cfloop>
    <cfif arguments.useTerm>
      <cfset local.tagList = local.tagListTerm>
    </cfif>
    <cfloop list="#local.alphabet#" index="local.alpha">
      <cfset local.alphaList = "">
      <cfloop list="#local.tagList#" index="local.tag">
        <cfif CompareNoCase(Mid(local.tag,1,1),local.alpha) EQ 0>
          <cfset local.alphaList = ListAppend(local.alphaList,local.tag)>
        </cfif>
      </cfloop>
      <cfif Len(Trim(local.alphaList))>
        <cfset local.alphaListLimit = "">
        <cfset local.alphaListPosition = "">
        <cfloop condition="ListLen(local.alphaListLimit) LT local.alphaListLimitLength">
          <cfset local.alphaPosition = RandRange(1,ListLen(local.alphaList))>
          <cfif NOT ListFindNoCase(local.alphaListPosition,local.alphaPosition)>
            <cfset local.alphaListPosition = ListAppend(local.alphaListPosition,local.alphaPosition)>
          </cfif>
          <cfset local.alphaListLimitItem = ListGetAt(local.alphaList,local.alphaPosition)>
          <cfif NOT ListFindNoCase(local.alphaListLimit,local.alphaListLimitItem) OR ListLen(local.alphaListPosition) EQ ListLen(local.alphaList)>
            <cfset local.alphaListLimit = ListAppend(local.alphaListLimit,local.alphaListLimitItem)>
          </cfif>
        </cfloop>
        <cfset local.alphaListLimit = ListRemoveDuplicates(local.alphaListLimit,",",true)>
        <cfset local.alphaListLimit = ListSort(local.alphaListLimit,"textnocase","asc")>
        <cfset local.tagListLimitRandomised = ListAppend(local.tagListLimitRandomised,local.alphaListLimit)>
      </cfif>
    </cfloop>
    <cfloop list="#local.tagListLimitRandomised#" index="local.tag">
      <cfset local.obj = StructNew()>
      <cfset local.obj['display'] = local.tag>
      <cfset local.obj['value'] = local.tag>
      <cfset ArrayAppend(local.data,local.obj)>
    </cfloop>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>