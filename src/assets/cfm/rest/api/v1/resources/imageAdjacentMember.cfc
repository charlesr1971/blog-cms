
<cfcomponent extends="taffy.core.resource" taffy_uri="/image/adjacent/{fileUuid}/{userid}/{direction}">

  <cffunction name="get">
    <cfargument name="fileUuid" type="string" required="yes" />
    <cfargument name="userid" type="numeric" required="yes" />
    <cfargument name="direction" type="string" required="yes" />
	<cfset var local = StructNew()>
    <cfset local['userToken'] = "">
    <cfset local['userid'] = 0>
    <cfset local.data = StructNew()>
	<cfset local.data['id'] = arguments.fileUuid>
    <cfset local.data['direction'] = arguments.direction>
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
    <CFQUERY NAME="local.qGetNextPreviousFile" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblFile 
      WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#"> AND (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(local['userid'])> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local['userid']#">)</cfif>)
    </CFQUERY>
    <cfif local.qGetNextPreviousFile.RecordCount AND Len(Trim(arguments.direction))>
      <cfloop query="local.qGetNextPreviousFile">
        <cfif CompareNoCase(local.qGetNextPreviousFile.File_uuid,arguments.fileUuid) EQ 0>
          <cfif CompareNoCase(arguments.direction,"next") EQ 0>
            <cfset local.row = local.qGetNextPreviousFile.CurrentRow + 1>
          <cfelse>
            <cfset local.row = local.qGetNextPreviousFile.CurrentRow - 1>
          </cfif>
          <cfif local.row EQ (local.qGetNextPreviousFile.RecordCount + 1) AND CompareNoCase(arguments.direction,"next") EQ 0>
            <cfset local.row = 1>
          </cfif>
          <cfif local.row LTE 0 AND CompareNoCase(arguments.direction,"previous") EQ 0>
            <cfset local.row = local.qGetNextPreviousFile.RecordCount>
          </cfif>
          <cfif local.row GT 0> 
            <cfset local.data['fileUuid'] = local.qGetNextPreviousFile['File_uuid'][local.row]>
          </cfif>
        </cfif>
      </cfloop>
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>