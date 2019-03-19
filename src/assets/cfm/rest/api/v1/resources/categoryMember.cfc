
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

</cfcomponent>