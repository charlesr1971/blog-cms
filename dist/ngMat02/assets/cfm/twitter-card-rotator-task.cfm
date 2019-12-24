
<!--

Schedule task frequency: daily
Date/time: 23:45:00
Dependency: none

-->

<cfsetting showdebugoutput="yes" requesttimeout="10000" />

<cfinclude template="functions.cfm">

<cfoutput>

  <cfparam name="title" default="Twiiter Card Rotator">
  <cfparam name="lockname" default="#LCase(REReplaceNoCase(title,'[\s:]+','','ALL'))#">
  <cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#">
  <cfparam name="prefix1" default="Date">

  <cfset date = "#DateFormat(now(),'full')#: #TimeFormat(now(),'full')#">
  <cfset taskname = title>
  <cfset subject = "Success: #taskname# from #request.title#">
  <cfset amessage = "#date#<br />#taskname#<br />TASK SUCCESSFUL<br /><br />">
  <cfset emailpassword = Decrypt(request.emailPassword,request.emailSalt,request.crptographyalgorithm,request.crptographyencoding)>
  <cfset messagedata = "">
  
  <cfif request.appreloadValidated OR isLocalhost(CGI.REMOTE_ADDR)>
  
    <cfset twitterCardObj = GetRandomTwitterCard()>
    
    <cftry>
      <cfif NOT StructIsEmpty(twitterCardObj) AND StructKeyExists(twitterCardObj,"path") AND Len(Trim(twitterCardObj['path'])) AND StructKeyExists(twitterCardObj,"url") AND Len(Trim(twitterCardObj['url']))>
        <cfsavecontent variable="messagedata">
          Twitter card was replaced successfully<br />
        </cfsavecontent>
      <cfelse>
        <cfsavecontent variable="messagedata">
          Twitter card could not be replaced<br />
        </cfsavecontent>
      </cfif>
      <cfset amessage = amessage & messagedata>
      <cfcatch>
        <cfset subject = "Error: #taskname# from #request.title#">
        <cfset amessage = "#date#<br />#taskname#<br />TASK UNSUCCESSFUL<br /><br />#cfcatch.message#<br /><br /><br />">
      </cfcatch>
    </cftry>
    
    <cfdump var="#twitterCardObj#" />
    
    <cfset plaintextmessage = REReplaceNoCase(amessage,"<br />","#request.newline#","ALL")>
    
    <cfmail to="#request.email#" from="#request.email#" server="#request.emailServer#" username="#request.emailUsername#" password="#emailpassword#" port="#request.emailPort#" useSSL="#request.emailUseSsl#" useTLS="#request.emailUseTls#" subject="#subject#" type="html">
      <cfmailpart type="html">
        #amessage#
      </cfmailpart>
      <cfmailpart type="text">
#plaintextmessage#
      </cfmailpart>
    </cfmail>
  
  </cfif>

</cfoutput>