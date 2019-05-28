<cfscript>

  request.title = "Establish Mindfulness";
  request.htmlTitle = request.title & ": Community";
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
  request.remoteDomain = "establishmindfulness.com";
  request.remoteSubDomain = "community";
  if(Len(Trim(request.remoteSubDomain))){
	request.remoteHost = request.remoteSubDomain & "." & request.remoteDomain;
  }
  else{
	request.remoteHost = request.remoteDomain;
  }
  request.remoteEmailPrefix = "admin+";
  
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
  
  if(IsLocalHost(CGI.REMOTE_ADDR)){
	request.subscribeurl = "http://localhost:8500/blog1.establishmindfulness/default/remote/dsp_subscribe.cfm";
	request.subscribeFormId = "296A7E58-84A6-C828-BCCF6F1EA827EED2";
	request.subscribeTaskKey = "4F893EE24950069DD823E083338A456D";
  }
  else{
	request.subscribeurl = "https://www.establishmindfulness.com/default/remote/dsp_subscribe.cfm";
	request.subscribeFormId = "296A7E58-84A6-C828-BCCF6F1EA827EED2";
	request.subscribeTaskKey = "4F893EE24950069DD823E083338A456D";
  }
  
  request.sectionauthortype = "author"; //author, user
  
  request.externalUrls = SerializeJson([{'title':'Blog','url':'https://www.establishmindfulness.com'},{'title':'Learning Centre','url':'https://app.establishmindfulness.com'}]);
  
  request.punctuationSubsetPattern = "[.\/\\##!$%\^&\*;{}=_""`~()]";
  request.sitemapmaxlinks = 1000;
  
  request.metadescription = "Join Paul Meek and the meditation community at Establish Mindfulness online. Contribute mindfulness stories to help others find the right balance in everyday life.";
  request.metakeywords = "meditation for everyday life, mindfulness for everyday life, meditation for life, mindfulness for life, establish mindfulness, Paul Meek, meditation community";
  
  


</cfscript>