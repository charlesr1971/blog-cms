
<cfcomponent extends="taffy.core.resource" taffy_uri="/pages/userid/{usertoken}">

  <cffunction name="get">
    <cfargument name="usertoken" type="string" required="yes" />
	<cfset var local = StructNew()>
    <cfset local.data = StructNew()>
    <cfset local.data['usertoken'] = arguments.userToken EQ 'empty' ? '' : arguments.userToken>
	<cfset local.data['pages'] = 0>
    <cfif Len(Trim(local.data['usertoken']))>
      <CFQUERY NAME="local.qGetUserID" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblUserToken 
        WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['usertoken']#">
      </CFQUERY>
      <cfif local.qGetUserID.RecordCount>
        <CFQUERY NAME="local.qGetFiles" DATASOURCE="#request.domain_dsn#">
          SELECT * 
          FROM tblFile 
          WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUserID.User_ID#"> AND (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(local.data['usertoken'])> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUserID.User_ID#">)</cfif>)
          ORDER BY Submission_date DESC
        </CFQUERY>
        <cfif local.qGetFiles.RecordCount>
          <cfset local.data['pages'] = Ceiling(local.qGetFiles.RecordCount/request.filebatch)>
        </cfif>
      </cfif>
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>