
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type,Authorization,userToken" />

<cfparam name="page" default="1" />
<cfparam name="startrow" default="1" />
<cfparam name="endrow" default="#request.agGridTableBatch#" />

<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset startrow = 1>
<cfset endrow = request.agGridTableBatch>
<cfif Val(page) AND Val(request.agGridTableBatch)>
  <cfif page GT 1>
	<cfset startrow = Int((page - 1) * request.agGridTableBatch) + 1>
	<cfset endrow = (startrow + request.agGridTableBatch) - 1>
  <cfelse>
	<cfset endrow = (startrow + request.agGridTableBatch) - 1>
  </cfif>
</cfif>

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

<cfset columnOrder = "Surname,Forename,E_mail,User_ID,SystemUser,Submission_date">
<cfset columnOrderTemp = "">
<cfset temp = ArrayNew(1)>
<cfset counter = 1>
<CFQUERY NAME="qGetUserArchive" DATASOURCE="#request.domain_dsn#">
  SELECT Surname, Forename ,E_mail, User_ID, SystemUser, DATE_FORMAT(Submission_date,"%Y-%m-%d") AS Submission_date   
  FROM tblUserArchive 
  ORDER BY Surname ASC
</CFQUERY>
<cfif qGetUserArchive.RecordCount>
  <cfset columns = qGetUserArchive.columnList>
  <cfloop list="#columns#" index="column">
	<cfset obj = StructNew()>
	<cfset columnName = ReplaceNoCase(Trim(LCase(column)),"_"," ","ALL")>
	<cfset obj['headerName'] = CapFirstAll(str=columnName)>
	<cfset obj['field'] = Trim(LCase(column))>
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
            <cfset obj['cellRenderer'] = "formatEmailRenderer">
		  </cfif>
		  <cfset obj['field'] = data['columnDefs'][index]['field']>
		  <cfset ArrayAppend(temp,obj)>
		  <cfset columnOrderTemp = ListAppend(columnOrderTemp,column)>
		  <cfset counter = counter + 1>
		</cfif>
	  </cfloop>
	</cfloop>
	<cfset data['columnDefs'] = temp>
  </cfif>
  <cfset data['rowData'] = QueryToArray(query=qGetUserArchive,startrow=startrow,endrow=endrow)>
<cfelse>
  <cfset data['error'] = "No users found">
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>