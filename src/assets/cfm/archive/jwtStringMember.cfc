
<cfcomponent extends="taffy.core.resource" taffy_uri="/jwtString" taffy_docs_hide>

  <cffunction name="get">
	  <cfset var local = StructNew()>
      <cfset local.jwtString = "">
      <cfset local.data = StructNew()>
      <cfset local.data['jwtString'] = "">
      <cfset local.data['userToken'] = "">
      <cfset local.data['error'] = "">
	  <cfif StructKeyExists(application,"jwtString")>
        <cflock name="jwtString" type="exclusive" timeout="30">
          <cfset local.data['jwtString'] = application.jwtString>
        </cflock>
      </cfif>
      <cfif StructKeyExists(application,"userToken")>
        <cflock name="userToken" type="exclusive" timeout="30">
          <cfset local.data['userToken'] = application.userToken>
        </cflock>
      </cfif>
      <cfreturn representationOf(local.data) />
  </cffunction>
  
</cfcomponent>