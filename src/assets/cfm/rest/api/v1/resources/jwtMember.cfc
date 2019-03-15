
<cfcomponent extends="taffy.core.resource" taffy_uri="/jwt/{userToken}">

  <cffunction name="get">
      <cfargument name="userToken" type="string" required="yes" />
	  <cfset var local = StructNew()>
      <cfset local.jwtString = "">
      <cfset local.data = StructNew()>
      <cfset local.data['userToken'] = arguments.usertoken EQ 'empty' ? '' : arguments.usertoken>
      <cfset local.data['jwtObj'] = StructNew()>
      <cfset local.data['error'] = "">
      <cfset local.requestBody = getHttpRequestData().headers>
      <cftry>
        <cfif StructKeyExists(local.requestBody,"Authorization")>
		  <cfset local.jwtString = request.utils.GetJwtString(Trim(local.requestBody['Authorization']))>
        </cfif>
        <cfcatch>
		  <cfset local.data['error'] = cfcatch.message>
        </cfcatch>
      </cftry>
      <cfinclude template="../../../../jwt-decrypt.cfm">
      <cfif StructKeyExists(local.data['jwtObj'],"jwtAuthenticated") AND NOT local.data['jwtObj']['jwtAuthenticated']>
        <cfreturn representationOf(local.data).withStatus(403,"Not Authorized") />
      </cfif>
      <cfset local.data['jwtObj'] = request.utils.DecryptJwt(usertoken=local.data['userToken'],jwtString=local.jwtString,refreshExpiredToken=request.refreshExpiredToken)>
	  <cfif NOT local.data['jwtObj']['jwtAuthenticated']>
        <cfset local.jwtObj = Duplicate(local.data['jwtObj'])>
        <cfset local.data = StructNew()>
        <cfset local.data['jwtObj'] = local.jwtObj >
        <cfset local.data['error'] = "The user failed JWT Token authentication">
        <cfreturn representationOf(local.data).withStatus(403,"Not Authorized") />
      </cfif>
      <cfreturn representationOf(local.data) />
  </cffunction>
  
</cfcomponent>