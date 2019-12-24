
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
            <cfif NOT approved>
              <CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
                SELECT * 
                FROM tblFile 
                WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#">
              </CFQUERY>
              <cfif qGetFile.RecordCount>
                <cfloop query="qGetFile">
                  <CFQUERY DATASOURCE="#request.domain_dsn#">
                    UPDATE tblFile
                    SET Approved_previous = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#qGetFile.Approved#"> 
                    WHERE File_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetFile.File_ID#">
                  </CFQUERY>
                </cfloop>
              </cfif>
              <CFQUERY DATASOURCE="#request.domain_dsn#">
                UPDATE tblFile
                SET Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#approved#"> 
                WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#">
              </CFQUERY>
            <cfelse>
              <CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
                SELECT * 
                FROM tblFile 
                WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#">
              </CFQUERY>
              <cfif qGetFile.RecordCount>
                <cfloop query="qGetFile">
                  <CFQUERY DATASOURCE="#request.domain_dsn#">
                    UPDATE tblFile
                    SET Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#qGetFile.Approved_previous#"> 
                    WHERE File_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetFile.File_ID#">
                  </CFQUERY>
                </cfloop>
              </cfif>
            </cfif>
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
          <cfif Len(Trim(obj['password']))>
            <cftransaction>
              <CFQUERY DATASOURCE="#request.domain_dsn#">
                UPDATE tblUser
                SET Password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#obj['password']#"> 
                WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#">
              </CFQUERY>
            </cftransaction>
          </cfif>
        </cfcase>
        <cfcase value="approved">
          <cftransaction>
            <CFQUERY DATASOURCE="#request.domain_dsn#">
              UPDATE tblFile
              SET Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="#obj['approved']#"> 
              WHERE File_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#obj['fileid']#">
            </CFQUERY>
          </cftransaction>
        </cfcase>
        <cfcase value="email">
		  <cfset data['createdat'] = Now()>
          <cfset salutation = forename>
          <cfsavecontent variable="emailtemplatemessage">
            <cfoutput>
              <h1><cfif Len(Trim(obj['startSalutation']))>#CapFirst(str=Trim(obj['startSalutation']),first=true)#<cfelse>Hi<cfif Len(Trim(salutation))> #salutation#</cfif></cfif></h1>
              <table cellpadding="0" cellspacing="0" border="0" width="100%">
                <tr valign="middle">
                  <td width="10" bgcolor="##DDDDDD"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="10" height="1" /></td>
                  <td width="20"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="20" height="1" /></td>
                  <td style="font-size:16px;">
                    <strong style="color:##777;">Message Date:</strong><span style="color:##afafaf;"> #DateFormat(data['createdat'],"full")# #TimeFormat(data['createdat'],"full")#</span>
                  </td>
                </tr>
                <tr>
                  <td colspan="3" style="font-size:16px;">
                    <p>#CapFirst(Trim(obj['message']))#</p>
                  </td>
                </tr>
                <tr>
                  <td width="10" bgcolor="##DDDDDD"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="10" height="1" /></td>
                  <td width="20"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="20" height="1" /></td>
                  <td style="font-size:16px;">
                    <cfif Len(Trim(obj['endSalutation']))>#CapFirst(str=Trim(obj['endSalutation']),first=true)#<cfelse>Yours sincerely</cfif><br /><br />
                    <strong><cfif Len(Trim(obj['credit']))>#CapFirst(str=Trim(obj['credit']),first=true)#<cfelse>#request.title# Support</cfif></strong>
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
	<cfset columnOrder = "Surname,Forename,E_mail,Suspend,User_ID,SystemUser,Submission_date">
    <cfset columnOrderTemp = "">
    <cfset temp = ArrayNew(1)>
    <cfset counter = 1>
    <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
      SELECT Surname, Forename ,E_mail, Suspend, User_ID, SystemUser, DATE_FORMAT(Submission_date,"%Y-%m-%d") AS Submission_date 
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
      <cfset data['rowData'] = QueryToArray(query=qGetUser)>
    <cfelse>
      <cfset data['error'] = "No users found">
    </cfif>
  </cfcase>
  <cfcase value="password">
	<cfset columnOrder = "Surname,Forename,E_mail,Password,User_ID,SystemUser,Submission_date">
    <cfset columnOrderTemp = "">
    <cfset temp = ArrayNew(1)>
    <cfset counter = 1>
    <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
      SELECT Surname, Forename ,E_mail, '' As Password, User_ID, SystemUser, DATE_FORMAT(Submission_date,"%Y-%m-%d") AS Submission_date 
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
      <cfset data['rowData'] = QueryToArray(query=qGetUser)>
    <cfelse>
      <cfset data['error'] = "No users found">
    </cfif>
  </cfcase>
  <cfcase value="approved">
	<cfset columnOrder = "Surname,Forename,E_mail,Title,Approved,User_ID,File_ID,File_uuid,SystemUser,Submission_date">
    <cfset columnOrderTemp = "">
    <cfset temp = ArrayNew(1)>
    <cfset counter = 1>
    <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
      SELECT Surname, Forename ,E_mail, Title, Approved, tblUser.User_ID, File_ID, File_uuid, SystemUser, DATE_FORMAT(tblFile.Submission_date,"%Y-%m-%d") AS Submission_date 
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
      <cfset data['rowData'] = QueryToArray(query=qGetUser)>
    <cfelse>
      <cfset data['error'] = "No users found">
    </cfif>
  </cfcase>
</cfswitch>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>