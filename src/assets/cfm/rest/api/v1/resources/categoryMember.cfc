
<cfcomponent extends="taffy.core.resource" taffy_uri="/category">

  <cffunction name="get">
	<cfset var local = StructNew()>
    <cfset local.data = StructNew()>
	<cfset local.qGetDirPlusId = request.utils.ParseDirectory(path=request.filepath & "/categories")>
	<cfset local.directories = request.utils.CleanArray(directories=request.utils.ConvertDirectoryQueryToArray(query=local.qGetDirPlusId),formatWithKeys=false)>
    <cfset local.data = SerializeJSON(local.directories)>
    <cfset local.data = ReplaceNoCase(local.data,"\","/","ALL")>
    <cfset local.data = DeserializeJSON(local.data)>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>