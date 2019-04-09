
<cfcomponent extends="taffy.core.resource" taffy_uri="/recaptcha">

  <cffunction name="get">
    <cfargument name="token" type="string" required="no" default="" />
    <cfset var local = StructNew()>
    <cfset local.data = StructNew()>
    <cfset local.data['success'] = true>
    
	<!---<cfset var local = StructNew()>
    <cfset local['userToken'] = "">
    <cfset local['userid'] = 0>
    <cfset local.data = StructNew()>
	<cfset local.data['authors'] = ArrayNew(1)>
    <cfset local.requestBody = getHttpRequestData().headers>
    <cftry>
	  <cfif StructKeyExists(local.requestBody,"userToken")>
      	<cfset local['userToken'] = Trim(local.requestBody['userToken'])>
      </cfif>
      <cfcatch>
      </cfcatch>
    </cftry>
    <CFQUERY NAME="local.qGetUserID" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUserToken 
      WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local['userToken']#">
    </CFQUERY>
    <cfif local.qGetUserID.RecordCount>
	  <cfset local['userid'] = local.qGetUserID.User_ID>
    </cfif>
    <CFQUERY NAME="local.qGetAuthors" DATASOURCE="#request.domain_dsn#">
      SELECT tblUser.User_ID, Forename, Surname, tblUser.Submission_date  
      FROM tblFile INNER JOIN tblUser ON tblFile.User_ID = tblUser.User_ID 
      WHERE Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(local['userid'])> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND tblUser.User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local['userid']#">)</cfif>
      GROUP BY tblUser.User_ID 
      ORDER BY tblUser.Submission_date DESC
    </CFQUERY>
    <cfif local.qGetAuthors.RecordCount>
      <cfloop query="local.qGetAuthors">
        <cfset local.obj = StructNew()>
        <cfset local.obj['userid'] = local.qGetAuthors.User_ID>
        <cfset local.obj['forename'] = local.qGetAuthors.Forename>
        <cfset local.obj['surname'] = local.qGetAuthors.Surname>
        <cfset local.obj['createdAt'] = local.qGetAuthors.Submission_date>
        <CFQUERY NAME="local.qGetFile" DATASOURCE="#request.domain_dsn#">
          SELECT * 
          FROM tblFile 
          WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetAuthors.User_ID#"> AND (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"><cfif Val(local['userid'])> OR (Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> AND User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local['userid']#">)</cfif>)
        </CFQUERY>
        <cfset local.obj['pages'] = Ceiling(local.qGetFile.RecordCount/request.filebatch)>
        <cfset ArrayAppend(local.data['authors'],local.obj)>
      </cfloop>
    </cfif>
    <cfreturn representationOf(local.data) />--->
    
    <!---var express = require('express');
    var rp = require('request-promise');
    var cors = require('cors')
    app.use(cors());
    
    const secret = 'SECRET_KEY';
    
    app.get('/validate_captcha', (req, res) => {
      
      const options = {
        method: 'POST',
        uri: 'https://www.google.com/recaptcha/api/siteverify',
        qs: {
          secret,
          response: req.query.token  
        },
        json: true
      };
      
      rp(options)
        .then(response => res.json(response))
        .catch(() => {});
      
    });
    
    module.exports = app;--->
    
    <cfhttp url="https://www.google.com/recaptcha/api/siteverify" method="post" result="local.result" timeout="30">
      <cfhttpparam type="formfield" name="secret" value="#request.googleRecaptchaSecretKey#" />
      <cfhttpparam type="formfield" name="token" value="#arguments.token#" />
    </cfhttp>
    
    <cfif StructKeyExists(local.result,"Filecontent")>
      <cfif IsJson(local.result['Filecontent'])>
		<cfset local.result = DeserializeJson(local.result['Filecontent'])>
        <cfif StructKeyExists(local.result,"success")>
		  <cfset local.data['success'] = local.result['success'] EQ 'NO' ? false: true>
        </cfif>
      </cfif>
    </cfif>
    
    <cfreturn representationOf(local.data) />
    
  </cffunction>

</cfcomponent>