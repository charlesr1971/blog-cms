
<cfcomponent extends="taffy.core.resource" taffy_uri="/system/user/{quantity}" taffy_docs_hide>

  <cffunction name="post">
    <cfargument name="quantity" type="numeric" required="yes" />
    <cfset var local = StructNew()>
    <cfset local.salt = request.crptographykey>
    <cfset local.jwtString = "">
    <cfset local.data = StructNew()>
    <cfset local.data['userToken'] = "">
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
    <cfif Val(arguments.quantity)>
	  <cfset local.temp = ArrayNew(1)>
      <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblUser 
      </CFQUERY>
      <cfset local.emails = "">
      <cfif local.qGetUser.RecordCount>
		<cfset local.emails = ListRemoveDuplicates(ValueList(local.qGetUser.E_mail))>
      </cfif>
      <cfloop from="1" to="#arguments.quantity#" index="local.index">
		<cfset local.simulationData = request.utils.GenerateSimulationData()>
        <cfloop condition="ListFind(local.emails,local.simulationData['email'])">
		  <cfset local.simulationData = request.utils.GenerateSimulationData()>
        </cfloop>
		<cfset local.encryptedstring = request.utils.Encrypts(local.simulationData['password'],local.salt)>
        <cfset local.password = request.utils.Hashed(local.encryptedstring,request.lckbcryptlib)>
        <cfset local.forename = request.utils.CapFirst(local.simulationData['forename'])>
        <cfset local.surname = request.utils.CapFirst(local.simulationData['surname'])>
        <cfset local.email = Trim(REReplaceNoCase(local.simulationData['email'],"[\s]+","","ALL"))>
        <cfset local.emails = ListAppend(local.emails,local.email)>
        <CFQUERY DATASOURCE="#request.domain_dsn#" result="local.queryInsertResult">
          INSERT INTO tblUser (Salt,Password,E_mail,Forename,Surname,SignUpToken,SignUpValidated,SystemUser) 
          VALUES (<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.salt#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.password#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.email#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.forename#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#local.surname#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#LCase(CreateUUID())#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="1">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="1">)
        </CFQUERY>
        <cfset local.obj = StructNew()>
        <cfset local.obj['userid'] = local.queryInsertResult.generatedkey>
        <cfset local.obj['password'] = local.simulationData['password']>
        <cfset local.obj['email'] = local.email>
        <cfset local.obj['forename'] = local.forename>
        <cfset local.obj['surname'] = local.surname>
        <cfset ArrayAppend(local.temp,local.obj)>
      </cfloop> 
      <cfset local.data['systemUsers'] = local.temp>
      <cfset local.data['error'] = "">
    <cfelse>
	  <cfset local.data['error'] = "System users could not be created">
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>