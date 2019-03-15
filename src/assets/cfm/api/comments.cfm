
<cfheader name="Access-Control-Allow-Origin" value="#request.ngAccessControlAllowOrigin#" />
<cfheader name="Access-Control-Allow-Headers" value="Authorization,userToken" />

<cfparam name="page" default="1" />
<cfparam name="fileuuid" default="" />
<cfparam name="commentid" default="0" />
<cfparam name="startrow" default="1" />
<cfparam name="endrow" default="#request.commentbatch#" />

<cfparam name="timestamp" default="#DateFormat(Now(),'yyyymmdd')##TimeFormat(Now(),'HHmmss')#" />
<cfparam name="data" default="#StructNew()#" />

<cfinclude template="../functions.cfm">

<cfif Val(page) AND Val(request.commentbatch)>
  <cfif page GT 1>
    <cfset startrow = Int((page - 1) * request.commentbatch) + 1>
    <cfset endrow = (startrow + request.commentbatch) - 1>
  <cfelse>
	<cfset endrow = (startrow + request.commentbatch) - 1>
  </cfif>
</cfif>

<cfset data['comments'] = ArrayNew(1)>
<cfset data['total'] = 0>
<cfset data['viewcomment'] = 0>
<cfif Val(commentid)>
  <cfset data['viewcomment'] = 1>
</cfif>

<CFQUERY NAME="qGetComment" DATASOURCE="#request.domain_dsn#">
  SELECT * 
  FROM tblComment
  WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#fileuuid#"><cfif Val(commentid)> AND Comment_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#commentid#"></cfif>
  <!---ORDER BY Submission_date DESC--->
  ORDER BY Reply_to_comment_ID DESC, Comment_ID ASC
</CFQUERY>

<cfif qGetComment.RecordCount>
  <cfset data['total'] = qGetComment.RecordCount>
  <cfloop query="qGetComment" startrow="#startrow#" endrow="#endrow#">
    <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUser 
      WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetComment.User_ID#">
    </CFQUERY>
    <cfset forename = "">
    <cfset surname = "">
    <cfset avatarSrc = "">
    <cfif qGetUser.RecordCount>
      <cfset forename = qGetUser.Forename>
      <cfset surname = qGetUser.Surname>
      <cfif Len(Trim(qGetUser.Filename))>
        <cfset avatarSrc = request.avatarbasesrc & qGetUser.Filename>
      </cfif>
    </cfif>
    <cfset obj = StructNew()>
    <cfset obj['commentid'] = qGetComment.Comment_ID>
    <cfset obj['fileid'] = qGetComment.File_ID>
    <cfset obj['fileUuid'] = qGetComment.File_uuid>
    <cfset obj['userid'] = qGetComment.User_ID>
    <cfset obj['comment'] = FormatCommentOut(qGetComment.Comment)>
    <cfset obj['forename'] = forename>
    <cfset obj['surname'] = surname>
    <cfset obj['avatarSrc'] = avatarSrc>
    <cfset obj['token'] = qGetComment.Token>
    <cfset obj['replyToCommentid'] = qGetComment.Reply_to_comment_ID>
    <cfset obj['createdAt'] = qGetComment.Submission_date>
    <cfset ArrayAppend(data['comments'],obj)>
  </cfloop>
</cfif>

<cfoutput>
#SerializeJSON(data)#
</cfoutput>