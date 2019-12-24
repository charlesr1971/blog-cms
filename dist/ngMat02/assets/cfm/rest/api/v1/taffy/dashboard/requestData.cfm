<cfoutput>

  <cfparam name="local.metaData" default="#StructNew()#">
  <cfparam name="local.funcName" default="">
  <cfparam name="local.currentResource" default="#StructNew()#">
  <cfparam name="local.componentName" default="">

  <cfif structKeyExists(local.metaData, "taffy:dashboard:name")>
      <cfset local.componentName = local.metaData['taffy:dashboard:name']>
  <cfelseif structKeyExists(local.metaData, "taffy_dashboard_name")>
      <cfset local.componentName = local.metaData['taffy_dashboard_name']>
  <cfelseif structKeyExists(local.metaData, "taffy:docs:name")>
      <cfset local.componentName = local.metaData['taffy:docs:name']>
  <cfelseif structKeyExists(local.metaData, "taffy_docs_name")>
      <cfset local.componentName = local.metaData['taffy_docs_name']>
  <cfelse>
	<cfif structKeyExists(local.currentResource, "beanName")>
	  <cfset local.componentName = local.currentResource.beanName>
    </cfif>
  </cfif>
  <cfloop collection="#request.requestMetaData#" item="local.item">
    <cfif CompareNoCase(local.item,local.componentName) EQ 0>
      <cfif StructKeyExists(request.requestMetaData[item],local.funcName)>
        <cfloop collection="#request.requestMetaData[item][local.funcName]#" item="local.requestItem">
          <cfif CompareNoCase(local.requestItem,"requestHeader") EQ 0>
            <cfset local.requestHeader = request.requestMetaData[item][local.funcName][local.requestItem]>
            <cfloop list="#local.requestHeader#" index="local.header">
              <cfset local.header = ListToArray(local.header,"^",true)>
              <cfset local.headerName = local.header[1]>
              <cfset local.headerDataType = local.header[2]>
              <cfset local.headerDataFormat = "">
              <cfif ArrayLen(local.header) GT 2>
                <cfset local.headerDataFormat = local.header[3]>
              </cfif>
              <div class="row">
                <div class="col-md-11 col-md-offset-1">
                  required <em style="color:##0C0;">header:</em><cfif Len(Trim(local.headerName))> <strong>#local.headerName#</strong>:</cfif> <span style="color:##36F;">#local.headerDataType#</span><cfif Len(Trim(local.headerDataFormat))>: <span style="color:##900;">#local.headerDataFormat#</span></cfif>
                </div>
              </div>
            </cfloop>
          </cfif>
          <cfif CompareNoCase(local.requestItem,"body") EQ 0>
            <cfset local.requestBody = request.requestMetaData[item][local.funcName][local.requestItem]>
            <cfloop list="#local.requestBody#" index="local.body" >
			  <cfset local.body = ListToArray(local.body,"^",true)>
              <cfset local.bodyName = local.body[1]>
              <cfset local.bodyDataType = local.body[2]>
              <cfset local.bodyDataFormat = "">
              <cfif ArrayLen(local.body) GT 2>
                <cfset local.bodyDataFormat = local.body[3]>
              </cfif>
              <div class="row">
                <div class="col-md-11 col-md-offset-1">
                  required <em style="color:##90C;">body:</em><cfif Len(Trim(local.bodyName))> <strong>#local.bodyName#</strong>:</cfif> <span style="color:##36F;">#local.bodyDataType#</span><cfif Len(Trim(local.bodyDataFormat))>: <span style="color:##900;">#local.bodyDataFormat#</span></cfif>
                </div>
              </div>
            </cfloop>
          </cfif>
        </cfloop>
      </cfif>
    </cfif>
  </cfloop>

</cfoutput>