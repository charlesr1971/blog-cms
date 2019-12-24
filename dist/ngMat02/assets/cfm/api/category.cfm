
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="Authorization,userToken" />

<cfparam name="addEmptyFlag" default="false" />
<cfparam name="formatWithKeys" default="false" />
<cfparam name="flattenParentArray" default="false" />

<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset qGetDirPlusId = ParseDirectory(path=request.filepath & "/categories")>

<cfset directories = CleanArray(directories=ConvertDirectoryQueryToArray(query=qGetDirPlusId,addEmptyFlag=addEmptyFlag),formatWithKeys=formatWithKeys,flattenParentArray=flattenParentArray)>

<cfset data = SerializeJSON(directories)>
<cfset data = ReplaceNoCase(data,"\","/","ALL")>

<cfoutput>
#data#
</cfoutput>