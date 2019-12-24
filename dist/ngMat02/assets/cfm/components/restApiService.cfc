	

<!--- 

AUTHOR: Charles Robertson
COMPANY: CDESIGN
DATE: 02.2019
DESCRIPTION: REST API service functions 

--->


<cfcomponent displayname="restApiService" hint="component description: performs restApiService functions">
  
  
  <!--- FUNCTION: constructor --->
  
  <cffunction name="init" access="public" output="false" hint="function description: constructor for the restApiService component">
    <!--- arguments --->
    <!--- logic --->
    <cfreturn this />
  </cffunction>
  
  
  <!--- FUNCTION UDF: commentMember  --->
  
  <cffunction name="CommentMember" returntype="struct" output="false" hint="returns CommentMember">
    <!--- arguments --->
    <cfargument name="commentId" type="numeric" required="no" default="0" hint="argument description: commentId" />
    <cfargument name="fileUuid" type="string" required="no" default="" hint="argument description: fileUuid" />
    <cfargument name="userid" type="numeric" required="no" default="0" hint="argument description: userid" />
    <cfargument name="comment" type="string" required="no" default="" hint="argument description: comment" />
    <cfargument name="replyToCommentid" type="numeric" required="no" default="0" hint="argument description: replyToCommentid" />
    <cfargument name="authorization" type="string" required="no" default="" hint="argument description: authorization" />
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <cfargument name="verb" type="string" required="no" default="get" hint="argument description: verb" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfset local.verb = arguments.verb>
    <cfif ListFind("put,delete",arguments.verb)>
	  <cfset local.verb = "post">
    </cfif>
    <cfhttp url="#request.restApiEndpoint#/comment/#arguments.commentId#" method="#local.verb#" result="local.result" timeout="30">
      <cfif ListFind("post,delete",arguments.verb)>
        <cfhttpparam type="header" name="Authorization" value="Bearer #Trim(arguments.authorization)#" />
        <cfhttpparam type="header" name="userToken" value="#arguments.userToken#" />
      </cfif>
      <cfif CompareNoCase(arguments.verb,"post") EQ 0>
        <cfhttpparam type="header" name="fileUuid" value="#arguments.fileUuid#" />
        <cfhttpparam type="header" name="userid" value="#arguments.userid#" />
        <cfhttpparam type="header" name="comment" value="#arguments.comment#" />
        <cfhttpparam type="header" name="replyToCommentid" value="#arguments.replyToCommentid#" />
      </cfif>
      <cfif CompareNoCase(arguments.verb,"delete") EQ 0>
        <cfhttpparam type="header" name="X-HTTP-METHOD-OVERRIDE" value="DELETE" />
      </cfif>
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: commentCollection  --->
  
  <cffunction name="CommentCollection" returntype="struct" output="false" hint="returns CommentCollection">
    <!--- arguments --->
    <cfargument name="fileUuid" type="string" required="no" default="" hint="argument description: fileUuid" />
    <cfargument name="page" type="numeric" required="no" default="1" hint="argument description: page" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfhttp url="#request.restApiEndpoint#/comments/#arguments.fileUuid#/#arguments.page#" method="get" result="local.result" timeout="30">
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: imageMember  --->
  
  <cffunction name="ImageMember" returntype="struct" output="false" hint="returns ImageMember">
    <!--- arguments --->
    <cfargument name="fileUuid" type="string" required="no" default="" hint="argument description: fileUuid" />
    <cfargument name="fileid" type="numeric" required="no" default="0" hint="argument description: fileid" />
    <cfargument name="commentId" type="numeric" required="no" default="0" hint="argument description: commentId" />
    <cfargument name="fileName" type="string" required="no" default="" hint="argument description: fileName" />
    <cfargument name="imagePath" type="string" required="no" default="" hint="argument description: imagePath" />
    <cfargument name="name" type="string" required="no" default="" hint="argument description: name" />
    <cfargument name="title" type="string" required="no" default="" hint="argument description: title" />
    <cfargument name="description" type="string" required="no" default="" hint="argument description: description" />
    <cfargument name="article" type="string" required="no" default="" hint="argument description: article" />
    <cfargument name="tags" type="string" required="no" default="" hint="argument description: tags" />
    <cfargument name="publishArticleDate" type="string" required="no" default="" hint="argument description: publishArticleDate" />
    <cfargument name="fileExtension" type="string" required="no" default="" hint="argument description: fileExtension" />
    <cfargument name="contentLength" type="numeric" required="no" default="0" hint="argument description: contentLength" />
    <cfargument name="cfid" type="string" required="no" default="" hint="argument description: cfid" />
    <cfargument name="cftoken" type="string" required="no" default="" hint="argument description: cftoken" />
    <cfargument name="uploadType" type="string" required="no" default="gallery" hint="argument description: uploadType" />
    <cfargument name="contentType" type="string" required="no" default="gallery" hint="argument description: contentType" />
    <cfargument name="submitArticleNotification" type="numeric" required="no" default="0" hint="argument description: submitArticleNotification" />
    <cfargument name="binaryFileObj" type="any" required="no" default="" hint="argument description: binaryFileObj" />
    <cfargument name="authorization" type="string" required="no" default="" hint="argument description: authorization" />
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <cfargument name="verb" type="string" required="no" default="get" hint="argument description: verb" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfset local.verb = arguments.verb>
    <cfif ListFind("put,delete",arguments.verb)>
	  <cfset local.verb = "post">
    </cfif>
    <cfhttp url="#request.restApiEndpoint#/image/#arguments.fileUuid#" method="#local.verb#" result="local.result" timeout="30">
      <cfif ListFind("get",arguments.verb)>
        <cfhttpparam type="header" name="userToken" value="#arguments.userToken#" />
      </cfif>
      <cfif ListFind("post,delete,put",arguments.verb)>
        <cfhttpparam type="header" name="Authorization" value="Bearer #Trim(arguments.authorization)#" />
        <cfif CompareNoCase(arguments.verb,"post") EQ 0>
          <cfhttpparam type="header" name="user-token" value="#arguments.userToken#" />
        <cfelse>
          <cfhttpparam type="header" name="userToken" value="#arguments.userToken#" />
        </cfif>
      </cfif>
      <cfif CompareNoCase(arguments.verb,"post") EQ 0 AND IsBinary(arguments.binaryFileObj)>
        <cfhttpparam type="header" name="file-name" value="#arguments.fileName#" />
        <cfhttpparam type="header" name="image-path" value="#arguments.imagePath#" />
        <cfhttpparam type="header" name="name" value="#arguments.name#" />
        <cfhttpparam type="header" name="title" value="#arguments.title#" />
        <cfhttpparam type="header" name="description" value="#arguments.description#" />
        <cfhttpparam type="header" name="article" value="#arguments.article#" />
        <cfhttpparam type="header" name="tags" value="#arguments.tags#" />
        <cfhttpparam type="header" name="publish-article-date" value="#arguments.publishArticleDate#" />
        <cfhttpparam type="header" name="tinymce-article-deleted-images" value="" />
        <cfhttpparam type="header" name="file-extension" value="#arguments.fileExtension#" />
        <cfhttpparam type="header" name="content-length" value="#arguments.contentLength#" />
        <cfhttpparam type="header" name="cfid" value="" />
        <cfhttpparam type="header" name="cftoken" value="" />
        <cfhttpparam type="header" name="upload-type" value="#arguments.uploadType#" />
        <cfhttpparam type="header" name="Content-Type" value="#arguments.contentType#" />
        <cfhttpparam type="body" value="#arguments.binaryFileObj#" />
      </cfif>
      <cfif CompareNoCase(arguments.verb,"put") EQ 0>
        <cfhttpparam type="header" name="imagePath" value="#arguments.imagePath#" />
        <cfhttpparam type="header" name="name" value="#arguments.name#" />
        <cfhttpparam type="header" name="title" value="#arguments.title#" />
        <cfhttpparam type="header" name="description" value="#arguments.description#" />
        <cfhttpparam type="header" name="tags" value="#arguments.tags#" />
        <cfhttpparam type="header" name="publishArticleDate" value="#arguments.publishArticleDate#" />
        <cfhttpparam type="header" name="tinymceArticleDeletedImages" value="" />
        <cfhttpparam type="header" name="submitArticleNotification" value="#arguments.submitArticleNotification#" />
        <cfhttpparam type="header" name="Content-Type" value="application/json" />
        <cfhttpparam type="header" name="X-HTTP-METHOD-OVERRIDE" value="PUT" />
        <cfhttpparam type="body" name="article" value='#ToBinary(ToBase64(SerializeJson({"article":"#arguments.article#"})))#' />
      </cfif>
      <cfif CompareNoCase(arguments.verb,"delete") EQ 0>
        <cfhttpparam type="header" name="X-HTTP-METHOD-OVERRIDE" value="DELETE" />
      </cfif>
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: imageCollection  --->
  
  <cffunction name="ImageCollection" returntype="struct" output="false" hint="returns ImageCollection">
    <!--- arguments --->
    <cfargument name="page" type="numeric" required="no" default="1" hint="argument description: page" />
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfhttp url="#request.restApiEndpoint#/images/#arguments.page#" method="get" result="local.result" timeout="30">
      <cfhttpparam type="header" name="userToken" value="#arguments.userToken#" />
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  <!--- FUNCTION UDF: imageUnapprovedCollection  --->
  
  <cffunction name="ImageUnapprovedCollection" returntype="struct" output="false" hint="returns ImageUnapprovedCollection">
    <!--- arguments --->
    <cfargument name="page" type="numeric" required="no" default="1" hint="argument description: page" />
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfhttp url="#request.restApiEndpoint#/images/unapproved/#arguments.page#" method="get" result="local.result" timeout="30">
      <cfhttpparam type="header" name="userToken" value="#arguments.userToken#" />
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: imageApprovedCollection  --->
  
  <cffunction name="ImageApprovedCollection" returntype="struct" output="false" hint="returns ImageApprovedCollection">
    <!--- arguments --->
    <cfargument name="page" type="numeric" required="no" default="1" hint="argument description: page" />
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfhttp url="#request.restApiEndpoint#/images/approved/#arguments.page#" method="get" result="local.result" timeout="30">
      <cfhttpparam type="header" name="userToken" value="#arguments.userToken#" />
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: jwtMember  --->
  
  <cffunction name="JwtMember" returntype="struct" output="false" hint="returns JwtMember">
    <!--- arguments --->
    <cfargument name="authorization" type="string" required="no" default="" hint="argument description: authorization" />
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfhttp url="#request.restApiEndpoint#/jwt/#arguments.userToken#" method="get" result="local.result" timeout="30">
      <cfhttpparam type="header" name="Authorization" value="Bearer #Trim(arguments.authorization)#" />
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: likeMember  --->
  
  <cffunction name="LikeMember" returntype="struct" output="false" hint="returns LikeMember">
    <!--- arguments --->
    <cfargument name="fileUuid" type="string" required="no" default="" hint="argument description: fileUuid" />
    <cfargument name="add" type="numeric" required="no" default="0" hint="argument description: add" />
    <cfargument name="allowMultipleLikesPerUser" type="numeric" required="no" default="0" hint="argument description: allowMultipleLikesPerUser" />
    <cfargument name="authorization" type="string" required="no" default="" hint="argument description: authorization" />
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfhttp url="#request.restApiEndpoint#/like/#arguments.fileUuid#/#arguments.add#/#arguments.allowMultipleLikesPerUser#" method="post" result="local.result" timeout="30">
      <cfhttpparam type="header" name="Authorization" value="Bearer #Trim(arguments.authorization)#" />
      <cfhttpparam type="header" name="userToken" value="#arguments.userToken#" />
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
   <!--- FUNCTION UDF: searchCollection  --->
  
  <cffunction name="SearchCollection" returntype="struct" output="false" hint="returns SearchCollection">
    <!--- arguments --->
    <cfargument name="term" type="string" required="no" default="" hint="argument description: term" />
    <cfargument name="page" type="numeric" required="no" default="1" hint="argument description: page" />
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfhttp url="#request.restApiEndpoint#/search/#arguments.page#" method="get" result="local.result" timeout="30">
      <cfhttpparam type="header" name="term" value="#Trim(arguments.term)#" />
      <cfhttpparam type="header" name="userToken" value="#arguments.userToken#" />
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: oauthMember  --->
  
  <cffunction name="OauthMember" returntype="struct" output="false" hint="returns OauthMember">
    <!--- arguments --->
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <cfargument name="keeploggedin" type="numeric" required="no" default="0" hint="argument description: keeploggedin" />
    <cfargument name="email" type="string" required="no" default="" hint="argument description: email" />
    <cfargument name="password" type="string" required="no" default="" hint="argument description: password" />
    <cfargument name="commentToken" type="string" required="no" default="" hint="argument description: commentToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfhttp url="#request.restApiEndpoint#/oauth/#arguments.userToken#/#arguments.keeploggedin#" method="post" result="local.result" timeout="30">
      <cfhttpparam type="header" name="email" value="#arguments.email#" />
      <cfhttpparam type="header" name="password" value="#arguments.password#" />
      <cfhttpparam type="header" name="commentToken" value="#arguments.commentToken#" />
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: tinymceArticleImageMember  --->
  
  <cffunction name="TinymceArticleImageMember" returntype="struct" output="false" hint="returns TinymceArticleImageMember">
    <!--- arguments --->
    <cfargument name="fileid" type="numeric" required="no" default="0" hint="argument description: fileid" />
    <cfargument name="filename" type="string" required="no" default="" hint="argument description: filename" />
    <cfargument name="contentType" type="string" required="no" default="" hint="argument description: contentType" />
    <cfargument name="binaryFileObj" type="any" required="no" default="" hint="argument description: binaryFileObj" />
    <cfargument name="authorization" type="string" required="no" default="" hint="argument description: authorization" />
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <cfargument name="verb" type="string" required="no" default="get" hint="argument description: verb" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfset local.verb = arguments.verb>
    <cfif ListFind("put,delete",arguments.verb)>
	  <cfset local.verb = "post">
    </cfif>
    <cfhttp url="#request.restApiEndpoint#/tinymcearticleimage/#arguments.fileid#" method="#local.verb#" result="local.result" timeout="30">
	  <cfif CompareNoCase(arguments.verb,"get") EQ 0>
        <cfhttpparam type="header" name="userToken" value="#arguments.userToken#" />
      </cfif>
      <cfif ListFind("post,delete",arguments.verb)>
        <cfhttpparam type="header" name="Authorization" value="Bearer #Trim(arguments.authorization)#" />
        <cfhttpparam type="header" name="userToken" value="#arguments.userToken#" />
      </cfif>
      <cfif CompareNoCase(arguments.verb,"post") EQ 0 AND IsBinary(arguments.binaryFileObj)>
        <cfhttpparam type="header" name="filename" value="#arguments.filename#" />
        <cfhttpparam type="header" name="content-type" value="#arguments.contentType#" />
        <cfhttpparam type="body" value="#arguments.binaryFileObj#" />
      </cfif>
      <cfif CompareNoCase(arguments.verb,"delete") EQ 0>
        <cfhttpparam type="header" name="filename" value="#arguments.filename#" />
        <cfhttpparam type="header" name="X-HTTP-METHOD-OVERRIDE" value="DELETE" />
      </cfif>
    </cfhttp>
  <cfreturn local.result />
  </cffunction>

  
  <!--- FUNCTION UDF: userMember  --->
  
  <cffunction name="UserMember" returntype="struct" output="false" hint="returns UserMember">
    <!--- arguments --->
    <cfargument name="forename" type="string" required="no" default="" hint="argument description: forename" />
    <cfargument name="surname" type="string" required="no" default="" hint="argument description: surname" />
    <cfargument name="email" type="string" required="no" default="" hint="argument description: email" />
    <cfargument name="password" type="string" required="no" default="" hint="argument description: password" />
    <cfargument name="cfid" type="string" required="no" default="" hint="argument description: cfid" />
    <cfargument name="cftoken" type="string" required="no" default="" hint="argument description: cftoken" />
    <cfargument name="testEmail" type="boolean" required="no" default="false" hint="argument description: testEmail" />
    <cfargument name="cookieAcceptance" type="numeric" required="no" default="0" hint="argument description: cookieAcceptance" />
    <cfargument name="emailNotification" type="numeric" required="no" default="0" hint="argument description: emailNotification" />
    <cfargument name="theme" type="string" required="no" default="theme-1-dark" hint="argument description: theme" />
    <cfargument name="userid" type="numeric" required="no" default="0" hint="argument description: userid" />
    <cfargument name="authorization" type="string" required="no" default="" hint="argument description: authorization" />
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <cfargument name="verb" type="string" required="no" default="get" hint="argument description: verb" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfset local.verb = arguments.verb>
    <cfif ListFind("put,delete",arguments.verb)>
	  <cfset local.verb = "post">
    </cfif>
    <cfhttp url="#request.restApiEndpoint#/user/#arguments.userToken#" method="#local.verb#" result="local.result" timeout="30">
      <cfif ListFind("put,delete",arguments.verb)>
        <cfhttpparam type="header" name="Authorization" value="Bearer #Trim(arguments.authorization)#" />
        <cfhttpparam type="header" name="userToken" value="#arguments.userToken#" />
      </cfif>
      <cfif CompareNoCase(arguments.verb,"post") EQ 0>
        <cfhttpparam type="header" name="forename" value="#arguments.forename#" />
        <cfhttpparam type="header" name="surname" value="#arguments.surname#" />
        <cfhttpparam type="header" name="email" value="#arguments.email#" />
        <cfhttpparam type="header" name="password" value="#arguments.password#" />
        <cfhttpparam type="header" name="cfid" value="#arguments.cfid#" />
        <cfhttpparam type="header" name="cftoken" value="#arguments.cftoken#" />
        <cfhttpparam type="header" name="testEmail" value="#arguments.testEmail#" />
        <cfhttpparam type="header" name="cookieAcceptance" value="#arguments.cookieAcceptance#" />
      </cfif>
      <cfif CompareNoCase(arguments.verb,"put") EQ 0>
        <cfhttpparam type="header" name="forename" value="#arguments.forename#" />
        <cfhttpparam type="header" name="surname" value="#arguments.surname#" />
        <cfhttpparam type="header" name="password" value="#arguments.password#" />
        <cfhttpparam type="header" name="emailNotification" value="#arguments.emailNotification#" />
        <cfhttpparam type="header" name="theme" value="#arguments.theme#" />
        <cfhttpparam type="header" name="userid" value="#arguments.userid#" />
        <cfhttpparam type="header" name="X-HTTP-METHOD-OVERRIDE" value="PUT" />
      </cfif>
      <cfif CompareNoCase(arguments.verb,"delete") EQ 0>
        <cfhttpparam type="header" name="userid" value="#arguments.userid#" />
        <cfhttpparam type="header" name="X-HTTP-METHOD-OVERRIDE" value="DELETE" />
      </cfif>
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: authorCollection  --->
  
  <cffunction name="AuthorCollection" returntype="struct" output="false" hint="returns AuthorCollection">
    <!--- arguments --->
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfhttp url="#request.restApiEndpoint#/authors" method="get" result="local.result" timeout="30">
      <cfhttpparam type="header" name="userToken" value="#arguments.userToken#" />
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: autocompleteTagsCollection  --->
  
  <cffunction name="AutocompleteTagsCollection" returntype="struct" output="false" hint="returns AutocompleteTagsCollection">
    <!--- arguments --->
    <cfargument name="term" type="string" required="no" default="" hint="argument description: term" />
    <cfargument name="useTerm" type="boolean" required="no" default="true" hint="argument description: useTerm" />
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfhttp url="#request.restApiEndpoint#/autocompleteTags/#arguments.term#/#arguments.useTerm#" method="get" result="local.result" timeout="30">
      <cfhttpparam type="header" name="userToken" value="#arguments.userToken#" />
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: categoryCollection  --->
  
  <cffunction name="CategoryCollection" returntype="struct" output="false" hint="returns CategoryCollection">
    <!--- arguments --->
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfhttp url="#request.restApiEndpoint#/categories" method="get" result="local.result" timeout="30">
      <cfhttpparam type="header" name="userToken" value="#arguments.userToken#" />
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: categoryMember  --->
  
  <cffunction name="CategoryMember" returntype="struct" output="false" hint="returns CategoryMember">
    <!--- arguments --->
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfhttp url="#request.restApiEndpoint#/category" method="get" result="local.result" timeout="30">
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: dateCollection  --->
  
  <cffunction name="DateCollection" returntype="struct" output="false" hint="returns DateCollection">
    <!--- arguments --->
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfhttp url="#request.restApiEndpoint#/dates" method="get" result="local.result" timeout="30">
      <cfhttpparam type="header" name="userToken" value="#arguments.userToken#" />
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: imageAdjacentMember  --->
  
  <cffunction name="ImageAdjacentMember" returntype="struct" output="false" hint="returns ImageAdjacentMember">
    <!--- arguments --->
    <cfargument name="fileUuid" type="string" required="no" default="" hint="argument description: fileUuid" />
    <cfargument name="userid" type="numeric" required="no" default="0" hint="argument description: userid" />
    <cfargument name="direction" type="string" required="no" default="next" hint="argument description: direction" />
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfhttp url="#request.restApiEndpoint#/image/adjacent/#arguments.fileUuid#/#arguments.userid#/#arguments.direction#" method="get" result="local.result" timeout="30">
      <cfhttpparam type="header" name="userToken" value="#arguments.userToken#" />
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: imageApprovedByUseridCollection  --->
  
  <cffunction name="ImageApprovedByUseridCollection" returntype="struct" output="false" hint="returns ImageApprovedByUseridCollection">
    <!--- arguments --->
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfhttp url="#request.restApiEndpoint#/images/approved/userid" method="get" result="local.result" timeout="30">
      <cfhttpparam type="header" name="userToken" value="#arguments.userToken#" />
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: imageByCategoryCollection  --->
  
  <cffunction name="ImageByCategoryCollection" returntype="struct" output="false" hint="returns ImageByCategoryCollection">
    <!--- arguments --->
    <cfargument name="category" type="string" required="no" default="" hint="argument description: category" />
    <cfargument name="page" type="numeric" required="no" default="1" hint="argument description: page" />
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfhttp url="#request.restApiEndpoint#/images/category/#arguments.category#/#arguments.page#" method="get" result="local.result" timeout="30">
      <cfhttpparam type="header" name="userToken" value="#arguments.userToken#" />
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: imageByDateCollection  --->
  
  <cffunction name="ImageByDateCollection" returntype="struct" output="false" hint="returns ImageByDateCollection">
    <!--- arguments --->
    <cfargument name="year" type="numeric" required="no" default="#Year(Now())#" hint="argument description: year" />
    <cfargument name="month" type="numeric" required="no" default="#Month(Now())#" hint="argument description: month" />
    <cfargument name="page" type="numeric" required="no" default="1" hint="argument description: page" />
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfhttp url="#request.restApiEndpoint#/images/date/#arguments.year#/#arguments.month#/#arguments.page#" method="get" result="local.result" timeout="30">
      <cfhttpparam type="header" name="userToken" value="#arguments.userToken#" />
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: imageByTagCollection  --->
  
  <cffunction name="ImageByTagCollection" returntype="struct" output="false" hint="returns ImageByTagCollection">
    <!--- arguments --->
    <cfargument name="tag" type="string" required="no" default="" hint="argument description: tag" />
    <cfargument name="page" type="numeric" required="no" default="1" hint="argument description: page" />
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfhttp url="#request.restApiEndpoint#/images/tag/#arguments.tag#/#arguments.page#" method="get" result="local.result" timeout="30">
      <cfhttpparam type="header" name="userToken" value="#arguments.userToken#" />
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: imageByUseridCollection  --->
  
  <cffunction name="ImageByUseridCollection" returntype="struct" output="false" hint="returns ImageByUseridCollection">
    <!--- arguments --->
    <cfargument name="userid" type="numeric" required="no" default="0" hint="argument description: userid" />
    <cfargument name="page" type="numeric" required="no" default="1" hint="argument description: page" />
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfhttp url="#request.restApiEndpoint#/images/userid/#arguments.userid#/#arguments.page#" method="get" result="local.result" timeout="30">
      <cfhttpparam type="header" name="userToken" value="#arguments.userToken#" />
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: pageByTagCollection  --->
  
  <cffunction name="PageByTagCollection" returntype="struct" output="false" hint="returns PageByTagCollection">
    <!--- arguments --->
    <cfargument name="tag" type="string" required="no" default="" hint="argument description: tag" />
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfhttp url="#request.restApiEndpoint#/pages/tag/#arguments.tag#" method="get" result="local.result" timeout="30">
      <cfhttpparam type="header" name="userToken" value="#arguments.userToken#" />
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: pageByTitleCollection  --->
  
  <cffunction name="PageByTitleCollection" returntype="struct" output="false" hint="returns PageByTitleCollection">
    <!--- arguments --->
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfhttp url="#request.restApiEndpoint#/pages/title" method="get" result="local.result" timeout="30">
      <cfhttpparam type="header" name="userToken" value="#arguments.userToken#" />
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: pageByCategoriesCollection  --->
  
  <cffunction name="PageByCategoriesCollection" returntype="struct" output="false" hint="returns PageByCategoriesCollection">
    <!--- arguments --->
    <cfargument name="category" type="string" required="no" default="" hint="argument description: category" />
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfif NOT Len(Trim(arguments.userToken))>
	  <cfset arguments.userToken = "empty">
    </cfif>
    <cfhttp url="#request.restApiEndpoint#/pages/categories/#arguments.category#/#arguments.userToken#" method="get" result="local.result" timeout="30">
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: pageByDateCollection  --->
  
  <cffunction name="PageByDateCollection" returntype="struct" output="false" hint="returns PageByDateCollection">
    <!--- arguments --->
    <cfargument name="year" type="numeric" required="no" default="#Year(Now())#" hint="argument description: year" />
    <cfargument name="month" type="numeric" required="no" default="#Month(Now())#" hint="argument description: month" />
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfif NOT Len(Trim(arguments.userToken))>
	  <cfset arguments.userToken = "empty">
    </cfif>
    <cfhttp url="#request.restApiEndpoint#/pages/dates/#arguments.year#/#arguments.month#/#arguments.userToken#" method="get" result="local.result" timeout="30">
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: pageByImageCollection  --->
  
  <cffunction name="PageByImageCollection" returntype="struct" output="false" hint="returns PageByImageCollection">
    <!--- arguments --->
    <cfargument name="fileUuid" type="string" required="no" default="" hint="argument description: file uuid" />
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfhttp url="#request.restApiEndpoint#/pages/#arguments.fileUuid#" method="get" result="local.result" timeout="30">
      <cfhttpparam type="header" name="userToken" value="#arguments.userToken#" />
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: pageByImagesCollection  --->
  
  <cffunction name="PageByImagesCollection" returntype="struct" output="false" hint="returns PageByImagesCollection">
    <!--- arguments --->
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfif NOT Len(Trim(arguments.userToken))>
	  <cfset arguments.userToken = "empty">
    </cfif>
    <cfhttp url="#request.restApiEndpoint#/pages/images/#arguments.userToken#" method="get" result="local.result" timeout="30">
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: pageBySearchCollection  --->
  
  <cffunction name="PageBySearchCollection" returntype="struct" output="false" hint="returns PageBySearchCollection">
    <!--- arguments --->
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <cfargument name="term" type="string" required="no" default="" hint="argument description: term" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfif NOT Len(Trim(arguments.userToken))>
	  <cfset arguments.userToken = "empty">
    </cfif>
    <cfhttp url="#request.restApiEndpoint#/pages/search/#arguments.userToken#" method="get" result="local.result" timeout="30">
      <cfhttpparam type="header" name="term" value="#arguments.term#" />
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: pageByUseridCollection  --->
  
  <cffunction name="PageByUseridCollection" returntype="struct" output="false" hint="returns PageByUseridCollection">
    <!--- arguments --->
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfif NOT Len(Trim(arguments.userToken))>
	  <cfset arguments.userToken = "empty">
    </cfif>
    <cfhttp url="#request.restApiEndpoint#/pages/userid/#arguments.userToken#" method="get" result="local.result" timeout="30">
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: pageUnapprovedByUseridCollection  --->
  
  <cffunction name="PageUnapprovedByUseridCollection" returntype="struct" output="false" hint="returns PageUnapprovedByUseridCollection">
    <!--- arguments --->
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfif NOT Len(Trim(arguments.userToken))>
	  <cfset arguments.userToken = "empty">
    </cfif>
    <cfhttp url="#request.restApiEndpoint#/pages/unapproved/userid/#arguments.userToken#" method="get" result="local.result" timeout="30">
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: pageApprovedByUseridCollection  --->
  
  <cffunction name="PageApprovedByUseridCollection" returntype="struct" output="false" hint="returns PageApprovedByUseridCollection">
    <!--- arguments --->
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfif NOT Len(Trim(arguments.userToken))>
	  <cfset arguments.userToken = "empty">
    </cfif>
    <cfhttp url="#request.restApiEndpoint#/pages/approved/userid/#arguments.userToken#" method="get" result="local.result" timeout="30">
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: pageCollection  --->
  
  <cffunction name="PageCollection" returntype="struct" output="false" hint="returns PageCollection">
    <!--- arguments --->
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfhttp url="#request.restApiEndpoint#/pages" method="get" result="local.result" timeout="30">
      <cfhttpparam type="header" name="userToken" value="#arguments.userToken#" />
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: signupvalidatedMember  --->
  
  <cffunction name="SignupvalidatedMember" returntype="struct" output="false" hint="returns SignupvalidatedMember">
    <!--- arguments --->
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfhttp url="#request.restApiEndpoint#/signupvalidated/#arguments.userToken#" method="get" result="local.result" timeout="30">
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: themeMember  --->
  
  <cffunction name="ThemeMember" returntype="struct" output="false" hint="returns ThemeMember">
    <!--- arguments --->
    <cfargument name="theme" type="string" required="no" default="#request.theme#" hint="argument description: theme" />
    <cfargument name="authorization" type="string" required="no" default="" hint="argument description: authorization" />
    <cfargument name="userToken" type="string" required="no" default="" hint="argument description: userToken" />
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfhttp url="#request.restApiEndpoint#/theme/#arguments.userToken#" method="post" result="local.result" timeout="30">
      <cfhttpparam type="header" name="Authorization" value="Bearer #Trim(arguments.authorization)#" />
      <cfhttpparam type="header" name="theme" value="#arguments.theme#" />
      <cfhttpparam type="header" name="X-HTTP-METHOD-OVERRIDE" value="PUT" />
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
  
  
  <!--- FUNCTION UDF: tokenMember  --->
  
  <cffunction name="TokenMember" returntype="struct" output="false" hint="returns TokenMember">
    <!--- arguments --->
    <!--- local variables --->
    <cfset var local = StructNew()>
    <cfset local.result = StructNew()>
    <!--- logic --->
    <cfhttp url="#request.restApiEndpoint#/token" method="get" result="local.result" timeout="30">
    </cfhttp>
  <cfreturn local.result />
  </cffunction>
	

</cfcomponent>