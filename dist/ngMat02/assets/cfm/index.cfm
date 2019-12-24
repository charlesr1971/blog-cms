<cfoutput>

  <cfparam name="ngdomid" default="#RandRange(1000000,9999999)#">
  <cfparam name="commentToken" default="">
  <cfparam name="id" default="">
  <cfparam name="title" default="">
  <cfparam name="signUpValidated" default="0">
  <cfparam name="forgottenPasswordToken" default="">
  <cfparam name="forgottenPasswordValidated" default="0">
  
  <cfif StructKeyExists(url,"signUpToken")>
    <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUser 
      WHERE SignUpToken = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.signUpToken#">
    </CFQUERY>
    <cfif qGetUser.RecordCount>
      <CFQUERY NAME="qUpdateSignUpValidated" DATASOURCE="#request.domain_dsn#">
        UPDATE tblUser
        SET SignUpValidated = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"> 
        WHERE SignUpToken = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.signUpToken#">
      </CFQUERY>
      <cfset signUpValidated = 1>
    </cfif>
  </cfif>
  
  <cfif StructKeyExists(url,"forgottenPasswordToken")>
    <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
      SELECT * 
      FROM tblUser 
      WHERE ForgottenPasswordToken = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.forgottenPasswordToken#">
    </CFQUERY>
    <cfif qGetUser.RecordCount>
      <CFQUERY NAME="qUpdateForgottenPasswordValidated" DATASOURCE="#request.domain_dsn#">
        UPDATE tblUser
        SET ForgottenPasswordValidated = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1">
        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUser.User_ID#">
      </CFQUERY>
      <cfset forgottenPasswordToken = url.forgottenPasswordToken>
      <cfset forgottenPasswordValidated = 1>
    </cfif>
  </cfif>

  <cfif StructKeyExists(url,"commentToken")>
	<cfset commentToken = url.commentToken>
  </cfif>
  
  <cfif StructKeyExists(url,"fileToken") AND Len(Trim(url.fileToken))>
	<CFQUERY NAME="qUpdateFileApproved" DATASOURCE="#request.domain_dsn#">
      UPDATE tblFile
      SET Approved = <cfqueryparam cfsqltype="cf_sql_tinyint" value="1"> 
      WHERE FileToken = <cfqueryparam cfsqltype="cf_sql_varchar" value="#url.fileToken#">
    </CFQUERY>
  </cfif>
  
  <cfif StructKeyExists(url,"id")>
	<cfset id = url.id>
  </cfif>
  
  <cfif StructKeyExists(url,"title")>
	<cfset title = url.title>
  </cfif>
  
  <!---<cfif request.appreloadValidated>
	<cfabort />
  </cfif>--->

  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    
  <html xmlns="http://www.w3.org/1999/xhtml">
    
    <head>
      
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=yes">
      <meta name="twitter:card" content="#request.twitterCardType#" />
      <meta name="twitter:site" content="#request.twitterSite#" />
      <meta name="twitter:creator" content="#request.twitterCreator#" />
      <meta name="twitter:title" content="#request.ogTitle#" />
      <meta name="twitter:description" content="#request.ogDescription#" />
      <meta name="twitter:image" content="#request.twittercard#" />
      <meta property="og:url" content="#request.ogUrl#" />
      <meta property="og:title" content="#request.ogTitle#" />
      <meta property="og:description" content="#request.ogDescription#" />
      <meta property="og:image" content="#request.twittercard#" />
      <meta name="description" content="#request.metadescription#">
      <meta name="keywords" content="#request.metakeywords#">
      <title>#request.htmlTitle#</title>
      <link rel="shortcut icon" href="../../favicon.png">
      <cfif NOT request.appreloadValidated>
		<script type="text/javascript">
          location.href = "#request.ngIframeSrc#?port=#request.cfport#&cfid=#cookie.cfid#&cftoken=#cookie.cftoken#&ngdomid=#ngdomid#&maxcontentlength=#request.maxcontentlength#&tinymcearticlemaximages=#request.tinymcearticlemaximages#&commenttoken=#commentToken#&id=#id#&title=#URLEncodedFormat(title)#&signUpValidated=#signUpValidated#&theme=#request.theme#&websiteTitle=#URLEncodedFormat(request.title)#&htmlTitle=#URLEncodedFormat(request.htmlTitle)#&twitterCardType=#URLEncodedFormat(request.twitterCardType)#&twitterSite=#URLEncodedFormat(request.twitterSite)#&twitterCreator=#URLEncodedFormat(request.twitterCreator)#&ogUrl=#URLEncodedFormat(request.ogUrl)#&ogTitle=#URLEncodedFormat(request.ogTitle)#&ogDescription=#URLEncodedFormat(request.ogDescription)#&ogImage=#URLEncodedFormat(request.ogImage)#&adZoneUrl=#URLEncodedFormat(request.adzoneurl)#&userAccountDeleteSchema=#request.userAccountDeleteSchema#&forgottenPasswordToken=#forgottenPasswordToken#&forgottenPasswordValidated=#forgottenPasswordValidated#&imageMediumSuffix=#request.imageMediumSuffix#&subscribeurl=#URLEncodedFormat(request.subscribeurl)#&subscribeFormId=#request.subscribeFormId#&subscribeTaskKey=#request.subscribeTaskKey#&sectionauthortype=#request.sectionauthortype#&externalUrls=#URLEncodedFormat(request.externalUrls)#&metadescription=#URLEncodedFormat(request.metadescription)#&metakeywords=#URLEncodedFormat(request.metakeywords)#&useHubToDeliverSocialMedia=#request.useHubToDeliverSocialMedia#&domainURLBaseHomeProxy=#URLEncodedFormat(request.domainURLBaseHomeProxy)#&proxyIsLocal=#request.proxyIsLocal#&ngAccessControlAllowOrigin=#URLEncodedFormat(request.ngAccessControlAllowOrigin)#";
        </script>
      </cfif>
    </head>
    <body>
        
    </body>
  </html>

</cfoutput>