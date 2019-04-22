
<cfcomponent extends="taffy.core.resource" taffy_uri="/users/archive" taffy_docs_hide>

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
    <cfset local.columnOrder = "Surname,Forename,E_mail,User_ID,Submission_date">
    <cfset local.columnOrderTemp = "">
    <cfset local.temp = ArrayNew(1)>
    <cfset local.counter = 1>
    <CFQUERY NAME="local.qGetUserArchive" DATASOURCE="#request.domain_dsn#">
      SELECT Surname, Forename ,E_mail, User_ID, DATE_FORMAT(Submission_date,"%Y-%m-%d") AS Submission_date   
      FROM tblUserArchive 
      ORDER BY Surname ASC
    </CFQUERY>
    <cfif local.qGetUserArchive.RecordCount>
	  <cfset local.columns = local.qGetUserArchive.columnList>
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
			  <cfset ArrayAppend(local.temp,local.obj)>
              <cfset local.columnOrderTemp = ListAppend(local.columnOrderTemp,local.column)>
              <cfset local.counter = local.counter + 1>
            </cfif>
          </cfloop>
        </cfloop>
        <cfset local.data['columnDefs'] = local.temp>
      </cfif>
      <cfset local.data['rowData'] = request.utils.QueryToArray(query=local.qGetUserArchive)>
    <cfelse>
	  <cfset local.data['error'] = "No users found">
    </cfif>
    <!---<cfthread action="sleep" duration="100000" />--->
    <cfreturn representationOf(local.data) />
  </cffunction>

  <cffunction name="post">
	<cfset var local = StructNew()>
    <cfset local.jwtString = "">
    <cfset local.data = StructNew()>
    <cfset local.data['columnDefs'] = ArrayNew(1)>
	<cfset local.data['rowData'] = ArrayNew(1)>
    <cfset local.data['userIds'] =  "">
    <cfset local.data['userToken'] =  "">
    <cfset local.data['jwtObj'] = StructNew()>
    <cfset local.data['error'] = "">
    <cfset local.requestBody = getHttpRequestData().headers>
    <cftry>
	  <cfif StructKeyExists(local.requestBody,"userIds")>
		<cfset local.data['userIds'] =  Trim(local.requestBody['userIds'])>
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
    <cfloop list="#local.data['userIds']#" index="local.userid">
	  <cfset local.userid = Val(Trim(local.userid))>
      <cfif local.userid>
        <CFQUERY NAME="local.qGetUserArchive" DATASOURCE="#request.domain_dsn#">
          SELECT * 
          FROM tblUserArchive 
          WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.userid#">
        </CFQUERY>
        <cfif local.qGetUserArchive.RecordCount>
          <cftransaction>
            <CFQUERY DATASOURCE="#request.domain_dsn#">
              INSERT INTO tblUser (User_ID,Role_ID,Salt,Password,E_mail,Forename,Surname,Cfid,Cftoken,SignUpToken,SignUpValidated,Clientfilename,Filename,Email_notification,Keep_logged_in,Submit_article_notification,Cookie_acceptance,Theme,ForgottenPasswordToken,ForgottenPasswordValidated,Suspend) 
              VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUserArchive.User_ID#">,<cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUserArchive.Role_ID#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.qGetUserArchive.Salt#" null="#yesNoFormat(NOT len(trim(local.qGetUserArchive.Salt)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.qGetUserArchive.Password#" null="#yesNoFormat(NOT len(trim(local.qGetUserArchive.Password)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.qGetUserArchive.E_mail#" null="#yesNoFormat(NOT len(trim(local.qGetUserArchive.E_mail)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.qGetUserArchive.Forename#" null="#yesNoFormat(NOT len(trim(local.qGetUserArchive.Forename)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.qGetUserArchive.Surname#" null="#yesNoFormat(NOT len(trim(local.qGetUserArchive.Surname)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.qGetUserArchive.Cfid#" null="#yesNoFormat(NOT len(trim(local.qGetUserArchive.Cfid)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.qGetUserArchive.Cftoken#" null="#yesNoFormat(NOT len(trim(local.qGetUserArchive.Cftoken)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.qGetUserArchive.SignUpToken#" null="#yesNoFormat(NOT len(trim(local.qGetUserArchive.SignUpToken)))#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#local.qGetUserArchive.SignUpValidated#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.qGetUserArchive.Clientfilename#" null="#yesNoFormat(NOT len(trim(local.qGetUserArchive.Clientfilename)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.qGetUserArchive.Filename#" null="#yesNoFormat(NOT len(trim(local.qGetUserArchive.Filename)))#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#local.qGetUserArchive.Email_notification#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#local.qGetUserArchive.Keep_logged_in#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#local.qGetUserArchive.Submit_article_notification#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#local.qGetUserArchive.Cookie_acceptance#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.qGetUserArchive.Theme#" null="#yesNoFormat(NOT len(trim(local.qGetUserArchive.Theme)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.qGetUserArchive.ForgottenPasswordToken#" null="#yesNoFormat(NOT len(trim(local.qGetUserArchive.ForgottenPasswordToken)))#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#local.qGetUserArchive.ForgottenPasswordValidated#" null="#yesNoFormat(NOT len(trim(local.qGetUserArchive.ForgottenPasswordValidated)))#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#local.qGetUserArchive.Suspend#" null="#yesNoFormat(NOT len(trim(local.qGetUserArchive.Suspend)))#">)
            </CFQUERY>
            <CFQUERY NAME="local.qGetFileArchive" DATASOURCE="#request.domain_dsn#">
              SELECT * 
              FROM tblFileArchive 
              WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.userid#">
            </CFQUERY>
            <cfloop query="local.qGetFileArchive">
              <CFQUERY DATASOURCE="#request.domain_dsn#">
                INSERT INTO tblFile (File_ID,User_ID,File_uuid,Category,Clientfilename,Filename,ImagePath,Author,Title,Description,Article,Size,Likes,Cfid,Cftoken,Tags,Publish_article_date,Approved,Approved_previous,FileToken,Submission_date) 
                VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetFileArchive.File_ID#">,<cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetFileArchive.User_ID#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.qGetFileArchive.File_uuid#" null="#yesNoFormat(NOT len(trim(local.qGetFileArchive.File_uuid)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.qGetFileArchive.Category#" null="#yesNoFormat(NOT len(trim(local.qGetFileArchive.Category)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.qGetFileArchive.Clientfilename#" null="#yesNoFormat(NOT len(trim(local.qGetFileArchive.Clientfilename)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.qGetFileArchive.Filename#" null="#yesNoFormat(NOT len(trim(local.qGetFileArchive.Filename)))#">,<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#local.qGetFileArchive.ImagePath#" null="#yesNoFormat(NOT len(trim(local.qGetFileArchive.ImagePath)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.qGetFileArchive.Author#" null="#yesNoFormat(NOT len(trim(local.qGetFileArchive.Author)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.qGetFileArchive.Title#" null="#yesNoFormat(NOT len(trim(local.qGetFileArchive.Title)))#">,<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#local.qGetFileArchive.Description#" null="#yesNoFormat(NOT len(trim(local.qGetFileArchive.Description)))#">,<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#local.qGetFileArchive.Article#" null="#yesNoFormat(NOT len(trim(local.qGetFileArchive.Article)))#">,<cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetFileArchive.Size#">,<cfqueryparam cfsqltype="cf_sql_integer" value="0">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.qGetFileArchive.Cfid#" null="#yesNoFormat(NOT len(trim(local.qGetFileArchive.Cfid)))#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.qGetFileArchive.Cftoken#" null="#yesNoFormat(NOT len(trim(local.qGetFileArchive.Cftoken)))#">,<cfqueryparam cfsqltype="cf_sql_longvarchar" value="#local.qGetFileArchive.Tags#" null="#yesNoFormat(NOT len(trim(local.qGetFileArchive.Tags)))#">,<cfqueryparam cfsqltype="cf_sql_timestamp" value="#local.qGetFileArchive.Publish_article_date#" null="#yesNoFormat(NOT len(trim(local.qGetFileArchive.Publish_article_date)))#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#local.qGetFileArchive.Approved#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="#local.qGetFileArchive.Approved_previous#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.qGetFileArchive.FileToken#" null="#yesNoFormat(NOT len(trim(local.qGetFileArchive.FileToken)))#">,<cfqueryparam cfsqltype="cf_sql_timestamp" value="#local.qGetFileArchive.Submission_date#">)
              </CFQUERY>
            </cfloop>
            <CFQUERY DATASOURCE="#request.domain_dsn#">
              DELETE 
              FROM tblUserArchive
              WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.userid#">
            </CFQUERY>
            <CFQUERY DATASOURCE="#request.domain_dsn#">
              DELETE 
              FROM tblFileArchive
              WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.userid#">
            </CFQUERY>
          </cftransaction>
        </cfif>
      </cfif>
    </cfloop>
    <cfset local.columnOrder = "Surname,Forename,E_mail,User_ID,Submission_date">
    <cfset local.columnOrderTemp = "">
    <cfset local.temp = ArrayNew(1)>
    <cfset local.counter = 1>
    <CFQUERY NAME="local.qGetUserArchive" DATASOURCE="#request.domain_dsn#">
      SELECT Surname, Forename ,E_mail, User_ID, DATE_FORMAT(Submission_date,"%Y-%m-%d") AS Submission_date   
      FROM tblUserArchive 
      ORDER BY Surname ASC
    </CFQUERY>
    <cfif local.qGetUserArchive.RecordCount>
	  <cfset local.columns = local.qGetUserArchive.columnList>
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
			  <cfset ArrayAppend(local.temp,local.obj)>
              <cfset local.columnOrderTemp = ListAppend(local.columnOrderTemp,local.column)>
              <cfset local.counter = local.counter + 1>
            </cfif>
          </cfloop>
        </cfloop>
        <cfset local.data['columnDefs'] = local.temp>
      </cfif>
      <cfset local.data['rowData'] = request.utils.QueryToArray(query=local.qGetUserArchive)>
    <cfelse>
	  <cfset local.data['error'] = "No users found">
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>