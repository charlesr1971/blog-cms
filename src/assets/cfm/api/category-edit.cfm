
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type,Authorization,userToken" />

<cfparam name="addEmptyFlag" default="false" />
<cfparam name="formatWithKeys" default="false" />
<cfparam name="flattenParentArray" default="false" />

<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset current = StructNew()>
<cfset current['categories'] = StructNew()>
<cfset qGetDirPlusId = ParseDirectory(path=request.filepath & "/categories")>
<cfset current['categories'] = CleanArray(directories=ConvertDirectoryQueryToArray(query=qGetDirPlusId,addEmptyFlag=addEmptyFlag),formatWithKeys=formatWithKeys,flattenParentArray=flattenParentArray)>

<cfset data = StructNew()>
<cfset data['categories'] =  "">
<cfset data['error'] = "">

<cftry>
  <cfset data['categories'] =  DeserializeJSON(Trim(ToString(getHttpRequestData().content)))>
  <cfif StructKeyExists(data['categories'],"categories")>
	<cfset data['categories'] =  data['categories']['data']>
  </cfif>
  <cfcatch>
	<cfset data['error'] = cfcatch.message>
  </cfcatch>
</cftry>

<cfset directories = UpdateCategories(currentObj=current['categories'],newObj=data['categories'],addEmptyFlag=true,formatWithKeys=true,flattenParentArray=true)>
<cfset data = SerializeJSON(directories)>
<cfset data = ReplaceNoCase(data,"\","/","ALL")>
<cfset data = DeserializeJSON(data)>

<cfoutput>
#SerializeJson(data)#
</cfoutput>