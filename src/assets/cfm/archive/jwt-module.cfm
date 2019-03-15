<cfswitch expression="#attributes.type#">
  
  <cfcase value="encrypt">
  
	<cfset local = StructNew()>
  
	<cfset local.claimset = {iss=request.absoluteBaseUrl,sub="Charles Robertson",aud=request.absoluteBaseUrl,exp=DateAdd("s",(1000 * 60 * 10),Now()),nbf=Now(),iat=Now(),jti=attributes.jwtid,claim={json=SerializeJson({userToken=attributes.usertoken})}}>
	<cfset local.JwtSignEncrypt = request.encrypter.init(claimSet=local.claimset,javaLoaderClassPath="",jarSystemPath="",useJavaLoader=true,javaLoaderInstance=request.jwtjavaloader)>
	<cfset local.secretKeyEncoded = local.JwtSignEncrypt.GetSecretKeyEncoded()>
	<cfset caller.jwtString = local.JwtSignEncrypt.Encrypt(secretKeyEncoded=local.secretKeyEncoded)>
    
    <cfif Len(Trim(caller.jwtString)) AND IsBinary(local.secretKeyEncoded)>
      <CFQUERY DATASOURCE="#request.domain_dsn#">
        UPDATE tblUserToken
        SET Secret_key = <cfqueryparam cfsqltype="cf_sql_blob" value="#local.secretKeyEncoded#">, Jwt_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.jwtid#">
        WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.usertoken#">
      </CFQUERY>
    </cfif>
    
  </cfcase>

</cfswitch>