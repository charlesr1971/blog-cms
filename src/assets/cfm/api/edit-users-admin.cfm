
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type,Authorization,userToken" />

<cfparam name="uploadfolder" default="#request.uploadfolder#" />
<cfparam name="emailsubject" default="Message from #request.title#" />
<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset emailtemplateheaderbackground = getMaterialThemePrimaryColour(theme=request.theme)>
<cfset emailtemplatemessage = "">

<cfset data = StructNew()>
<cfset data['columnDefs'] = ArrayNew(1)>
<cfset data['rowData'] = ArrayNew(1)>
<cfset data['users'] =  ArrayNew(1)>
<cfset data['task'] =  "">
<cfset data['userToken'] =  "">
<cfset data['createdat'] = "">
<cfset data['error'] = "">

<cfset requestBody = toString(getHttpRequestData().content)>
<cfset requestBody = Trim(requestBody)>
<cftry>
  <cfset requestBody = DeserializeJSON(requestBody)>
  <cfif StructKeyExists(requestBody,"users")>
  	<cfset data['users'] = requestBody['users']>
  </cfif>
  <cfif StructKeyExists(requestBody,"task")>
	<cfset data['task'] = requestBody['task']>
  </cfif>
  <cfcatch>
    <cftry>
      <cfset requestBody = REReplaceNoCase(requestBody,"[\s+]"," ","ALL")>
      <cfset requestBody = DeserializeJSON(requestBody)>
      <cfif StructKeyExists(requestBody,"users")>
		<cfset data['users'] = requestBody['users']>
      </cfif>
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
	<cfset userToken = Trim(requestBody['userToken'])>
  </cfif>
  <cfcatch>
	<cfset data['error'] = cfcatch.message>
  </cfcatch>
</cftry>

<cfset emailpassword = Decrypt(request.emailPassword,request.emailSalt,request.crptographyalgorithm,request.crptographyencoding)>

<cfloop from="1" to="#ArrayLen(data['users'])#" index="index">
  <cfset obj = data['users'][index]>
  <cfset userid = Trim(obj['id'])>
  <cfif Len(Trim(userid))>
    <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUser 
      WHERE <cfif ISNUMERIC(userid)>User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#"><cfelse>E_mail = <cfqueryparam cfsqltype="cf_sql_varchar" value="#userid#"></cfif>
    </CFQUERY>
    <cfif qGetUser.RecordCount>
	  <cfset forename = CapFirst(qGetUser.Forename)>
      <cfswitch expression="#data['task']#">
        <cfcase value="suspend">
          <cftransaction>
            <CFQUERY DATASOURCE="#request.domain_dsn#">
              UPDATE tblUser
              SET Suspend = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#obj['suspend']#"> 
              WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#">
            </CFQUERY>
            <cfset approved = obj['suspend'] EQ 1 ? 0 : 1>
            <CFQUERY DATASOURCE="#request.domain_dsn#">
              UPDATE tblFile
              SET Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#approved#"> 
              WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#">
            </CFQUERY>
            <CFQUERY DATASOURCE="#request.domain_dsn#">
              UPDATE tblComment
              SET Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#approved#"> 
              WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#">
            </CFQUERY>
          </cftransaction>
        </cfcase>
        <cfcase value="password">
		  <cfif Len(Trim(obj['password']))>
            <cftry>
              <cfset encryptedstring = Encrypts(obj['password'],qGetUser.Salt)>
              <cfcatch>
                <cfset encryptedstring = "">
              </cfcatch>
            </cftry>
          <cfelse>
            <cfset encryptedstring = "">
          </cfif>
          <cfif Len(Trim(encryptedstring))>
            <cfset obj['password'] = Hashed(encryptedstring,request.lckbcryptlib)>
          <cfelse>
            <cfset obj['password'] = "">
          </cfif>
          <cftransaction>
            <CFQUERY DATASOURCE="#request.domain_dsn#">
              UPDATE tblUser
              SET Password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#obj['password']#"> 
              WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#">
            </CFQUERY>
          </cftransaction>
        </cfcase>
        <cfcase value="email">
		  <cfset data['createdat'] = Now()>
          <cfset salutation = forename>
          <cfsavecontent variable="emailtemplatemessage">
            <cfoutput>
              <h1>Hi<cfif Len(Trim(salutation))> #salutation#</cfif></h1>
              <table cellpadding="0" cellspacing="0" border="0" width="100%">
                <tr valign="middle">
                  <td width="10" bgcolor="##DDDDDD"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="10" height="1" /></td>
                  <td width="20"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="20" height="1" /></td>
                  <td style="font-size:16px;">
                    #CapFirst((Trim(obj['message']))#
                  </td>
                </tr>
              </table>
            </cfoutput>
          </cfsavecontent>
          <cfmail to="#obj['email']#" from="#request.email#" server="#request.emailServer#" username="#request.emailUsername#" password="#emailpassword#" port="#request.emailPort#" useSSL="#request.emailUseSsl#" useTLS="#request.emailUseTls#" subject="#emailsubject#" type="html">
            <cfinclude template="../../../../email-template.cfm">
          </cfmail>
        </cfcase>
      </cfswitch>
    </cfif>
  </cfif>
</cfloop>

<cfswitch expression="#data['task']#">
  <cfcase value="suspend">
	<cfset columnOrder = "Surname,Forename,E_mail,Suspend,User_ID">
    <cfset columnWidth = "100,100,100,100,100">
    <cfset columnOrderTemp = "">
    <cfset temp = ArrayNew(1)>
    <cfset counter = 1>
    <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
      SELECT Surname, Forename ,E_mail, Suspend, User_ID  
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
              </cfif>
              <cfset ArrayAppend(temp,obj)>
              <cfset columnOrderTemp = ListAppend(columnOrderTemp,column)>
              <cfset counter = counter + 1>
            </cfif>
          </cfloop>
        </cfloop>
        <cfset data['columnDefs'] = temp>
      </cfif>
      <cfset data['rowData'] = QueryToArray(query=qGetUser)>
    <cfelse>
      <cfset data['error'] = "No archived users found">
    </cfif>
  </cfcase>
  <cfcase value="password">
	<cfset columnOrder = "Surname,Forename,E_mail,Password,User_ID">
    <cfset columnWidth = "100,100,100,100,100">
    <cfset columnOrderTemp = "">
    <cfset temp = ArrayNew(1)>
    <cfset counter = 1>
    <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
      SELECT Surname, Forename ,E_mail, '' As Password, User_ID  
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
              </cfif>
              <cfset ArrayAppend(temp,obj)>
              <cfset columnOrderTemp = ListAppend(columnOrderTemp,column)>
              <cfset counter = counter + 1>
            </cfif>
          </cfloop>
        </cfloop>
        <cfset data['columnDefs'] = temp>
      </cfif>
      <cfset data['rowData'] = QueryToArray(query=qGetUser)>
    <cfelse>
      <cfset data['error'] = "No archived users found">
    </cfif>
  </cfcase>
  <cfcase value="password">
	<cfset columnOrder = "Surname,Forename,E_mail,Password,User_ID">
    <cfset columnWidth = "100,100,100,100,100">
    <cfset columnOrderTemp = "">
    <cfset temp = ArrayNew(1)>
    <cfset counter = 1>
    <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
      SELECT Surname, Forename ,E_mail, '' As Password, User_ID  
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
              </cfif>
              <cfset ArrayAppend(temp,obj)>
              <cfset columnOrderTemp = ListAppend(columnOrderTemp,column)>
              <cfset counter = counter + 1>
            </cfif>
          </cfloop>
        </cfloop>
        <cfset data['columnDefs'] = temp>
      </cfif>
      <cfset data['rowData'] = QueryToArray(query=qGetUser)>
    <cfelse>
      <cfset data['error'] = "No archived users found">
    </cfif>
  </cfcase>
</cfswitch>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>