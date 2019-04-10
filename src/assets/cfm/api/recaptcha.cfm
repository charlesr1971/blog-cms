
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="Authorization,userToken" />

<cfparam name="uploadfolder" default="#request.uploadfolder#" />
<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="token" default="" />
<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset data = StructNew()>
<cfset data['success'] = true>

<cfhttp url="https://www.google.com/recaptcha/api/siteverify" method="post" result="result" timeout="30">
  <cfhttpparam type="formfield" name="secret" value="#request.googleRecaptchaSecretKey#" />
  <cfhttpparam type="formfield" name="response" value="#token#" />
</cfhttp>

<cfif StructKeyExists(result,"Filecontent")>
  <cfif IsJson(result['Filecontent'])>
    <cfset result = DeserializeJson(result['Filecontent'])>
    <cfif StructKeyExists(result,"success")>
      <cfset data['success'] = result['success'] EQ 'NO' ? false: true>
    </cfif>
  </cfif>
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>