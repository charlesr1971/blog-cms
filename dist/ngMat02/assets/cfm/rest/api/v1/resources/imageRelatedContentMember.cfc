
<cfcomponent extends="taffy.core.resource" taffy_uri="/image/related/{fileUuid}/{quantity}" taffy_docs_hide>

  <cffunction name="get">
    <cfargument name="fileUuid" type="string" required="yes" />
    <cfargument name="quantity" type="numeric" required="yes" />
	<cfset var local = StructNew()>
    <cfset local.directions = "previous,next">
    <cfset local['userToken'] = "">
    <cfset local.data = ArrayNew(1)>
    <cfset local.requestBody = getHttpRequestData().headers>
    <cftry>
	  <cfif StructKeyExists(local.requestBody,"userToken")>
      	<cfset local['userToken'] = Trim(local.requestBody['userToken'])>
      </cfif>
      <cfcatch>
      </cfcatch>
    </cftry>
    <CFQUERY NAME="local.qGetFile" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblFile 
      WHERE Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"> AND Article IS NOT NULL
      ORDER BY Submission_date DESC
    </CFQUERY>
    <cfif local.qGetFile.RecordCount AND Val(arguments.quantity)>
      <cfset local.targetObj = StructNew()>
      <CFQUERY NAME="local.qGetTargetFile" DATASOURCE="#request.domain_dsn#">
        SELECT * 
        FROM tblFile 
        WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fileUuid#">
      </CFQUERY>
      <cfif local.qGetTargetFile.RecordCount>
        <cfset local.targetObj['category'] = local.qGetTargetFile.Category>
        <cfset local.targetObj['userid'] = local.qGetTargetFile.User_ID>
        <cfset local.targetObj['fileid'] = local.qGetTargetFile.File_ID>
        <cfset local.targetObj['src'] = local.qGetTargetFile.ImagePath>
        <cfset local.targetObj['fileUuid'] = local.qGetTargetFile.File_uuid>
        <cfset local.targetObj['author'] = local.qGetTargetFile.Author>
        <cfset local.targetObj['title'] = local.qGetTargetFile.Title>
        <cfset local.targetObj['description'] = local.qGetTargetFile.Description>
        <cfset local.targetObj['article'] = local.qGetTargetFile.Article>
        <cfset local.targetObj['size'] = local.qGetTargetFile.Size>
        <cfset local.targetObj['likes'] = local.qGetTargetFile.Likes>
        <cfset local.targetObj['tags'] = local.qGetTargetFile.Tags>
        <cfset local.targetObj['publishArticleDate'] = local.qGetTargetFile.Publish_article_date>
        <cfset local.targetObj['approved'] = local.qGetTargetFile.Approved>
        <cfset local.targetObj['imageAccreditation'] = local.qGetTargetFile.ImageAccreditation>
        <cfset local.targetObj['imageOrientation'] = local.qGetTargetFile.ImageOrientation>
        <cfset local.targetObj['createdAt'] = local.qGetTargetFile.Submission_date>
        <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
          SELECT * 
          FROM tblUser 
          WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetTargetFile.User_ID#">
        </CFQUERY>
        <cfif local.qGetUser.RecordCount>
          <cfif Len(Trim(local.qGetUser.Filename))>
            <cfset local.targetObj['avatarSrc'] = request.avatarbasesrc & local.qGetUser.Filename>
          <cfelse>
            <cfset local.targetObj['avatarSrc'] = "">
          </cfif>
        <cfelse>
          <cfset local.targetObj['avatarSrc'] = "">
        </cfif>
      </cfif>
      <cfloop query="local.qGetFile">
		<cfif CompareNoCase(local.qGetFile.File_uuid,arguments.fileUuid) EQ 0>
          <cfset local.targetFileIsAdded = false>
          <cfset local.directionList = "">
          <cfloop from="1" to="#arguments.quantity#" index="local.index">
            <cfloop list="#local.directions#" index="local.direction">
              <cfif CompareNoCase(local.direction,"next") EQ 0>
                <cfset local.row = local.qGetFile.CurrentRow + local.index>
              <cfelse>
                <cfset local.row = local.qGetFile.CurrentRow - local.index>
              </cfif>
              <cfif local.row EQ (local.qGetFile.RecordCount + local.index) AND CompareNoCase(local.direction,"next") EQ 0>
                <cfset local.row = 0>
              </cfif>
              <cfif local.row LTE 0 AND CompareNoCase(local.direction,"previous") EQ 0>
                <cfset local.row = 0>
              </cfif>
              <cfif local.row GT 0 AND local.row LTE local.qGetFile.RecordCount> 
                <cfif Len(Trim(local.qGetFile['Article'][local.row])) AND (NOT IsDate(local.qGetFile['Publish_article_date'][local.row]) OR (IsDate(local.qGetFile['Publish_article_date'][local.row]) AND DateCompare(Now(),local.qGetFile['Publish_article_date'][local.row]) EQ 1))>
                <!---<cfif true>--->
				  <cfset local.directionList = ListAppend(local.directionList,local.direction)>
                  <cfif CompareNoCase(local.direction,"next") EQ 0 AND NOT local.targetFileIsAdded AND NOT StructIsEmpty(local.targetObj)>
                    <cfset local.targetFileIsAdded = true>
                    <cfset ArrayAppend(local.data,local.targetObj)>
                  </cfif>
                  <cfset local.obj = StructNew()>
                  <cfset local.obj['category'] = local.qGetFile['Category'][local.row]>
                  <cfset local.obj['userid'] = local.qGetFile['User_ID'][local.row]>
                  <cfset local.obj['fileid'] = local.qGetFile['File_ID'][local.row]>
                  <cfset local.obj['src'] = local.qGetFile['ImagePath'][local.row]>
                  <cfset local.obj['fileUuid'] = local.qGetFile['File_uuid'][local.row]>
                  <cfset local.obj['author'] = local.qGetFile['Author'][local.row]>
                  <cfset local.obj['title'] = local.qGetFile['Title'][local.row]>
                  <cfset local.obj['description'] = local.qGetFile['Description'][local.row]>
                  <cfset local.obj['article'] = local.qGetFile['Article'][local.row]>
                  <cfset local.obj['size'] = local.qGetFile['Size'][local.row]>
                  <cfset local.obj['likes'] = local.qGetFile['Likes'][local.row]>
                  <cfset local.obj['tags'] = local.qGetFile['Tags'][local.row]>
                  <cfset local.obj['publishArticleDate'] = local.qGetFile['Publish_article_date'][local.row]>
                  <cfset local.obj['approved'] = local.qGetFile['Approved'][local.row]>
                  <cfset local.obj['imageAccreditation'] = local.qGetFile['ImageAccreditation'][local.row]>
                  <cfset local.obj['imageOrientation'] = local.qGetFile['ImageOrientation'][local.row]>
                  <cfset local.obj['createdAt'] = local.qGetFile['Submission_date'][local.row]>
                  <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
                    SELECT * 
                    FROM tblUser 
                    WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetFile['User_ID'][local.row]#">
                  </CFQUERY>
                  <cfif local.qGetUser.RecordCount>
                    <cfif Len(Trim(local.qGetUser.Filename))>
                      <cfset local.obj['avatarSrc'] = request.avatarbasesrc & local.qGetUser.Filename>
                    <cfelse>
                      <cfset local.obj['avatarSrc'] = "">
                    </cfif>
                  <cfelse>
                    <cfset local.obj['avatarSrc'] = "">
                  </cfif>
                  <cfset ArrayAppend(local.data,local.obj)>
                </cfif>
              </cfif>
            </cfloop>
          </cfloop>
          <cfif ListFindNoCase(local.directionList,"previous") AND NOT ListFindNoCase(local.directionList,"next") AND NOT StructIsEmpty(local.targetObj)>
			<cfset ArrayAppend(local.data,local.targetObj)>
          </cfif>
        </cfif>
      </cfloop>
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>