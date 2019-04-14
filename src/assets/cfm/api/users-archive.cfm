
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type,Authorization,userToken" />

<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset data = StructNew()>
<cfset data['columnDefs'] = ArrayNew(1)>
<cfset data['rowData'] = ArrayNew(1)>
<cfset data['userToken'] =  "">
<cfset data['error'] = "">

<cfset requestBody = getHttpRequestData().headers>
<cftry>
  <cfif StructKeyExists(requestBody,"userToken")>
	<cfset userToken = Trim(requestBody['userToken'])>
  </cfif>
  <cfcatch>
	<cfset data['error'] = cfcatch.message>
  </cfcatch>
</cftry>

<cfset columnOrder = "Surname,Forename,E_mail,User_ID">
<cfset columnWidth = "100,100,100,100">
<cfset columnOrderTemp = "">
<cfset temp = ArrayNew(1)>
<cfset counter = 1>
<CFQUERY NAME="qGetUserArchive" DATASOURCE="#request.domain_dsn#">
  SELECT Surname, Forename ,E_mail, User_ID  
  FROM tblUserArchive 
  ORDER BY Surname ASC
</CFQUERY>
<cfif qGetUserArchive.RecordCount>
  <cfset columns = qGetUserArchive.columnList>
  <cfloop list="#columns#" index="column">
	<cfset obj = StructNew()>
	<cfset columnName = ReplaceNoCase(Trim(LCase(column)),"_"," ","ALL")>
	<cfset obj['headerName'] = CapFirstAll(str=columnName)>
	<cfset obj['field'] = column>
	<cfset ArrayAppend(data['columnDefs'],obj)>
  </cfloop>
  <cfif ArrayLen(data['columnDefs'])>
	<cfloop list="#columnOrder#" index="column">
	  <cfloop from="1" to="#ArrayLen(data['columnDefs'])#" index="index">
		<cfset field = data['columnDefs'][index]['field']>
		<cfif CompareNoCase(field,column) EQ 0 AND NOT ListFindNoCase(columnOrderTemp,column)>
		  <cfset obj = StructNew()>
		  <cfset obj['headerName'] = data['columnDefs'][index]['headerName']>
		  <cfif CompareNoCase(column,"E_mail") EQ 0>
			<cfset obj['headerName'] = "E-mail">
		  </cfif>
		  <cfset obj['field'] = data['columnDefs'][index]['field']>
		  <cfif CompareNoCase(column,"User_ID") EQ 0>
			<cfset obj['checkboxSelection'] = true>
		  </cfif>
		  <cfset obj['resizable'] = true>
		  <cfset ArrayAppend(temp,obj)>
		  <cfset columnOrderTemp = ListAppend(columnOrderTemp,column)>
		  <cfset counter = counter + 1>
		</cfif>
	  </cfloop>
	</cfloop>
	<cfset data['columnDefs'] = temp>
  </cfif>
  <cfset data['rowData'] = QueryToArray(query=qGetUserArchive)>
<cfelse>
  <cfset data['error'] = "No archived users found">
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>