<cfoutput>

  <cfif Len(Trim(local.data['userToken'])) AND Len(Trim(local.jwtString))>
    <cfset local.data['jwtObj'] = request.utils.DecryptJwt(usertoken=local.data['userToken'],jwtString=local.jwtString,refreshExpiredToken=request.refreshExpiredToken)>
    <cfif NOT local.data['jwtObj']['jwtAuthenticated']>
      <cfset local.jwtObj = Duplicate(local.data['jwtObj'])>
      <cfset local.data = StructNew()>
      <cfset local.data['jwtObj'] = local.jwtObj >
      <cfset local.data['error'] = "The user failed JWT Token authentication">
    </cfif>
  <cfelse>
      <cfset local.data = StructNew()>
      <cfset local.data['jwtObj']['jwtAuthenticated'] = false>
      <cfset local.data['jwtObj']['jwtError'] = "User's JWT Token cannot be verified">
      <cfset local.data['error'] = "JWT credentials were not supplied correctly">
  </cfif>

</cfoutput>