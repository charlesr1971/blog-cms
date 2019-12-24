<cfscript>

  request.title = "Establish Mindfulness";
  request.htmlTitle = request.title & " | Community";
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
  if(StructKeyExists(url,"useSSL") AND NOT url.useSSL){
	request.protocol = "http";
	request.remoteprotocol = "http";
  }
  request.domain_dsn = "community-establishmindfulness";
  request.domain_dsn_app = "establishmindfulness";
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
  request.ogDescription = "Join Paul Meek and the meditation community at Establish Mindfulness online. Contribute mindfulness stories to help others find the right balance in everyday life.";
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
  
  request.externalUrls = SerializeJson([{'title':'Blog','url':'https://www.establishmindfulness.com'},{'title':'Learning Centre','url':'https://app.establishmindfulness.com'}]);

  request.sectionauthortype = "author"; //author, user
  
  request.punctuationSubsetPattern = "[.\/\\##!$%\^&\*;{}=_""`~()]";
  request.sitemapmaxlinks = 1000;
  
  request.metadescription = "Join Paul Meek and the meditation community at Establish Mindfulness online. Contribute mindfulness stories to help others find the right balance in everyday life.";
  request.metakeywords = "meditation for everyday life, mindfulness for everyday life, meditation for life, mindfulness for life, establish mindfulness, Paul Meek, meditation community";
  
  request.domainURLBaseHome = request.protocol & "://localhost:8500/establishmindfulness";
  
  if(!IsLocalHost(CGI.REMOTE_ADDR)){
	request.domainURLBaseHome = request.protocol & "://app.establishmindfulness.com";
  }
  
  request.useHubToDeliverSocialMedia = 0;
  request.domainName = "";
  request.subDomain = "";
  
  local.queryObj = new Query();	 
  local.queryObj.setDatasource(request.domain_dsn_app);
  local.queryObj.setName("qGetGlobalSettings");
  local.queryResult = queryObj.execute(sql="SELECT * FROM tblGlobalSettings1");
  local.qGetSettings = local.queryResult.getResult(); 
  if(local.qGetSettings.RecordCount){
	request.useHubToDeliverSocialMedia = local.qGetSettings.Use_hub_to_deliver_social_media;
  }
  
  local.queryObj = new Query();	 
  local.queryObj.setDatasource(request.domain_dsn_app);
  local.queryObj.setName("qGetGlobalSettings");
  local.queryResult = queryObj.execute(sql="SELECT * FROM tblGlobalSettings");
  local.qGetSettings = local.queryResult.getResult(); 
  if(local.qGetSettings.RecordCount){
	request.domainName = local.qGetSettings.Domain_name;
	request.subDomain = local.qGetSettings.Sub_domain;
  }
  
  local.domainStem = ListFirst(request.domainName,".");
  
  request.domainURLBaseHomeProxy = ReplaceNoCase(request.domainURLBaseHome,local.domainStem,"proxy." & local.domainStem);
  request.domainURLBaseHomeHub = ReplaceNoCase(request.domainURLBaseHome,local.domainStem,"hub." & local.domainStem);
  if(Len(Trim(request.subDomain))){
	request.domainURLBaseHomeProxy = ReplaceNoCase(request.domainURLBaseHomeProxy,request.subDomain & ".","");
    request.domainURLBaseHomeHub = ReplaceNoCase(request.domainURLBaseHomeHub,request.subDomain & ".","");
    request.domainURLBaseHomeHub = ReplaceNoCase(request.domainURLBaseHomeHub,"https","http");
  }
  
  if(NOT Len(Trim(request.subDomain))){
	request.useHubToDeliverSocialMedia = 0;
  }
  
  request.proxyIsLocal = false;
  
  if(IsLocalHost(CGI.REMOTE_ADDR)){
	request.proxyIsLocal = true;
  }
  
  if(NOT StructKeyExists(APPLICATION,"isproxyavailable") OR request.appreloadValidated){
	cflock (name="isproxyavailable",type="exclusive",timeout=10) {
	  application.isproxyavailable = true;
	}
    try{
	  cfhttp(url=request.domainURLBaseHomeProxy & "?proxyIsLocal=" & request.proxyIsLocal,method="get",result="local.isproxyavailable",timeout=10);
      if(StructKeyExists(local.isproxyavailable,"Responseheader") AND StructKeyExists(local.isproxyavailable['Responseheader'],"Status_Code")){
		if(local.isproxyavailable.Responseheader.Status_Code EQ "404"){
          cflock (name="isproxyavailable",type="exclusive",timeout=10) {
			application.isproxyavailable = false;
		  }
		}
	  }
      else{
        cflock (name="isproxyavailable",type="exclusive",timeout=10) {
		  application.isproxyavailable = false;
		}
	  }
	}
	catch( any e ){
	  cflock (name="isproxyavailable",type="exclusive",timeout=10) {
		application.isproxyavailable = false;
	  }
	}
  }
  
  cflock(name="isproxyavailable",type="readonly",timeout=10){
	request.isproxyavailable =  application.isproxyavailable;
  }
  
  if(NOT StructKeyExists(APPLICATION,"ishubavailable") OR request.appreloadValidated){
	cflock (name="ishubavailable",type="exclusive",timeout=10) {
	  application.ishubavailable = true;
	}
    try{
	  cfhttp(url=request.domainURLBaseHomeHub,method="get",result="local.ishubavailable",timeout=10);
      if(StructKeyExists(local.ishubavailable,"Responseheader") AND StructKeyExists(local.ishubavailable['Responseheader'],"Status_Code")){
		if(local.ishubavailable.Responseheader.Status_Code EQ "404"){
          cflock (name="ishubavailable",type="exclusive",timeout=10) {
			application.ishubavailable = false;
		  }
		}
	  }
      else{
        cflock (name="ishubavailable",type="exclusive",timeout=10) {
		  application.ishubavailable = false;
		}
	  }
	}
	catch( any e ){
	  cflock (name="ishubavailable",type="exclusive",timeout=10) {
		application.ishubavailable = false;
	  }
	}
  }
  
  cflock(name="ishubavailable",type="readonly",timeout=10){
	request.ishubavailable =  application.ishubavailable;
  }
  
  if(NOT request.isproxyavailable OR NOT request.ishubavailable){
	request.useHubToDeliverSocialMedia = 0;
  }
  
  


</cfscript>