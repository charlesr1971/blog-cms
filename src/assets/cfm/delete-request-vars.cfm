<cfoutput>

  <cfif StructKeyExists(session,"httpRequest")>
    <cfset StructDelete(session,"httpRequest")>
  </cfif>
  
  <cfif StructKeyExists(session,"verb")>
    <cfset StructDelete(session,"verb")>
  </cfif>

</cfoutput>