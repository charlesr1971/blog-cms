
<cfcomponent extends="taffy.core.resource" taffy_uri="/pages/user/{type}" taffy_docs_hide>

  <cffunction name="get">
    <cfargument name="type" type="string" required="yes" />
	<cfset var local = StructNew()>
    <cfset local.startrow = 1>
    <cfset local.endrow = request.agGridTableBatch>
    <cfset local.data = StructNew()>
    <cfset local.data['pages'] = 0>
	<cfset local.data['pagessurnames'] = ArrayNew(1)>
    <cfset local.data['pagesnumeric'] = ArrayNew(1)>
    <cfset local.data['currentrow'] = ArrayNew(1)>
    <cfset local.data['alphahits'] = ArrayNew(1)>
    <cfif CompareNocase(arguments.type,"userarchive") EQ 0>
      <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblUserArchive 
      </CFQUERY>
    <cfelseif CompareNocase(arguments.type,"user") EQ 0>
      <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblUser 
      </CFQUERY>
	<cfelseif CompareNocase(arguments.type,"user_join_file") EQ 0>
      <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblUser INNER JOIN tblFile ON tblUser.User_ID = tblFile.User_ID
      </CFQUERY>
    </cfif>
    <cfif local.qGetUser.RecordCount>
      <cfset local.data['pages'] = Ceiling(local.qGetUser.RecordCount/request.agGridTableBatch)>
      <cfloop from="1" to="#local.data['pages']#" index="local.page">
        <cfset local.startalpha = "">
        <cfset local.endalpha = "">
        <cfif Val(local.page) AND Val(request.agGridTableBatch)>
          <cfif local.page GT 1>
            <cfset local.startrow = Int((local.page - 1) * request.agGridTableBatch) + 1>
            <cfset local.endrow = (local.startrow + request.agGridTableBatch) - 1>
          <cfelse>
            <cfset local.endrow = (local.startrow + request.agGridTableBatch) - 1>
          </cfif>
        </cfif>
        <cfif CompareNocase(arguments.type,"userarchive") EQ 0>
          <CFQUERY NAME="local.qGetUserSurnames" DATASOURCE="#request.domain_dsn#">
            SELECT * 
            FROM tblUserArchive 
            ORDER BY Surname ASC
          </CFQUERY>
        <cfelseif CompareNocase(arguments.type,"user") EQ 0>
          <CFQUERY NAME="local.qGetUserSurnames" DATASOURCE="#request.domain_dsn#">
            SELECT * 
            FROM tblUser 
            ORDER BY Surname ASC
          </CFQUERY>
       <cfelseif CompareNocase(arguments.type,"user_join_file") EQ 0>
          <CFQUERY NAME="local.qGetUserSurnames" DATASOURCE="#request.domain_dsn#">
            SELECT * 
            FROM tblUser INNER JOIN tblFile ON tblUser.User_ID = tblFile.User_ID
            ORDER BY Surname ASC
          </CFQUERY>   
        </cfif>
        <cfif local.qGetUserSurnames.RecordCount>
          <cfloop query="local.qGetUserSurnames" startrow="#local.startrow#" endrow="#local.endrow#">
            <cfif local.qGetUserSurnames.CurrentRow EQ Val(Trim(local.startrow))>
              <cfset local.startalpha = Mid(Trim(local.qGetUserSurnames.Surname),1,1)>
              <cfset ArrayAppend(local.data['alphahits'],"startalpha: " & local.startrow)>
            </cfif>
            <cfif local.qGetUserSurnames.RecordCount LT Val(Trim(local.endrow))>
              <cfset local.endrow = local.qGetUserSurnames.RecordCount>
              <cfset ArrayAppend(local.data['alphahits'],"endalpha: " & local.endrow)>
            </cfif>
            <cfif local.qGetUserSurnames.CurrentRow EQ Val(Trim(local.endrow))>
              <cfset local.endalpha = Mid(Trim(local.qGetUserSurnames.Surname),1,1)>
              <cfset ArrayAppend(local.data['alphahits'],"endalpha: " & local.endrow)>
            </cfif>
            <cfset ArrayAppend(local.data['currentrow'],local.page & " : " & local.qGetUserSurnames.CurrentRow)>
          </cfloop>
        </cfif>
        <cfset local.pagesurname = UCase(local.startalpha) & " - " & UCase(local.endalpha)>
        <cfset local.pagesurname = Trim(local.pagesurname)>
        <cfif Len(Trim(local.pagesurname)) AND CompareNoCase(local.pagesurname,"-") NEQ 0>
          <cfset ArrayAppend(local.data['pagessurnames'],local.pagesurname)>
        </cfif>
        <cfset ArrayAppend(local.data['pagesnumeric'],local.startrow & " - " & local.endrow)>
      </cfloop>
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>