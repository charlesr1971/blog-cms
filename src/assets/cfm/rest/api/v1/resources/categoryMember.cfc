
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
	<cfset local.directories = request.utils.CleanArray(directories=request.utils.ConvertDirectoryQueryToArray(query=local.qGetDirPlusId,addEmptyFlag=arguments.addEmptyFlag),formatWithKeys=arguments.formatWithKeys,flattenParentArray=arguments.flattenParentArray)>
    <cfset local.current['categories'] = SerializeJSON(local.directories)>
    <cfset local.current['categories'] = ReplaceNoCase(local.current['categories'],"\","/","ALL")>
    <cfset local.current['categories'] = DeserializeJSON(local.current['categories'])>
    
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
    <cfdump var="#SerializeJSON(local.data['categories'])#" abort />
    <cfinclude template="../../../../jwt-decrypt.cfm">
	<cfif StructKeyExists(local.data['jwtObj'],"jwtAuthenticated") AND NOT local.data['jwtObj']['jwtAuthenticated']>
      <cfreturn representationOf(local.data).withStatus(403,"Not Authorized") />
    </cfif>
    
    <cfset local.new = StructNew()>
    
    <cfloop collection="#local.current['categories']#" item="local.currentChild">
    
	  <cfset local.currentEmpty = ListLast(local.currentChild,"^")>
	  <cfset local.currentOriginalPath = REReplaceNoCase(ListFirst(local.currentChild,"^"),"[//]+","/","ALL")>
    
	  <cfif StructKeyExists(local.data['categories'],"data") AND IsArray(local.data['categories']['data']) AND ArrayLen(local.data['categories']['data']) AND IsObject(local.data['categories']['data'][1]) AND StructKeyExists(local.data['categories']['data'][1],"children") AND IsArray(local.data['categories']['data'][1]['children']) AND ArrayLen(local.data['categories']['data'][1]['children'])>
      
        <cfset local.new['categories'] = local.data['categories']['data'][1]['children']>
        
        <cfloop from="1" to="#local.data['categories']['data'][1]['children']#" index="local.newChild">
          <cfset local.obj = local.data['categories']['data'][1]['children']['local.newChild']>
          <cfif StructKeyExists(local.obj,"children") AND IsArray(local.obj['children']) AND StructKeyExists(local.obj,"empty") AND StructKeyExists(local.obj,"isDeleted") AND StructKeyExists(local.obj,"item") AND StructKeyExists(local.obj,"originalPath") AND StructKeyExists(local.obj,"path")>
            <cfset local.newChildren = local.obj['children']>
            <cfset local.newEmpty = local.obj['empty']>
            <cfset local.newIsDeleted = LCase(local.obj['isDeleted']) EQ 'yes' ? true : false>
            <cfset local.newCategory = local.obj['item']>
            <cfset local.newOriginalPath = REReplaceNoCase(ListFirst(local.obj['originalPath'],"^"),"[//]+","/","ALL")>
            <cfset local.newPath = REReplaceNoCase(ListFirst(local.obj['path'],"^"),"[//]+","/","ALL")>
            
            
            
          </cfif>
        </cfloop>
        
        <cfdump var="#local.current['categories']#" />
        <cfdump var="#local.data['categories']['data'][1]#" />
      
      </cfif>
      
      
    </cfloop>
    
    
    
    <cfabort />
    
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>