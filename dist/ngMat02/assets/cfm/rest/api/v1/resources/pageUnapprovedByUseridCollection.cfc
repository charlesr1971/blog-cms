
<cfcomponent extends="taffy.core.resource" taffy_uri="/pages/unapproved/userid/{usertoken}">

  <cffunction name="get">
    <cfargument name="usertoken" type="string" required="yes" />
	<cfset var local = StructNew()>
    <cfset local.startrow = 1>
    <cfset local.endrow = request.filebatch>
    <cfset local.data = StructNew()>
    <cfset local.data['usertoken'] = arguments.userToken EQ 'empty' ? '' : arguments.userToken>
	<cfset local.data['pages'] = 0>
	<cfset local.data['pagestitles'] = ArrayNew(1)>
    <cfset local.data['pagesnumeric'] = ArrayNew(1)>
    <cfset local.data['currentrow'] = ArrayNew(1)>
    <cfset local.data['alphahits'] = ArrayNew(1)>
    <cfif Len(Trim(local.data['usertoken']))>
      <CFQUERY NAME="local.qGetUserID" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblUserToken 
        WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#local.data['usertoken']#">
      </CFQUERY>
      <cfif local.qGetUserID.RecordCount>
        <CFQUERY NAME="local.qGetFile" DATASOURCE="#request.domain_dsn#">
          SELECT * 
          FROM tblFile 
          WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUserID.User_ID#"> AND Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> 
          ORDER BY Submission_date DESC
        </CFQUERY>
        <cfif local.qGetFile.RecordCount>
		  <cfset local.data['pages'] = Ceiling(local.qGetFile.RecordCount/request.filebatch)>
          <cfloop from="1" to="#local.data['pages']#" index="local.page">
            <cfset local.startalpha = "">
            <cfset local.endalpha = "">
            <cfif Val(local.page) AND Val(request.filebatch)>
              <cfif local.page GT 1>
                <cfset local.startrow = Int((local.page - 1) * request.filebatch) + 1>
                <cfset local.endrow = (local.startrow + request.filebatch) - 1>
              <cfelse>
                <cfset local.endrow = (local.startrow + request.filebatch) - 1>
              </cfif>
            </cfif>
            <CFQUERY NAME="local.qGetFileTitles" DATASOURCE="#request.domain_dsn#">
              SELECT * 
              FROM tblFile 
              WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetUserID.User_ID#"> AND Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="0"> 
              ORDER BY Title ASC
            </CFQUERY>
            <cfif local.qGetFileTitles.RecordCount>
              <cfloop query="local.qGetFileTitles" startrow="#local.startrow#" endrow="#local.endrow#">
                <cfif local.qGetFileTitles.CurrentRow EQ Val(Trim(local.startrow))>
                  <cfset local.startalpha = Mid(Trim(local.qGetFileTitles.Title),1,1)>
                  <cfset ArrayAppend(local.data['alphahits'],"startalpha: " & local.startrow)>
                </cfif>
                <cfif local.qGetFileTitles.RecordCount LT Val(Trim(local.endrow))>
                  <cfset local.endrow = local.qGetFileTitles.RecordCount>
                  <cfset ArrayAppend(local.data['alphahits'],"endalpha: " & local.endrow)>
                </cfif>
                <cfif local.qGetFileTitles.CurrentRow EQ Val(Trim(local.endrow))>
                  <cfset local.endalpha = Mid(Trim(local.qGetFileTitles.Title),1,1)>
                  <cfset ArrayAppend(local.data['alphahits'],"endalpha: " & local.endrow)>
                </cfif>
                <cfset ArrayAppend(local.data['currentrow'],local.page & " : " & local.qGetFileTitles.CurrentRow)>
              </cfloop>
            </cfif>
            <cfset local.pagetitle = UCase(local.startalpha) & " - " & UCase(local.endalpha)>
            <cfset local.pagetitle = Trim(local.pagetitle)>
            <cfif Len(Trim(local.pagetitle)) AND CompareNoCase(local.pagetitle,"-") NEQ 0>
              <cfset ArrayAppend(local.data['pagestitles'],local.pagetitle)>
            </cfif>
            <cfset ArrayAppend(local.data['pagesnumeric'],local.startrow & " - " & local.endrow)>
          </cfloop>
        </cfif>
        
        
        
      </cfif>
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>