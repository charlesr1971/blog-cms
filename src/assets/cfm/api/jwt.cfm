
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type,Authorization,userToken" />

<cfparam name="userToken" default="" />

<cfinclude template="../functions.cfm">

<cfset jwtString = "">
<cfset data = StructNew()>
<cfset data['userToken'] = userToken>
<cfset data['jwtObj'] = StructNew()>
<cfset data['error'] = "">
<cfset requestBody = getHttpRequestData().headers>
<cftry>
  <cfif StructKeyExists(requestBody,"Authorization")>
	<cfset jwtString = GetJwtString(Trim(requestBody['Authorization']))>
  </cfif>
  <cfcatch>
	<cfset data['error'] = cfcatch.message>
  </cfcatch>
</cftry>
<cfset data['jwtObj'] = DecryptJwt(usertoken=data['userToken'],jwtString=jwtString,refreshExpiredToken=request.refreshExpiredToken)>
<cfif NOT data['jwtObj']['jwtAuthenticated']>
  <cfset data['error'] = "The user failed JWT Token authentication">
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>