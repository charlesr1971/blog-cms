<cfoutput>

  <!---<cfparam name="metaData" default="#StructNew()#">
  <cfparam name="funcName" default="">
  <cfparam name="currentResource" default="#StructNew()#">
  <cfparam name="componentName" default="">--->

  <cfloop collection="#request.requestMetaData#" item="item">
    <cfif CompareNoCase(item,componentName) EQ 0>
      <cfif StructKeyExists(request.requestMetaData[item],funcName)>
        <cfloop collection="#request.requestMetaData[item][funcName]#" item="requestItem">
          <cfif CompareNoCase(requestItem,"requestHeader") EQ 0>
            <cfset requestHeader = request.requestMetaData[item][funcName][requestItem]>
            <cfloop list="#requestHeader#" index="header">
              <cfset header = ListToArray(header,"^",true)>
              <cfset headerName = header[1]>
              <cfset headerDataType = header[2]>
              <cfset headerDataFormat = "">
              <cfif ArrayLen(header) GT 2>
                <cfset headerDataFormat = header[3]>
              </cfif>
              <div class="param-container">
                <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span style="color:##0C0;">header:</span><cfif Len(Trim(headerName))> <strong>#headerName#</strong>:</cfif> <span style="color:##36F;">#headerDataType#</span><cfif Len(Trim(headerDataFormat))>: <span style="color:##900;">#headerDataFormat#</span></cfif></div>
              </div>
            </cfloop>
          </cfif>
          <cfif CompareNoCase(requestItem,"body") EQ 0>
            <cfset requestBody = request.requestMetaData[item][funcName][requestItem]>
            <cfloop list="#requestBody#" index="body" >
			  <cfset body = ListToArray(body,"^",true)>
              <cfset bodyName = body[1]>
              <cfset bodyDataType = body[2]>
              <cfset bodyDataFormat = "">
              <cfif ArrayLen(body) GT 2>
                <cfset bodyDataFormat = body[3]>
              </cfif>
              <div class="param-container">
                <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span style="color:##90C;">body:</span><cfif Len(Trim(bodyName))> <strong>#bodyName#</strong>:</cfif> <span style="color:##36F;">#bodyDataType#</span><cfif Len(Trim(bodyDataFormat))>: <span style="color:##900;">#bodyDataFormat#</span></cfif></div>
              </div>
            </cfloop>
          </cfif>
        </cfloop>
      </cfif>
    </cfif>
  </cfloop>

</cfoutput>