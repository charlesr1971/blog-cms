
<cfcomponent extends="taffy.core.resource" taffy_uri="/pages/{fileUuid}">

  <cffunction name="get">
    <cfargument name="fileUuid" type="string" required="yes" />
	<cfset var local = StructNew()>
    <cfset local.data = StructNew()>
	 <cfset local.data['pages'] = 0>
    <CFQUERY NAME="local.qGetComments" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblComment 
      WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fileUuid#">
    </CFQUERY>
    <cfif local.qGetComments.RecordCount>
      <cfset local.data['pages'] = Ceiling(local.qGetComments.RecordCount/request.commentbatch)>
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>