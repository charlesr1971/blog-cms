<cfscript>

  request.title = "Establish Mindfulness";
  request.htmlTitle = request.title & " S.P.A";
  request.cfport = 0;
  request.maxcontentlength = 500000;
  request.tinymcearticlemaximages = 2;
  request.theme = "theme-1-dark";
  request.useSSL = true;
  request.protocol = "http";
  request.remoteprotocol = "http";
  if(!IsLocalHost(CGI.REMOTE_ADDR) AND request.useSSL){
	request.protocol = "https";
  }
  if(request.useSSL){
	request.remoteprotocol = "https";
  }
  request.domain_dsn = "community-establishmindfulness";
  request.websiteRootDirectory = "";
  request.localHost = "community.establishmindfulness/material/ngMat02";
  request.remoteHost = "community.establishmindfulness.com";
  
  request.twitterCardType = "summary";
  request.twitterSite = "@charlesr1971";
  request.twitterCreator = "@charlesr1971";
  request.ogUrl = request.remoteprotocol & "://" & request.remoteHost & "/";
  request.unsecureOgUrl = ReplaceNoCase(request.ogUrl,"https:","http:");
  request.ogTitle = request.htmlTitle;
  request.ogDescription = "This website allows users to upload their favourite photos to the gallery. The following technologies power this website. An Angular 7x front-end with a Google Material UI. An Adobe Coldfusion back-end, using a Lucee 5 Application server with a MySQL database.";
  request.ogImage = "";
  
  if(IsLocalHost(CGI.REMOTE_ADDR)){
	request.adzoneurl = "http://localhost:8500/establishmindfulness/includes/structures/adzone-structure.cfm";
  }
  else{
	request.adzoneurl = "https://app.establishmindfulness.com/includes/structures/adzone-structure.cfm";
  }
  
  request.catalogRouterAlias = "stories";
  request.userAccountDeleteSchema = 2; //0=no delete, 1=delete, 2=archive


</cfscript>