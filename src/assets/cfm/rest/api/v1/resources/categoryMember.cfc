
<cfcomponent extends="taffy.core.resource" taffy_uri="/category/{addEmptyFlag}/{formatWithKeys}/{flattenParentArray}">

  <cffunction name="get">
    <cfargument name="addEmptyFlag" type="boolean" required="yes" />
    <cfargument name="formatWithKeys" type="boolean" required="yes" />
    <cfargument name="flattenParentArray" type="boolean" required="yes" />
	<cfset var local = StructNew()>
    <cfset local.data = StructNew()>
	<cfset local.qGetDirPlusId = request.utils.ParseDirectory(path=request.filepath & "/categories")>
	<cfset local.directories = request.utils.CleanArray(directories=request.utils.ConvertDirectoryQueryToArray(query=local.qGetDirPlusId,addEmptyFlag=arguments.addEmptyFlag),formatWithKeys=arguments.formatWithKeys,flattenParentArray=arguments.flattenParentArray)>
    <cfset local.data = SerializeJSON(local.directories)>
    <cfset local.data = ReplaceNoCase(local.data,"\","/","ALL")>
    <cfset local.data = DeserializeJSON(local.data)>
    <cfreturn representationOf(local.data) />
  </cffunction>
  
  
  <cffunction name="put">
    <cfargument name="addEmptyFlag" type="boolean" required="yes" />
    <cfargument name="formatWithKeys" type="boolean" required="yes" />
    <cfargument name="flattenParentArray" type="boolean" required="yes" />
	<cfset var local = StructNew()>
    <cfset local.current = StructNew()>
    <cfset local.current['categories'] = StructNew()>
	<cfset local.qGetDirPlusId = request.utils.ParseDirectory(path=request.filepath & "/categories")>
	<cfset local.current['categories'] = request.utils.CleanArray(directories=request.utils.ConvertDirectoryQueryToArray(query=local.qGetDirPlusId,addEmptyFlag=arguments.addEmptyFlag),formatWithKeys=arguments.formatWithKeys,flattenParentArray=arguments.flattenParentArray)>
    <cfset local.jwtString = "">
    <cfset local.authorized = true>
    <cfset local.data = StructNew()>
    <cfset local.data['categories'] =  "">
    <cfset local.data['userToken'] = "">
    <cfset local.data['jwtObj'] = StructNew()>
    <cfset local.data['error'] = "">
    <cfset local.requestBody = getHttpRequestData().headers>
    <cftry>
      <cfset local.data['categories'] =  DeserializeJSON(Trim(ToString(getHttpRequestData().content)))>
      <cfif StructKeyExists(local.data['categories'],"categories")>
		<cfset local.data['categories'] =  local.data['categories']['data']>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"userToken")>
		<cfset local.data['userToken'] =  Trim(local.requestBody['userToken'])>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"Authorization")>
        <cfset local.jwtString = request.utils.GetJwtString(Trim(local.requestBody['Authorization']))>
      </cfif>
      <cfcatch>
        <cfset local.data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
    <!---<cfdump var="#local.current['categories']#" />
    <cfdump var="#local.data['categories']#" />
    <cfdump var="#SerializeJSON(local.data['categories'])#" abort />--->
    <cfinclude template="../../../../jwt-decrypt.cfm">
	<cfif StructKeyExists(local.data['jwtObj'],"jwtAuthenticated") AND NOT local.data['jwtObj']['jwtAuthenticated']>
      <cfreturn representationOf(local.data).withStatus(403,"Not Authorized") />
    </cfif>
    <cfset local.directories = request.utils.UpdateCategories(currentObj=local.current['categories'],newObj=local.data['categories'],addEmptyFlag=true,formatWithKeys=true,flattenParentArray=true)>
    <!---<cfdump var="#local.directories#" abort />--->
    <cfset local.data = SerializeJSON(local.directories)>
    <cfset local.data = ReplaceNoCase(local.data,"\","/","ALL")>
    <cfset local.data = DeserializeJSON(local.data)>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>