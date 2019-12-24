
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="Authorization,userToken" />

<cfparam name="fileUuid" default="" />
<cfparam name="quantity" default="0" />

<cfparam name="directions" default="previous,next" />
<cfparam name="userToken" default="" />
<cfparam name="data" default="" />

<cfinclude template="../functions.cfm">

<cfset data = ArrayNew(1)>

<cfset requestBody = getHttpRequestData().headers>
<cftry>
  <cfif StructKeyExists(requestBody,"userToken")>
	<cfset userToken = Trim(requestBody['userToken'])>
  </cfif>
  <cfcatch>
  </cfcatch>
</cftry>

<CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblFile 
  WHERE Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"> AND Article IS NOT NULL
  ORDER BY Submission_date DESC
</CFQUERY>
<cfif qGetFile.RecordCount AND Val(quantity)>
  <cfset targetObj = StructNew()>
  <CFQUERY NAME="qGetTargetFile" DATASOURCE="#request.domain_dsn#">
    SELECT * 
    FROM tblFile 
    WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#fileUuid#">
  </CFQUERY>
  <cfif qGetTargetFile.RecordCount>
    <cfset targetObj['category'] = qGetTargetFile.Category>
    <cfset targetObj['userid'] = qGetTargetFile.User_ID>
    <cfset targetObj['fileid'] = qGetTargetFile.File_ID>
    <cfset targetObj['src'] = qGetTargetFile.ImagePath>
    <cfset targetObj['fileUuid'] = qGetTargetFile.File_uuid>
    <cfset targetObj['author'] = qGetTargetFile.Author>
    <cfset targetObj['title'] = qGetTargetFile.Title>
    <cfset targetObj['description'] = qGetTargetFile.Description>
    <cfset targetObj['article'] = qGetTargetFile.Article>
    <cfset targetObj['size'] = qGetTargetFile.Size>
    <cfset targetObj['likes'] = qGetTargetFile.Likes>
    <cfset targetObj['tags'] = qGetTargetFile.Tags>
    <cfset targetObj['publishArticleDate'] = qGetTargetFile.Publish_article_date>
    <cfset targetObj['approved'] = qGetTargetFile.Approved>
    <cfset targetObj['imageAccreditation'] = qGetTargetFile.ImageAccreditation>
    <cfset targetObj['imageOrientation'] = qGetTargetFile.ImageOrientation>
    <cfset targetObj['createdAt'] = qGetTargetFile.Submission_date>
    <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUser 
      WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetTargetFile.User_ID#">
    </CFQUERY>
    <cfif qGetUser.RecordCount>
      <cfif Len(Trim(qGetUser.Filename))>
        <cfset targetObj['avatarSrc'] = request.avatarbasesrc & qGetUser.Filename>
      <cfelse>
        <cfset targetObj['avatarSrc'] = "">
      </cfif>
    <cfelse>
      <cfset targetObj['avatarSrc'] = "">
    </cfif>
  </cfif>
  <cfloop query="qGetFile">
    <cfif CompareNoCase(qGetFile.File_uuid,fileUuid) EQ 0>
      <cfset targetFileIsAdded = false>
      <cfset directionList = "">
      <cfloop from="1" to="#quantity#" index="index">
        <cfloop list="#directions#" index="direction">
          <cfif CompareNoCase(direction,"next") EQ 0>
            <cfset row = qGetFile.CurrentRow + index>
          <cfelse>
            <cfset row = qGetFile.CurrentRow - index>
          </cfif>
          <cfif row EQ (qGetFile.RecordCount + index) AND CompareNoCase(direction,"next") EQ 0>
            <cfset row = 0>
          </cfif>
          <cfif row LTE 0 AND CompareNoCase(direction,"previous") EQ 0>
            <cfset row = 0>
          </cfif>
          <cfif row GT 0 AND row LTE qGetFile.RecordCount> 
            <cfif Len(Trim(qGetFile['Article'][row])) AND (NOT IsDate(qGetFile['Publish_article_date'][row]) OR (IsDate(qGetFile['Publish_article_date'][row]) AND DateCompare(Now(),qGetFile['Publish_article_date'][row]) EQ 1))>
            <!---<cfif true>--->
              <cfset directionList = ListAppend(directionList,direction)>
              <cfif CompareNoCase(direction,"next") EQ 0 AND NOT targetFileIsAdded AND NOT StructIsEmpty(targetObj)>
                <cfset targetFileIsAdded = true>
                <cfset ArrayAppend(data,targetObj)>
              </cfif>
              <cfset obj = StructNew()>
              <cfset obj['category'] = qGetFile['Category'][row]>
              <cfset obj['userid'] = qGetFile['User_ID'][row]>
              <cfset obj['fileid'] = qGetFile['File_ID'][row]>
              <cfset obj['src'] = qGetFile['ImagePath'][row]>
              <cfset obj['fileUuid'] = qGetFile['File_uuid'][row]>
              <cfset obj['author'] = qGetFile['Author'][row]>
              <cfset obj['title'] = qGetFile['Title'][row]>
              <cfset obj['description'] = qGetFile['Description'][row]>
              <cfset obj['article'] = qGetFile['Article'][row]>
              <cfset obj['size'] = qGetFile['Size'][row]>
              <cfset obj['likes'] = qGetFile['Likes'][row]>
              <cfset obj['tags'] = qGetFile['Tags'][row]>
              <cfset obj['publishArticleDate'] = qGetFile['Publish_article_date'][row]>
              <cfset obj['approved'] = qGetFile['Approved'][row]>
              <cfset obj['imageAccreditation'] = qGetFile['ImageAccreditation'][local.row]>
              <cfset obj['imageOrientation'] = qGetFile['ImageOrientation'][local.row]>
              <cfset obj['createdAt'] = qGetFile['Submission_date'][row]>
              <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
                SELECT * 
                FROM tblUser 
                WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetFile['User_ID'][row]#">
              </CFQUERY>
              <cfif qGetUser.RecordCount>
                <cfif Len(Trim(qGetUser.Filename))>
                  <cfset obj['avatarSrc'] = request.avatarbasesrc & qGetUser.Filename>
                <cfelse>
                  <cfset obj['avatarSrc'] = "">
                </cfif>
              <cfelse>
                <cfset obj['avatarSrc'] = "">
              </cfif>
              <cfset ArrayAppend(data,obj)>
            </cfif>
          </cfif>
        </cfloop>
      </cfloop>
      <cfif ListFindNoCase(directionList,"previous") AND NOT ListFindNoCase(directionList,"next") AND NOT StructIsEmpty(targetObj)>
        <cfset ArrayAppend(data,targetObj)>
      </cfif>
    </cfif>
  </cfloop>
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>