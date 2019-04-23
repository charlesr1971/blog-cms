
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
<cfset data['task'] =  "">
<cfset data['userToken'] =  "">
<cfset data['error'] = "">

<cfset requestBody = toString(getHttpRequestData().content)>
<cfset requestBody = Trim(requestBody)>
<cftry>
  <cfset requestBody = DeserializeJSON(requestBody)>
  <cfif StructKeyExists(requestBody,"task")>
	<cfset data['task'] = requestBody['task']>
  </cfif>
  <cfcatch>
    <cftry>
      <cfset requestBody = REReplaceNoCase(requestBody,"[\s+]"," ","ALL")>
      <cfset requestBody = DeserializeJSON(requestBody)>
      <cfif StructKeyExists(requestBody,"task")>
		<cfset data['task'] = requestBody['task']>
      </cfif>
      <cfcatch>
		<cfset data['error'] = cfcatch.message>
      </cfcatch>
    </cftry>
  </cfcatch>
</cftry>

<cfset requestBody = getHttpRequestData().headers>
<cftry>
  <cfif StructKeyExists(requestBody,"userToken")>
	<cfset data['userToken'] = Trim(requestBody['userToken'])>
  </cfif>
  <cfcatch>
	<cfset data['error'] = cfcatch.message>
  </cfcatch>
</cftry>

<cfswitch expression="#data['task']#">
  <cfcase value="suspend">
	<cfset columnOrder = "Surname,Forename,E_mail,Suspend,User_ID,Submission_date">
    <cfset columnOrderTemp = "">
    <cfset temp = ArrayNew(1)>
    <cfset counter = 1>
    <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
      SELECT Surname, Forename ,E_mail, Suspend, User_ID, DATE_FORMAT(Submission_date,"%Y-%m-%d") AS Submission_date 
      FROM tblUser 
      ORDER BY Surname ASC
    </CFQUERY>
    <cfif qGetUser.RecordCount>
      <cfset columns = qGetUser.columnList>
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
              <cfif CompareNoCase(column,"Suspend") EQ 0>
                <cfset obj['editable'] = true>
                <cfset obj['cellEditor'] = "numericCellEditor">
                <cfset obj['suppressMenu'] = false>
              </cfif>
              <cfset ArrayAppend(temp,obj)>
              <cfset columnOrderTemp = ListAppend(columnOrderTemp,column)>
              <cfset counter = counter + 1>
            </cfif>
          </cfloop>
        </cfloop>
        <cfset data['columnDefs'] = temp>
      </cfif>
      <cfset data['rowData'] = QueryToArray(query=qGetUser,startrow=startrow,endrow=endrow)>
    <cfelse>
      <cfset data['error'] = "No users found">
    </cfif>
  </cfcase>
  <cfcase value="password">
	<cfset columnOrder = "Surname,Forename,E_mail,Password,User_ID,Submission_date">
    <cfset columnOrderTemp = "">
    <cfset temp = ArrayNew(1)>
    <cfset counter = 1>
    <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
      SELECT Surname, Forename ,E_mail, '' As Password, User_ID, DATE_FORMAT(Submission_date,"%Y-%m-%d") AS Submission_date 
      FROM tblUser 
      ORDER BY Surname ASC
    </CFQUERY>
    <cfif qGetUser.RecordCount>
      <cfset columns = qGetUser.columnList>
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
              <cfif CompareNoCase(column,"Password") EQ 0>
                <cfset obj['editable'] = true>
                <cfset obj['suppressMenu'] = false>
              </cfif>
              <cfset ArrayAppend(temp,obj)>
              <cfset columnOrderTemp = ListAppend(columnOrderTemp,column)>
              <cfset counter = counter + 1>
            </cfif>
          </cfloop>
        </cfloop>
        <cfset data['columnDefs'] = temp>
      </cfif>
      <cfset data['rowData'] = QueryToArray(query=qGetUser,startrow=startrow,endrow=endrow)>
    <cfelse>
      <cfset data['error'] = "No users found">
    </cfif>
  </cfcase>
  <cfcase value="approved">
	<cfset columnOrder = "Surname,Forename,E_mail,Title,Approved,User_ID,File_ID,File_uuid,Submission_date">
    <cfset columnOrderTemp = "">
    <cfset temp = ArrayNew(1)>
    <cfset counter = 1>
    <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
      SELECT Surname, Forename ,E_mail, Title, Approved, tblUser.User_ID, File_ID, File_uuid, DATE_FORMAT(tblFile.Submission_date,"%Y-%m-%d") AS Submission_date 
      FROM tblUser INNER JOIN tblFile ON tblUser.User_ID = tblFile.User_ID
      ORDER BY Surname ASC, Title ASC
    </CFQUERY>
    <cfif qGetUser.RecordCount>
      <cfset columns = qGetUser.columnList>
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
              <cfif CompareNoCase(column,"Title") EQ 0>
                <cfset obj['cellRenderer'] = "formatFileTitleRenderer">
              </cfif>
              <cfset obj['field'] = data['columnDefs'][index]['field']>
              <cfif CompareNoCase(column,"Approved") EQ 0>
                <cfset obj['editable'] = true>
                <cfset obj['cellEditor'] = "numericCellEditor">
                <cfset obj['suppressMenu'] = false>
              </cfif>
              <cfset ArrayAppend(temp,obj)>
              <cfset columnOrderTemp = ListAppend(columnOrderTemp,column)>
              <cfset counter = counter + 1>
            </cfif>
          </cfloop>
        </cfloop>
        <cfset data['columnDefs'] = temp>
      </cfif>
      <cfset data['rowData'] = QueryToArray(query=qGetUser,startrow=startrow,endrow=endrow)>
    <cfelse>
      <cfset data['error'] = "No users found">
    </cfif>
  </cfcase>
</cfswitch>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>