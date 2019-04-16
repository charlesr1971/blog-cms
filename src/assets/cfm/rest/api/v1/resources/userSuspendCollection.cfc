
<cfcomponent extends="taffy.core.resource" taffy_uri="/users/suspend" taffy_docs_hide>

  <cffunction name="get">
	<cfset var local = StructNew()>
    <cfset local.jwtString = "">
    <cfset local.data = StructNew()>
    <cfset local.data['columnDefs'] = ArrayNew(1)>
	<cfset local.data['rowData'] = ArrayNew(1)>
    <cfset local.data['userToken'] =  "">
    <cfset local.data['jwtObj'] = StructNew()>
    <cfset local.data['error'] = "">
    <cfset local.requestBody = getHttpRequestData().headers>
    <cftry>
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
    <cfinclude template="../../../../jwt-decrypt.cfm">
	<cfif StructKeyExists(local.data['jwtObj'],"jwtAuthenticated") AND NOT local.data['jwtObj']['jwtAuthenticated']>
      <cfreturn representationOf(local.data).withStatus(403,"Not Authorized") />
    </cfif>
    <cfset local.columnOrder = "Surname,Forename,E_mail,Suspend,User_ID">
    <cfset local.columnWidth = "100,100,100,100,100">
    <cfset local.columnOrderTemp = "">
    <cfset local.temp = ArrayNew(1)>
    <cfset local.counter = 1>
    <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
      SELECT Surname, Forename ,E_mail, Suspend, User_ID  
      FROM tblUser 
      ORDER BY Surname ASC
    </CFQUERY>
    <cfif local.qGetUser.RecordCount>
	  <cfset local.columns = local.qGetUser.columnList>
      <cfloop list="#local.columns#" index="local.column">
		<cfset local.obj = StructNew()>
        <cfset local.columnName = ReplaceNoCase(Trim(LCase(column)),"_"," ","ALL")>
        <cfset local.obj['headerName'] = request.utils.CapFirstAll(str=local.columnName)>
        <cfset local.obj['field'] = Trim(LCase(local.column))>
        <cfset ArrayAppend(local.data['columnDefs'],local.obj)>
      </cfloop>
      <cfif ArrayLen(local.data['columnDefs'])>
        <cfloop list="#local.columnOrder#" index="local.column">
          <cfloop from="1" to="#ArrayLen(local.data['columnDefs'])#" index="local.index">
			<cfset local.field = local.data['columnDefs'][local.index]['field']>
            <cfif CompareNoCase(local.field,local.column) EQ 0 AND NOT ListFindNoCase(local.columnOrderTemp,local.column)>
			  <cfset local.obj = StructNew()>
              <cfset local.obj['headerName'] = local.data['columnDefs'][local.index]['headerName']>
              <cfif CompareNoCase(local.column,"E_mail") EQ 0>
				<cfset local.obj['headerName'] = "E-mail">
                <cfset local.obj['cellRenderer'] = "formatEmailRenderer">
              </cfif>
              <cfset local.obj['field'] = local.data['columnDefs'][local.index]['field']>
              <cfif CompareNoCase(local.column,"Suspend") EQ 0>
				<cfset local.obj['editable'] = true>
                <cfset local.obj['cellEditor'] = "numericCellEditor">
              </cfif>
			  <cfset ArrayAppend(local.temp,local.obj)>
              <cfset local.columnOrderTemp = ListAppend(local.columnOrderTemp,local.column)>
              <cfset local.counter = local.counter + 1>
            </cfif>
          </cfloop>
        </cfloop>
        <cfset local.data['columnDefs'] = local.temp>
      </cfif>
      <cfset local.data['rowData'] = request.utils.QueryToArray(query=local.qGetUser)>
    <cfelse>
	  <cfset local.data['error'] = "No archived users found">
    </cfif>
    <!---<cfthread action="sleep" duration="15000" />--->
    <cfreturn representationOf(local.data) />
  </cffunction>
  
  <cffunction name="put">
	<cfset var local = StructNew()>
    <cfset local.jwtString = "">
    <cfset local.data = StructNew()>
    <cfset local.data['columnDefs'] = ArrayNew(1)>
	<cfset local.data['rowData'] = ArrayNew(1)>
    <cfset local.data['users'] =  ArrayNew(1)>
    <cfset local.data['userToken'] =  "">
    <cfset local.data['jwtObj'] = StructNew()>
    <cfset local.data['error'] = "">
    <cfset local.requestBody = getHttpRequestData().headers>
    <cftry>
	  <cfif StructKeyExists(local.requestBody,"users")>
		<cfset local.data['users'] =  DeserializeJson(Trim(local.requestBody['users']))>
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
    <cfinclude template="../../../../jwt-decrypt.cfm">
	<cfif StructKeyExists(local.data['jwtObj'],"jwtAuthenticated") AND NOT local.data['jwtObj']['jwtAuthenticated']>
      <cfreturn representationOf(local.data).withStatus(403,"Not Authorized") />
    </cfif>
    <cfloop from="1" to="#ArrayLen(local.data['users'])#" index="local.index">
	  <cfset local.obj = local.data['users'][local.index]>
	  <cfset local.userid = Val(Trim(local.obj['id']))>
      <cfif local.userid>
        <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
          SELECT * 
          FROM tblUser 
          WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.userid#">
        </CFQUERY>
        <cfif local.qGetUser.RecordCount>
          <cftransaction>
            <CFQUERY DATASOURCE="#request.domain_dsn#">
              UPDATE tblUser
              SET Suspend = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#local.obj['suspend']#"> 
              WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUser.User_ID#">
            </CFQUERY>
            <cfset local.approved = local.obj['suspend'] EQ 1 ? 0 : 1>
            <CFQUERY DATASOURCE="#request.domain_dsn#">
              UPDATE tblFile
              SET Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#local.approved#"> 
              WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUser.User_ID#">
            </CFQUERY>
            <CFQUERY DATASOURCE="#request.domain_dsn#">
              UPDATE tblComment
              SET Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#local.approved#"> 
              WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUser.User_ID#">
            </CFQUERY>
          </cftransaction>
        </cfif>
      </cfif>
    </cfloop>
    <cfset local.columnOrder = "Surname,Forename,E_mail,Suspend,User_ID">
    <cfset local.columnWidth = "100,100,100,100,100">
    <cfset local.columnOrderTemp = "">
    <cfset local.temp = ArrayNew(1)>
    <cfset local.counter = 1>
    <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
      SELECT Surname, Forename ,E_mail, Suspend, User_ID  
      FROM tblUser 
      ORDER BY Surname ASC
    </CFQUERY>
    <cfif local.qGetUser.RecordCount>
	  <cfset local.columns = local.qGetUser.columnList>
      <cfloop list="#local.columns#" index="local.column">
		<cfset local.obj = StructNew()>
        <cfset local.columnName = ReplaceNoCase(Trim(LCase(column)),"_"," ","ALL")>
        <cfset local.obj['headerName'] = request.utils.CapFirstAll(str=local.columnName)>
        <cfset local.obj['field'] = Trim(LCase(local.column))>
        <cfset ArrayAppend(local.data['columnDefs'],local.obj)>
      </cfloop>
      <cfif ArrayLen(local.data['columnDefs'])>
        <cfloop list="#local.columnOrder#" index="local.column">
          <cfloop from="1" to="#ArrayLen(local.data['columnDefs'])#" index="local.index">
			<cfset local.field = local.data['columnDefs'][local.index]['field']>
            <cfif CompareNoCase(local.field,local.column) EQ 0 AND NOT ListFindNoCase(local.columnOrderTemp,local.column)>
			  <cfset local.obj = StructNew()>
              <cfset local.obj['headerName'] = local.data['columnDefs'][local.index]['headerName']>
              <cfif CompareNoCase(local.column,"E_mail") EQ 0>
				<cfset local.obj['headerName'] = "E-mail">
                <cfset local.obj['cellRenderer'] = "formatEmailRenderer">
              </cfif>
              <cfset local.obj['field'] = local.data['columnDefs'][local.index]['field']>
              <cfif CompareNoCase(local.column,"Suspend") EQ 0>
				<cfset local.obj['editable'] = true>
                <cfset local.obj['cellEditor'] = "numericCellEditor">
              </cfif>
			  <cfset ArrayAppend(local.temp,local.obj)>
              <cfset local.columnOrderTemp = ListAppend(local.columnOrderTemp,local.column)>
              <cfset local.counter = local.counter + 1>
            </cfif>
          </cfloop>
        </cfloop>
        <cfset local.data['columnDefs'] = local.temp>
      </cfif>
      <cfset local.data['rowData'] = request.utils.QueryToArray(query=local.qGetUser)>
    <cfelse>
	  <cfset local.data['error'] = "No archived users found">
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>