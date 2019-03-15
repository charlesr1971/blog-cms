
<cfcomponent extends="taffy.core.resource" taffy_uri="/token">

  <cffunction name="get">
	<cfset var local = StructNew()>
    <cfset local.data = StructNew()>
    <cfset local.data['token'] = LCase(CreateUUID())>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>