
<cfcomponent extends="taffy.core.resource" taffy_uri="/recaptcha">

  <cffunction name="get">
    <cfargument name="token" type="string" required="no" default="" />
    <cfset var local = StructNew()>
    <cfset local.data = StructNew()>
    <cfset local.data['success'] = true>
    
    <cfhttp url="https://www.google.com/recaptcha/api/siteverify" method="post" result="local.result" timeout="30">
      <cfhttpparam type="formfield" name="secret" value="#request.googleRecaptchaSecretKey#" />
      <cfhttpparam type="formfield" name="response" value="#arguments.token#" />
    </cfhttp>
    
    <cfif StructKeyExists(local.result,"Filecontent")>
      <cfif IsJson(local.result['Filecontent'])>
		<cfset local.result = DeserializeJson(local.result['Filecontent'])>
        <cfif StructKeyExists(local.result,"success")>
		  <cfset local.data['success'] = local.result['success'] EQ 'NO' ? false: true>
        </cfif>
      </cfif>
    </cfif>
    
    <cfreturn representationOf(local.data) />
    
  </cffunction>

</cfcomponent>