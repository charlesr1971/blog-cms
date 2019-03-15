
<cfcomponent extends="taffy.core.resource" taffy_uri="/comments/{fileUuid}/{page}">

  <cffunction name="get">
    <cfargument name="fileUuid" type="string" required="yes" />
    <cfargument name="page" type="numeric" required="yes" />
	<cfset var local = StructNew()>
    <cfset local.startrow = 1>
    <cfset local.endrow = request.commentbatch>
    <cfif Val(arguments.page) AND Val(request.commentbatch)>
	  <cfif arguments.page GT 1>
        <cfset local.startrow = Int((arguments.page - 1) * request.commentbatch) + 1>
        <cfset local.endrow = (local.startrow + request.commentbatch) - 1>
      <cfelse>
        <cfset local.endrow = (local.startrow + request.commentbatch) - 1>
      </cfif>
    </cfif>
    <cfset local.data['comments'] = ArrayNew(1)>
	<cfset local.data['total'] = 0>
    <cfset local.data['viewcomment'] = 0>
    <CFQUERY NAME="local.qGetComment" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblComment
      WHERE File_uuid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fileUuid#">
      ORDER BY Reply_to_comment_ID DESC, Comment_ID ASC
    </CFQUERY>
    <cfif local.qGetComment.RecordCount>
      <cfset local.data['total'] = local.qGetComment.RecordCount>
      <cfloop query="local.qGetComment" startrow="#local.startrow#" endrow="#local.endrow#">
        <CFQUERY NAME="local.qGetUser" DATASOURCE="#request.domain_dsn#">
          SELECT * 
          FROM tblUser 
          WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetComment.User_ID#">
        </CFQUERY>
        <cfset local.forename = "">
        <cfset local.surname = "">
        <cfset local.avatarSrc = "">
        <cfif local.qGetUser.RecordCount>
          <cfset local.forename = local.qGetUser.Forename>
          <cfset local.surname = local.qGetUser.Surname>
          <cfif Len(Trim(local.qGetUser.Filename))>
            <cfset local.avatarSrc = request.avatarbasesrc & local.qGetUser.Filename>
          </cfif>
        </cfif>
        <cfset local.obj = StructNew()>
        <cfset local.obj['commentid'] = local.qGetComment.Comment_ID>
        <cfset local.obj['fileid'] = local.qGetComment.File_ID>
        <cfset local.obj['fileUuid'] = local.qGetComment.File_uuid>
        <cfset local.obj['userid'] = local.qGetComment.User_ID>
        <cfset local.obj['comment'] = request.utils.FormatCommentOut(local.qGetComment.Comment)>
        <cfset local.obj['forename'] = local.forename>
        <cfset local.obj['surname'] = local.surname>
        <cfset local.obj['avatarSrc'] = local.avatarSrc>
        <cfset local.obj['token'] = local.qGetComment.Token>
        <cfset local.obj['replyToCommentid'] = local.qGetComment.Reply_to_comment_ID>
        <cfset local.obj['createdAt'] = local.qGetComment.Submission_date>
        <cfset ArrayAppend(local.data['comments'],local.obj)>
      </cfloop>
    </cfif>
    <cfreturn representationOf(local.data) />
  </cffunction>

</cfcomponent>