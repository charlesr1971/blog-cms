
<cfcomponent extends="taffy.core.resource" taffy_uri="/users/admin" taffy_docs_hide>

  <cffunction name="get">
	<cfset var local = StructNew()>
    <cfset local.jwtString = "">
    <cfset local.data = StructNew()>
    <cfset local.data['columnDefs'] = ArrayNew(1)>
	<cfset local.data['rowData'] = ArrayNew(1)>
    <cfset local.data['task'] =  "">
    <cfset local.data['userToken'] =  "">
    <cfset local.data['jwtObj'] = StructNew()>
    <cfset local.data['error'] = "">
    <cfset local.requestBody = getHttpRequestData().headers>
    <cftry>
	  <cfif StructKeyExists(local.requestBody,"task")>
		<cfset local.data['task'] =  Trim(local.requestBody['task'])>
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
    <cfswitch expression="#local.data['task']#">
      <cfcase value="suspend">
		<cfset local.columnOrder = "Surname,Forename,E_mail,Suspend,User_ID,Submission_date">
        <cfset local.columnWidth = "200,200,300,160,120,185">
        <cfset local.columnOrderTemp = "">
        <cfset local.temp = ArrayNew(1)>
        <cfset local.counter = 1>
        <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
          SELECT Surname, Forename ,E_mail, Suspend, User_ID, DATE_FORMAT(Submission_date,"%Y-%m-%d") AS Submission_date 
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
                    <cfset local.obj['suppressMenu'] = false>
                  </cfif>
                  <!---<cfset local.obj['width'] = ListGetAt(local.columnWidth,local.counter)>--->
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
      </cfcase>
      <cfcase value="password">
		<cfset local.columnOrder = "Surname,Forename,E_mail,Password,User_ID,Submission_date">
        <cfset local.columnWidth = "200,200,300,180,120,185">
        <cfset local.columnOrderTemp = "">
        <cfset local.temp = ArrayNew(1)>
        <cfset local.counter = 1>
        <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
          SELECT Surname, Forename ,E_mail, '' As Password, User_ID, DATE_FORMAT(Submission_date,"%Y-%m-%d") AS Submission_date 
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
                  <cfif CompareNoCase(local.column,"Password") EQ 0>
                    <cfset local.obj['editable'] = true>
                    <cfset local.obj['suppressMenu'] = false>
                  </cfif>
                  <!---<cfset local.obj['width'] = ListGetAt(local.columnWidth,local.counter)>--->
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
      </cfcase>
    </cfswitch>
    <!---<cfthread action="sleep" duration="15000" />--->
    <cfreturn representationOf(local.data) />
  </cffunction>
  
  <cffunction name="put">
	<cfset var local = StructNew()>
    <cfset var emailtemplateheaderbackground = request.utils.getMaterialThemePrimaryColour(theme=request.theme)>
    <cfset var emailtemplatemessage = "">
	<cfset local.uploadfolder = request.uploadfolder>
    <cfset local.emailsubject = "Message from " & request.title>
    <cfset local.jwtString = "">
    <cfset local.data = StructNew()>
    <cfset local.data['columnDefs'] = ArrayNew(1)>
	<cfset local.data['rowData'] = ArrayNew(1)>
    <cfset local.data['users'] =  ArrayNew(1)>
    <cfset local.data['task'] =  "">
    <cfset local.data['userToken'] =  "">
    <cfset local.data['jwtObj'] = StructNew()>
    <cfset local.data['createdat'] = "">
    <cfset local.data['error'] = "">
    <cfset local.requestBody = getHttpRequestData().headers>
    <cftry>
	  <cfif StructKeyExists(local.requestBody,"users")>
		<cfset local.data['users'] =  DeserializeJson(Trim(local.requestBody['users']))>
      </cfif>
      <cfif StructKeyExists(local.requestBody,"task")>
		<cfset local.data['task'] =  Trim(local.requestBody['task'])>
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
    <cfset local.emailpassword = Decrypt(request.emailPassword,request.emailSalt,request.crptographyalgorithm,request.crptographyencoding)>
    <cfinclude template="../../../../jwt-decrypt.cfm">
	<cfif StructKeyExists(local.data['jwtObj'],"jwtAuthenticated") AND NOT local.data['jwtObj']['jwtAuthenticated']>
      <cfreturn representationOf(local.data).withStatus(403,"Not Authorized") />
    </cfif>
    <cfloop from="1" to="#ArrayLen(local.data['users'])#" index="local.index">
	  <cfset local.obj = local.data['users'][local.index]>
	  <cfset local.userid = Trim(local.obj['id'])>
      <cfif Len(Trim(local.userid))>
        <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
          SELECT * 
          FROM tblUser 
          WHERE <cfif ISNUMERIC(local.userid)>User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.userid#"><cfelse>E_mail = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.userid#"></cfif>
        </CFQUERY>
        <cfif local.qGetUser.RecordCount>
		  <cfset local.forename = request.utils.CapFirst(local.qGetUser.Forename)>
          <cfswitch expression="#local.data['task']#">
            <cfcase value="suspend">
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
            </cfcase>
            <cfcase value="password">
			  <cfif Len(Trim(local.obj['password']))>
                <cftry>
                  <cfset local.encryptedstring = request.utils.Encrypts(local.obj['password'],local.qGetUser.Salt)>
                  <cfcatch>
                    <cfset local.encryptedstring = "">
                  </cfcatch>
                </cftry>
              <cfelse>
                <cfset local.encryptedstring = "">
              </cfif>
              <cfif Len(Trim(local.encryptedstring))>
                <cfset local.obj['password'] = request.utils.Hashed(local.encryptedstring,request.lckbcryptlib)>
              <cfelse>
                <cfset local.obj['password'] = "">
              </cfif>
              <cfif Len(Trim(local.obj['password']))>
                <cftransaction>
                  <CFQUERY DATASOURCE="#request.domain_dsn#">
                    UPDATE tblUser
                    SET Password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.obj['password']#"> 
                    WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUser.User_ID#">
                  </CFQUERY>
                </cftransaction>
              </cfif>
            </cfcase>
            <cfcase value="email">
			  <cfset local.data['createdat'] = Now()>
			  <cfset local.salutation = local.forename>
              <cfsavecontent variable="emailtemplatemessage">
                <cfoutput>
                  <h1>Hi<cfif Len(Trim(local.salutation))> #local.salutation#</cfif></h1>
                  <table cellpadding="0" cellspacing="0" border="0" width="100%">
                    <tr valign="middle">
                      <td width="10" bgcolor="##DDDDDD"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="10" height="1" /></td>
                      <td width="20"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="20" height="1" /></td>
                      <td style="font-size:16px;">
                        <strong style="color:##777;">Message Date:</strong><span style="color:##afafaf;"> #DateFormat(local.data['createdat'],"full")# #TimeFormat(local.data['createdat'],"full")#</span>
                      </td>
                    </tr>
                    <tr>
                      <td colspan="3" style="font-size:16px;">
                        <p>#request.utils.CapFirst(Trim(local.obj['message']))#</p>
                      </td>
                    </tr>
                    <tr>
                      <td width="10" bgcolor="##DDDDDD"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="10" height="1" /></td>
                      <td width="20"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="20" height="1" /></td>
                      <td style="font-size:16px;">
                        Yours sincerely<br /><br />
                        <strong>#request.title# Support</strong>
                      </td>
                    </tr>
                  </table>
                </cfoutput>
              </cfsavecontent>
              <cfmail to="#local.obj['email']#" from="#request.email#" server="#request.emailServer#" username="#request.emailUsername#" password="#local.emailpassword#" port="#request.emailPort#" useSSL="#request.emailUseSsl#" useTLS="#request.emailUseTls#" subject="#local.emailsubject#" type="html">
                <cfinclude template="../../../../email-template.cfm">
              </cfmail>
            </cfcase>
          </cfswitch>
        </cfif>
      </cfif>
    </cfloop>
    <cfswitch expression="#local.data['task']#">
      <cfcase value="suspend">
		<cfset local.columnOrder = "Surname,Forename,E_mail,Suspend,User_ID,Submission_date">
        <cfset local.columnWidth = "200,200,300,160,120,185">
        <cfset local.columnOrderTemp = "">
        <cfset local.temp = ArrayNew(1)>
        <cfset local.counter = 1>
        <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
          SELECT Surname, Forename ,E_mail, Suspend, User_ID, DATE_FORMAT(Submission_date,"%Y-%m-%d") AS Submission_date 
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
                    <cfset local.obj['suppressMenu'] = false>
                  </cfif>
                  <!---<cfset local.obj['width'] = ListGetAt(local.columnWidth,local.counter)>--->
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
      </cfcase>
      <cfcase value="password">
		<cfset local.columnOrder = "Surname,Forename,E_mail,Password,User_ID,Submission_date">
        <cfset local.columnWidth = "200,200,300,180,120,185">
        <cfset local.columnOrderTemp = "">
        <cfset local.temp = ArrayNew(1)>
        <cfset local.counter = 1>
        <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
          SELECT Surname, Forename ,E_mail, '' As Password, User_ID, DATE_FORMAT(Submission_date,"%Y-%m-%d") AS Submission_date 
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
                  <cfif CompareNoCase(local.column,"Password") EQ 0>
                    <cfset local.obj['editable'] = true>
                    <cfset local.obj['suppressMenu'] = false>
                  </cfif>
                  <!---<cfset local.obj['width'] = ListGetAt(local.columnWidth,local.counter)>--->
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
      </cfcase>
    </cfswitch>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>