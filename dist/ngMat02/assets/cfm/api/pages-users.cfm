
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="Authorization,userToken" />

<cfparam name="type" default="user" />
<cfparam name="startrow" default="1" />
<cfparam name="endrow" default="#request.agGridTableBatch#" />

<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="data" default="#StructNew()#" />

<cfinclude template="../functions.cfm">

<cfset data['pages'] = 0>
<cfset data['pagessurnames'] = ArrayNew(1)>
<cfset data['pagesnumeric'] = ArrayNew(1)>
<cfset data['currentrow'] = ArrayNew(1)>
<cfset data['alphahits'] = ArrayNew(1)>
<cfif CompareNocase(arguments.type,"userarchive") EQ 0>
  <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
	SELECT * 
	FROM tblUserArchive 
  </CFQUERY>
<cfelseif CompareNocase(arguments.type,"user") EQ 0>
  <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
	SELECT * 
	FROM tblUser 
  </CFQUERY>
<cfelseif CompareNocase(arguments.type,"user_join_file") EQ 0>
  <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
	SELECT * 
	FROM tblUser INNER JOIN tblFile ON tblUser.User_ID = tblFile.User_ID
  </CFQUERY>
</cfif>
<cfif qGetUser.RecordCount>
  <cfset data['pages'] = Ceiling(qGetUser.RecordCount/request.agGridTableBatch)>
  <cfloop from="1" to="#data['pages']#" index="page">
	<cfset startalpha = "">
	<cfset endalpha = "">
	<cfif Val(page) AND Val(request.agGridTableBatch)>
	  <cfif page GT 1>
		<cfset startrow = Int((page - 1) * request.agGridTableBatch) + 1>
		<cfset endrow = (startrow + request.agGridTableBatch) - 1>
	  <cfelse>
		<cfset endrow = (startrow + request.agGridTableBatch) - 1>
	  </cfif>
	</cfif>
	<cfif CompareNocase(arguments.type,"userarchive") EQ 0>
	  <CFQUERY NAME="qGetUserSurnames" DATASOURCE="#request.domain_dsn#">
		SELECT * 
		FROM tblUserArchive 
		ORDER BY Surname ASC
	  </CFQUERY>
	<cfelseif CompareNocase(arguments.type,"user") EQ 0>
	  <CFQUERY NAME="qGetUserSurnames" DATASOURCE="#request.domain_dsn#">
		SELECT * 
		FROM tblUser 
		ORDER BY Surname ASC
	  </CFQUERY>
   <cfelseif CompareNocase(arguments.type,"user_join_file") EQ 0>
	  <CFQUERY NAME="qGetUserSurnames" DATASOURCE="#request.domain_dsn#">
		SELECT * 
		FROM tblUser INNER JOIN tblFile ON tblUser.User_ID = tblFile.User_ID
		ORDER BY Surname ASC
	  </CFQUERY>   
	</cfif>
	<cfif qGetUserSurnames.RecordCount>
	  <cfloop query="qGetUserSurnames" startrow="#startrow#" endrow="#endrow#">
		<cfif qGetUserSurnames.CurrentRow EQ Val(Trim(startrow))>
		  <cfset startalpha = Mid(Trim(qGetUserSurnames.Surname),1,1)>
		  <cfset ArrayAppend(data['alphahits'],"startalpha: " & startrow)>
		</cfif>
		<cfif qGetUserSurnames.RecordCount LT Val(Trim(endrow))>
		  <cfset endrow = qGetUserSurnames.RecordCount>
		  <cfset ArrayAppend(data['alphahits'],"endalpha: " & endrow)>
		</cfif>
		<cfif qGetUserSurnames.CurrentRow EQ Val(Trim(endrow))>
		  <cfset endalpha = Mid(Trim(qGetUserSurnames.Surname),1,1)>
		  <cfset ArrayAppend(data['alphahits'],"endalpha: " & endrow)>
		</cfif>
		<cfset ArrayAppend(data['currentrow'],page & " : " & qGetUserSurnames.CurrentRow)>
	  </cfloop>
	</cfif>
	<cfset pagesurname = UCase(startalpha) & " - " & UCase(endalpha)>
	<cfset pagesurname = Trim(pagesurname)>
	<cfif Len(Trim(pagesurname)) AND CompareNoCase(pagesurname,"-") NEQ 0>
	  <cfset ArrayAppend(data['pagessurnames'],pagesurname)>
	</cfif>
	<cfset ArrayAppend(data['pagesnumeric'],startrow & " - " & endrow)>
  </cfloop>
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>