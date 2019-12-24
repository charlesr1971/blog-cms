
<cfcomponent extends="taffy.core.resource" taffy_uri="/images/approved/userid">

  <cffunction name="get">
	<cfset var local = StructNew()>
    <cfset local['userToken'] = "">
    <cfset local['userid'] = 0>
    <cfset local.data = StructNew()>
    <cfset local.data['approved'] = true>
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
    <cfif Len(Trim(local['userToken'])) AND Val(local['userid'])>
      <CFQUERY NAME="local.qGetFile" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblFile 
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local['userid']#"> AND Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0">
      </CFQUERY>
      <cfif local.qGetFile.RecordCount>
        <cfset local.data['approved'] = false>
      </cfif>
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>