
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="content-type,Authorization,userToken" />

<cfparam name="quantity" default="1" />

<cfparam name="salt" default="#request.crptographykey#" />

<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset data = StructNew()>
<cfset data['usertoken'] = "">
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

<cfif Val(quantity)>
  <cfset temp = ArrayNew(1)>
  <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
    SELECT * 
    FROM tblUser 
  </CFQUERY>
  <cfset emails = "">
  <cfif qGetUser.RecordCount>
    <cfset emails = ListRemoveDuplicates(ValueList(qGetUser.E_mail))>
  </cfif>
  <cfloop from="1" to="#quantity#" index="index">
    <cfset simulationData = GenerateSimulationData()>
    <cfloop condition="ListFind(emails,simulationData['email'])">
      <cfset simulationData = GenerateSimulationData()>
    </cfloop>
    <cfset encryptedstring = Encrypts(simulationData['password'],salt)>
    <cfset password = Hashed(encryptedstring,request.lckbcryptlib)>
    <cfset forename = CapFirst(simulationData['forename'])>
    <cfset surname = CapFirst(simulationData['surname'])>
    <cfset email = Trim(REReplaceNoCase(simulationData['email'],"[\s]+","","ALL"))>
	<cfset emails = ListAppend(emails,email)>
    <CFQUERY DATASOURCE="#request.domain_dsn#" result="queryInsertResult">
      INSERT INTO tblUser (Salt,Password,E_mail,Forename,Surname,SignUpToken,SignUpValidated,SystemUser) 
      VALUES (<cfqueryparam cfsqltype="cf_sql_varchar" value="#salt#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#password#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#email#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#forename#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#surname#">,<cfqueryparam cfsqltype="cf_sql_varchar" value="#LCase(CreateUUID())#">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="1">,<cfqueryparam cfsqltype="cf_sql_tinyint" value="1">)
    </CFQUERY>
    <cfset obj = StructNew()>
    <cfset obj['userid'] = queryInsertResult.generatedkey>
    <cfset obj['password'] = simulationData['password']>
    <cfset obj['email'] = email>
    <cfset obj['forename'] = forename>
    <cfset obj['surname'] = surname>
    <cfset ArrayAppend(temp,obj)>
  </cfloop> 
  <cfset data['systemUsers'] = temp>
  <cfset data['error'] = "">
<cfelse>
  <cfset data['error'] = "System users could not be created">
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>