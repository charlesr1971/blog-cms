<cfoutput>

  <cfif StructKeyExists(httpRequest$,"Responseheader") AND StructKeyExists(httpRequest$['Responseheader'],"Status_code") AND StructKeyExists(httpRequest$,"FileContent")>
	<cfif IsJson(httpRequest$['FileContent'])>
	  <cfset filecontent = DeserializeJson(httpRequest$['FileContent'])>
      <cfset statuscode = Val(Trim(httpRequest$['Responseheader']['Status_code']))>
<pre><code class="json">#formatJSON(Trim(SerializeJson(filecontent)))#</code></pre>
    </cfif>
  </cfif>

</cfoutput>