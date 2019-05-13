
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
<cfset data['userIds'] =  "">
<cfset data['userToken'] =  "">
<cfset data['error'] = "">

<cfset requestBody = toString(getHttpRequestData().content)>
<cfset requestBody = Trim(requestBody)>
<cftry>
  <cfset requestBody = DeserializeJSON(requestBody)>
  <cfif StructKeyExists(requestBody,"userids")>
  	<cfset data['userids'] = Trim(requestBody['userids'])>
  </cfif>
  <cfcatch>
    <cftry>
      <cfset requestBody = REReplaceNoCase(requestBody,"[\s+]"," ","ALL")>
      <cfset requestBody = DeserializeJSON(requestBody)>
      <cfif StructKeyExists(requestBody,"userids")>
		<cfset data['userids'] = Trim(requestBody['userids'])>
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

<cfloop list="#data['userIds']#" index="userid">
  <cfset userid = Val(Trim(userid))>
  <cfif userid>
    <CFQUERY NAME="qGetUserArchive" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUserArchive 
      WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#">
    </CFQUERY>
    <cfif qGetUserArchive.RecordCount>
      <cftransaction>
        <CFQUERY DATASOURCE="#request.domain_dsn#">
          INSERT INTO tblUser (User_ID,Role_ID,Salt,Password,E_mail,Forename,Surname,Cfid,Cftoken,SignUpToken,SignUpValidated,Clientfilename,Filename,Email_notification,Keep_logged_in,Submit_article_notification,Cookie_acceptance,Theme,ForgottenPasswordToken,ForgottenPasswordValidated,Suspend,DisplayName,SystemUser) 
          VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUserArchive.User_ID#">,<cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUserArchive.Role_ID#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetUserArchive.Salt#" null="#yesNoFormat(NOT len(trim(qGetUserArchive.Salt)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetUserArchive.Password#" null="#yesNoFormat(NOT len(trim(qGetUserArchive.Password)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetUserArchive.E_mail#" null="#yesNoFormat(NOT len(trim(qGetUserArchive.E_mail)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetUserArchive.Forename#" null="#yesNoFormat(NOT len(trim(qGetUserArchive.Forename)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetUserArchive.Surname#" null="#yesNoFormat(NOT len(trim(qGetUserArchive.Surname)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetUserArchive.Cfid#" null="#yesNoFormat(NOT len(trim(qGetUserArchive.Cfid)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetUserArchive.Cftoken#" null="#yesNoFormat(NOT len(trim(qGetUserArchive.Cftoken)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetUserArchive.SignUpToken#" null="#yesNoFormat(NOT len(trim(qGetUserArchive.SignUpToken)))#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#qGetUserArchive.SignUpValidated#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetUserArchive.Clientfilename#" null="#yesNoFormat(NOT len(trim(qGetUserArchive.Clientfilename)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetUserArchive.Filename#" null="#yesNoFormat(NOT len(trim(qGetUserArchive.Filename)))#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#qGetUserArchive.Email_notification#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#qGetUserArchive.Keep_logged_in#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#qGetUserArchive.Submit_article_notification#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#qGetUserArchive.Cookie_acceptance#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetUserArchive.Theme#" null="#yesNoFormat(NOT len(trim(qGetUserArchive.Theme)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetUserArchive.ForgottenPasswordToken#" null="#yesNoFormat(NOT len(trim(qGetUserArchive.ForgottenPasswordToken)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetUserArchive.ForgottenPasswordToken#" null="#yesNoFormat(NOT len(trim(qGetUserArchive.ForgottenPasswordToken)))#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#qGetUserArchive.ForgottenPasswordValidated#" null="#yesNoFormat(NOT len(trim(qGetUserArchive.ForgottenPasswordValidated)))#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#qGetUserArchive.Suspend#" null="#yesNoFormat(NOT len(trim(qGetUserArchive.Suspend)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetUserArchive.DisplayName#" null="#yesNoFormat(NOT len(trim(qGetUserArchive.DisplayName)))#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#qGetUserArchive.SystemUser#" null="#yesNoFormat(NOT len(trim(qGetUserArchive.SystemUser)))#">)
        </CFQUERY>
        <CFQUERY NAME="qGetFileArchive" DATASOURCE="#request.domain_dsn#">
          SELECT * 
          FROM tblFileArchive 
          WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#">
        </CFQUERY>
        <cfloop query="qGetFileArchive">
          <CFQUERY DATASOURCE="#request.domain_dsn#">
            INSERT INTO tblFile (File_ID,User_ID,File_uuid,Category,Clientfilename,Filename,ImagePath,Author,Title,Description,Article,Size,Likes,Cfid,Cftoken,Tags,Publish_article_date,Approved,Approved_previous,FileToken,Submission_date) 
            VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#qGetFileArchive.File_ID#">,<cfqueryparam cfsqltype="cf_sql_integer" value="#qGetFileArchive.User_ID#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetFileArchive.File_uuid#" null="#yesNoFormat(NOT len(trim(qGetFileArchive.File_uuid)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetFileArchive.Category#" null="#yesNoFormat(NOT len(trim(qGetFileArchive.Category)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetFileArchive.Clientfilename#" null="#yesNoFormat(NOT len(trim(qGetFileArchive.Clientfilename)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetFileArchive.Filename#" null="#yesNoFormat(NOT len(trim(qGetFileArchive.Filename)))#">,<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#qGetFileArchive.ImagePath#" null="#yesNoFormat(NOT len(trim(qGetFileArchive.ImagePath)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetFileArchive.Author#" null="#yesNoFormat(NOT len(trim(qGetFileArchive.Author)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetFileArchive.Title#" null="#yesNoFormat(NOT len(trim(qGetFileArchive.Title)))#">,<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#qGetFileArchive.Description#" null="#yesNoFormat(NOT len(trim(qGetFileArchive.Description)))#">,<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#qGetFileArchive.Article#" null="#yesNoFormat(NOT len(trim(qGetFileArchive.Article)))#">,<cfqueryparam cfsqltype="cf_sql_integer" value="#qGetFileArchive.Size#">,<cfqueryparam cfsqltype="cf_sql_integer" value="0">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetFileArchive.Cfid#" null="#yesNoFormat(NOT len(trim(qGetFileArchive.Cfid)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetFileArchive.Cftoken#" null="#yesNoFormat(NOT len(trim(qGetFileArchive.Cftoken)))#">,<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#qGetFileArchive.Tags#" null="#yesNoFormat(NOT len(trim(qGetFileArchive.Tags)))#">,<cfqueryparam cfsqltype="cf_sql_timestamp" value="#qGetFileArchive.Publish_article_date#" null="#yesNoFormat(NOT len(trim(qGetFileArchive.Publish_article_date)))#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#qGetFileArchive.Approved#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#qGetFileArchive.Approved_previous#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#qGetFileArchive.FileToken#" null="#yesNoFormat(NOT len(trim(qGetFileArchive.FileToken)))#">,<cfqueryparam cfsqltype="cf_sql_timestamp" value="#qGetFileArchive.Submission_date#">)
          </CFQUERY>
        </cfloop>
        <CFQUERY DATASOURCE="#request.domain_dsn#">
          DELETE 
          FROM tblUserArchive
          WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#">
        </CFQUERY>
        <CFQUERY DATASOURCE="#request.domain_dsn#">
          DELETE 
          FROM tblFileArchive
          WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#userid#">
        </CFQUERY>
      </cftransaction>
    </cfif>
  </cfif>
</cfloop>
    
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