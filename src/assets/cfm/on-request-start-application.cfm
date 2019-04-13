
<cfscript>

  request.appreloadkey = this.name;
  request.appreloadValidated = false;
  
  local.timestamp = DateFormat(Now(),'yyyymmdd') & TimeFormat(Now(),'HHmmss');
  
  if((StructKeyExists(url,"appreload") AND NOT isLocalhost(CGI.REMOTE_ADDR) AND CompareNocase(url.appReload,request.appreloadkey) EQ 0) OR (StructKeyExists(url,"appreload") AND isLocalhost(CGI.REMOTE_ADDR))){
	request.appreloadValidated = true;
  }

  if(request.appreloadValidated){
	OnApplicationStart();
	this.applicationTimeout = CreateTimeSpan( 0, 0, 0, 1 );
  }
  
  if(FindNoCase("Coldfusion",SERVER.ColdFusion.ProductName)){
	request.engine = "Coldfusion";
  }
  else{
	request.engine = "Railo";
  }
  
  // START: settings
  
  include "settings/settings.cfm";
  
  // END: settings
  
  request.newline = Chr(13) & Chr(10);
  request.crptographyencoding = "Hex";
  request.crptographyalgorithm = "AES";
  request.crptographykey = generateSecretKey(request.crptographyalgorithm);
  
  request.emailServer = "";
  request.emailUsername = "";
  request.emailSalt = "";
  request.emailPassword = "";
  request.email = "";
  request.emailPort = 25;
  request.emailUseSsl = "no";
  request.emailUseTls = "no";
  request.googleRecaptchaSecretKey = "";
  local.queryObj = new Query();	 
  local.queryObj.setDatasource(request.domain_dsn);
  local.queryObj.setName("qGetSettings");
  local.queryResult = queryObj.execute(sql="SELECT * FROM tblSettings");
  local.qGetSettings = local.queryResult.getResult(); 
  if(local.qGetSettings.RecordCount){
	request.emailServer = local.qGetSettings.Email_server;
	request.emailUsername = local.qGetSettings.Email_username;
	request.emailSalt = local.qGetSettings.Email_salt;
	request.emailPassword = local.qGetSettings.Email_password;
	request.email = local.qGetSettings.Email;
	request.emailPort = local.qGetSettings.Email_port;
	request.emailUseSsl = YesNoFormat(local.qGetSettings.Email_use_ssl);
	request.emailUseTls = YesNoFormat(local.qGetSettings.Email_use_tls);
	request.googleRecaptchaSecretKey = local.qGetSettings.Google_recaptcha_secret_key;
  }
  
  if(CompareNoCase(local.identity,"parent") EQ 0){
	request.basePathFull = this.currentTemplatePathDirectory;
  }
  else{
	request.basePathFull = ExpandPath('../../../');
  }
  request.basePath = REReplaceNoCase( request.basePathFull, "\\$", "", "ALL" );
  request.webroot = ExpandPath( "/" );
  request.filepath = request.basePath;
  request.assetdirectory = "";
  request.assetdir = "";
  
  if(IsLocalHost(CGI.REMOTE_ADDR)){
	if(CompareNoCase(local.identity,"parent") EQ 0){
	  request.securefilepath = ExpandPath('../../../../secure');
	}
	else{
	  request.securefilepath = ExpandPath('../../../../../../../secure');
	}
  }
  else{
	if(CompareNoCase(local.identity,"parent") EQ 0){
	  request.securefilepath = ExpandPath('../../../secure');
	}
	else{
	  request.securefilepath = ExpandPath('../../../../../../secure');
	}
  }
  
  if(NOT DirectoryExists(request.securefilepath)){
	try{
	  cflock (name="create_directory_" & local.timestamp, type="exclusive", timeout="30") {
		cfdirectory(action="create",directory=request.securefilepath);
	  }
	}
	catch( any e ){
	}
  }
  
  if(CompareNoCase(local.identity,"parent") EQ 0){
	request.webrootfilepath = ExpandPath('../../');
  }
  else{
	request.webrootfilepath = ExpandPath('../../../../../');
  }
  
  if( Len( Trim( request.assetdirectory ) ) ){
	request.assetdir = "/" & Mid( request.assetdirectory, 1, Len( request.assetdirectory )-1 );
  }
  
  request.filepathasset = request.filepath & ReplaceNoCase( request.assetdir, '/', '\', 'ALL' );
  
  request.rootdir = "";
  request.equalswebroot = false;
  request.clientdir = ReplaceNoCase( request.basePathFull, request.webroot, "", "ALL" );
  request.clientdir = REReplaceNoCase( request.clientdir, "\\$", "", "ALL" );
  request.avatarbasesrc = "assets/cfm/user-avatars/";
  
  if( Len( Trim( request.clientdir ) ) ){
	  
	if( ListLen( request.clientdir, "\" ) ){
	  request.clientdir = ListGetAt( request.clientdir, ListLen( request.clientdir, "\" ), "\" );
	  request.rootdir = "/" & request.clientdir;
	}
	
  }
  else{
	  
	request.equalswebroot = true;
	
	if( Len( Trim( request.webroot ) ) ){
		
	  if( ListLen( request.webroot, "\" ) ){
		request.clientdir = ListGetAt( request.webroot, ListLen( request.webroot, "\" ), "\" );
	  }
	  
	}
	
  }
  
  //theme=#request.theme#
  
  local.ngport = 4200;
  
  local.host = ListFirst(CGI.HTTP_HOST,":");
  request.absoluteBaseUrl = request.protocol & "://" & CGI.HTTP_HOST;
  request.domainToken = Hash(request.basePathFull);
  request.ngAccessControlAllowOrigin = request.absoluteBaseUrl;
  request.ngIframeSrc = request.ngAccessControlAllowOrigin & "/" & request.websiteRootDirectory;
  request.uploadfolder = request.ngIframeSrc & "assets/cfm";
  request.tinymcearticleuploadfolder = request.ngIframeSrc & "assets/cfm/article-images";
  request.ngIframeSrc = request.ngIframeSrc & "index.html";
  if(IsLocalHost(CGI.REMOTE_ADDR)){
	local.host = ListAppend(local.host,local.ngport,":");
	request.cfport = ListLast(CGI.HTTP_HOST,":");
	request.ngAccessControlAllowOrigin = request.protocol & "://" & local.host;
	if(ListLen(local.host,":") EQ 1){
	  request.ngAccessControlAllowOrigin = request.protocol & "://localhost";
	}
	request.ngIframeSrc = request.ngAccessControlAllowOrigin;
	request.uploadfolder = request.absoluteBaseUrl & "/" & request.localHost & "/src/assets/cfm";
	request.tinymcearticleuploadfolder = request.absoluteBaseUrl & "/" & request.localHost & "/src/assets/cfm/article-images";
  }	
  
  request.restApiEndpoint = request.uploadfolder & "/rest/api/v1/index.cfm";
  
  if(!IsLocalHost(CGI.REMOTE_ADDR)){
	request.restApiEndpoint = request.uploadfolder & "/rest/api/v1";
  }
   
  request.remotedomainurl = request.remoteprotocol & "://" & request.remoteHost; 
  request.remoteuploadfolder = request.remoteprotocol & "://" & request.remoteHost & "/" & request.websiteRootDirectory & "assets/cfm";
  request.emailimagesrc = request.remoteprotocol & "://" & request.remoteHost & "/" & request.websiteRootDirectory & "assets/images";
  request.emailimagealt = request.title & "S.P.A";  
  
  request.jwtexpiryminutes = 60;
  request.refreshExpiredToken = true;
  request.allowMultipleLikesPerUser = 0;
  
  local.queryObj = new Query();	 
  local.queryObj.setDatasource(request.domain_dsn);
  local.queryObj.setName("qGetFile");
  local.queryResult = queryObj.execute(sql="SELECT * FROM tblFile");
  local.qGetFile = local.queryResult.getResult(); 
  local.records = local.qGetFile.RecordCount;
  request.filebatch = 0;
  if(local.qGetFile.RecordCount) {
	try{
	  local.logFactor = 11;
	  local.formula = (local.records * local.logFactor)/(Log(local.records)/Log(1.05));
	  request.filebatch = Ceiling(local.formula);
	}
	catch(any e) {
	}
  }
  if(request.filebatch < 4){
	request.filebatch = 4;
  }
  
  local.queryObj = new Query();	 
  local.queryObj.setDatasource(request.domain_dsn);
  local.queryObj.setName("qGetComment");
  local.queryResult = queryObj.execute(sql="SELECT * FROM tblComment INNER JOIN tblUser ON tblComment.User_ID = tblUser.User_ID");
  local.qGetComment = local.queryResult.getResult(); 
  local.records = local.qGetComment.RecordCount;
  request.commentbatch = 0;
  if(local.qGetComment.RecordCount) {
	try{
	  local.logFactor = 11;
	  local.formula = (local.records * local.logFactor)/(Log(local.records)/Log(1.05));
	  request.commentbatch = Ceiling(local.formula);
	}
	catch(any e) {
	}
  }
  if(request.commentbatch < 3){
	request.commentbatch = 3;
  }
  
  request.lckbcryptlibinit = true;
  
  if(NOT StructKeyExists(application,"bcryptlib") OR request.appreloadValidated OR ISDEFINED('url.cfcreload')) {
	try{
	  cflock (name="bcryptlib", type="exclusive", timeout="30") {
		application.jbClass = request.filepathasset & "\lib\jBCrypt-0.4";
		application.javaloader = createObject('component','components.javaloader.JavaLoader');
		application.javaloader.init([application.jbClass]);
		application.bcryptlib = application.javaloader.create("BCrypt");
	  }
	}
	catch(any e) {
	  request.lckbcryptlibinit = false;
	}
  }
  
  if(request.lckbcryptlibinit) {
	cflock (name="bcryptliblck", type="readonly", timeout="30") {
	  request.lckbcryptlib = application.bcryptlib;
	}
  }
  else{
	request.lckbcryptlib = "";
  }
  
  if(NOT StructKeyExists(application,"jwtjavaloader") OR request.appreloadValidated) {
	try{
	  cflock (name="jwtjavaloader", type="exclusive", timeout="30") {
		local.jarSystemPath = request.filepathasset & "\lib\chamika-jwt-sign-encrypt\chamika-jwt-sign-encrypt-1.0.8.jar";
		application.jwtjavaloader = createObject('component','components.javaloader.JavaLoader');
		application.jwtjavaloader.init([local.jarSystemPath]);
	  }
	}
	catch(any e) {
	  cflock (name="jwtjavaloader", type="exclusive", timeout="30") {
		application.jwtjavaloader = "";
	  }
	}
  }
  
  cflock (name="jwtjavaloader", type="readonly", timeout="30") {
	request.jwtjavaloader = application.jwtjavaloader;
  }
  
  if(NOT StructKeyExists(application,"encrypter") OR request.appreloadValidated) {
	try{
	  cflock (name="encrypter", type="exclusive", timeout="30") {
		application.encrypter = createObject('component','components.jwt.lib.encrypt.Encrypter');
	  }
	}
	catch(any e) {
	  cflock (name="encrypter", type="exclusive", timeout="30") {
		application.encrypter = {};
	  }
	}
  }
  cflock (name="encrypter", type="readOnly", timeout="10") {
	  request.encrypter = application.encrypter;
  }
  
  if(NOT StructKeyExists(application,"twittercard")) {
	cflock (name="twittercard", type="exclusive", timeout="30") {
	  application.twittercard = request.protocol & "://" & request.remoteHost & "/" & request.websiteRootDirectory & "assets/images/twitter-card.png";
	}
  }
  
  cflock (name="twittercard", type="readOnly", timeout="10") {
	request.twittercard = application.twittercard;
  }
  
  request.ogImage = request.twittercard;
  
  request.unsecureTwittercard = ReplaceNoCase(request.twittercard,"https:","http:");
  
  if(NOT StructKeyExists(application,"utils") OR request.appreloadValidated) {
	try{
	  cflock (name="utils", type="exclusive", timeout="30") {
		application.utils = createObject('component','components.Utils');
	  }
	}
	catch(any e) {
	  cflock (name="utils", type="exclusive", timeout="30") {
		application.utils = {};
	  }
	}
  }
  cflock (name="utils", type="readOnly", timeout="10") {
	  request.utils = application.utils;
  }
  
  request.materialThemeData = [
	{
	  themeName:'theme-1',
	  colorName:'$mat-blue-grey',
	  primaryIndex:'500',
	  primaryHex:'##607D8B'
	},
	{
	  themeName:'theme-2',
	  colorName:'$mat-red',
	  primaryIndex:'500',
	  primaryHex:'##F44336'
	},
	{
	  themeName:'theme-3',
	  colorName:'$mat-pink',
	  primaryIndex:'500',
	  primaryHex:'##E91E63'
	},
	{
	  themeName:'theme-4',
	  colorName:'$mat-purple',
	  primaryIndex:'500',
	  primaryHex:'##9C27B0'
	},
	{
	  themeName:'theme-5',
	  colorName:'$mat-deep-purple',
	  primaryIndex:'500',
	  primaryHex:'##673AB7'
	},
	{
	  themeName:'theme-6',
	  colorName:'$mat-indigo',
	  primaryIndex:'500',
	  primaryHex:'##3F51B5'
	},
	{
	  themeName:'theme-7',
	  colorName:'$mat-blue',
	  primaryIndex:'500',
	  primaryHex:'##3F51B5'
	},
	{
	  themeName:'theme-8',
	  colorName:'$mat-light-blue',
	  primaryIndex:'500',
	  primaryHex:'##03A9F4'
	},
	{
	  themeName:'theme-9',
	  colorName:'$mat-cyan',
	  primaryIndex:'500',
	  primaryHex:'##00BCD4'
	},
	{
	  themeName:'theme-10',
	  colorName:'$mat-teal',
	  primaryIndex:'500',
	  primaryHex:'##009688'
	},
	{
	  themeName:'theme-11',
	  colorName:'$mat-green',
	  primaryIndex:'500',
	  primaryHex:'##4CAF50'
	},
	{
	  themeName:'theme-12',
	  colorName:'$mat-light-green',
	  primaryIndex:'500',
	  primaryHex:'##8BC34A'
	},
	{
	  themeName:'theme-13',
	  colorName:'$mat-lime',
	  primaryIndex:'500',
	  primaryHex:'##CDDC39'
	},
	{
	  themeName:'theme-14',
	  colorName:'$mat-yellow',
	  primaryIndex:'500',
	  primaryHex:'##FFEB3B'
	},
	{
	  themeName:'theme-15',
	  colorName:'$mat-amber',
	  primaryIndex:'500',
	  primaryHex:'##FFC107'
	},
	{
	  themeName:'theme-16',
	  colorName:'$mat-orange',
	  primaryIndex:'500',
	  primaryHex:'##FF9800'
	},
	{
	  themeName:'theme-17',
	  colorName:'$mat-deep-orange',
	  primaryIndex:'500',
	  primaryHex:'##FF5722'
	},
	{
	  themeName:'theme-18',
	  colorName:'$mat-brown',
	  primaryIndex:'500',
	  primaryHex:'##795548'
	},
	{
	  themeName:'theme-19',
	  colorName:'$mat-gray',
	  primaryIndex:'500',
	  primaryHex:'##9E9E9E'
	}
  ];
  
  request.componentNameArray = ListToArray("authorCollection-get,autocompleteTagsCollection-get,categoryCollection-get,categoryMember-get,commentCollection-get,commentMember-delete,commentMember-get,commentMember-post,dateCollection-get,imageAdjacentMember-get,imageByCategoryCollection-get,imageByDateCollection-get,imageByTagCollection-get,imageByUseridCollection-get,imageCollection-get,imageMember-delete,imageMember-get,imageMember-post,imageMember-put,jwtMember-get,likeMember-get,likeMember-post,oauthMember-post,pageByCategoriesCollection-get,pageByDateCollection-get,pageByImageCollection-get,pageByImagesCollection-get,pageBySearchCollection-get,pageByTagCollection-get,pageByTitleCollection-get,pageCollection-get,searchCollection-get,tinymceArticleImageMember-delete,tinymceArticleImageMember-get,tinymceArticleImageMember-post,tokenMember-get,userMember-delete,userMember-get,userMember-post,userMember-put");
    
  local.themeObj = request.utils.createTheme(request.theme);
  
  request.requestMetaData = {
	authorCollection:{
	  get:{
		requestHeader:"userToken^string",
		body:""
	  }
	},
	autocompleteTagsCollection:{
	  get:{
		requestHeader:"userToken^string",
		body:""
	  }
	},
	categoryCollection:{
	  get:{
		requestHeader:"userToken^string",
		body:""
	  }
	},
	commentMember:{
	  post:{
		requestHeader:"fileUuid^string,userToken^string,Authorization^string^[ Bearer (API Token) ]",
		body:""
	  },
	  delete:{
		requestHeader:"userToken^string,Authorization^string^[ Bearer (API Token) ],X-HTTP-METHOD-OVERRIDE^string^[ 'DELETE' [use POST in Curl method] ]",
		body:""
	  }
	},
	dateCollection:{
	  get:{
		requestHeader:"userToken^string",
		body:""
	  }
	},
	imageAdjacentMember:{
	  get:{
		requestHeader:"userToken^string",
		body:""
	  }
	},
	imageApprovedByUseridCollection:{
	  get:{
		requestHeader:"userToken^string",
		body:""
	  }
	},
	imageByCategoryCollection:{
	  get:{
		requestHeader:"userToken^string",
		body:""
	  }
	},
	imageByDateCollection:{
	  get:{
		requestHeader:"userToken^string",
		body:""
	  }
	},
	imageByTagCollection:{
	  get:{
		requestHeader:"userToken^string",
		body:""
	  }
	},
	imageByUseridCollection:{
	  get:{
		requestHeader:"userToken^string",
		body:""
	  }
	},
	imageCollection:{
	  get:{
		requestHeader:"userToken^string",
		body:""
	  }
	},
	imageMember:{
	  get:{
		requestHeader:"userToken^string",
		body:""
	  },
	  post:{
		requestHeader:"file-name^string,image-path^string,name^string,title^string,description^string,article^json^[ string ],tags^json^[ array [{display:'value'&comma;value:'value'}] ],publish-article-date^date^[ yyyy-mm-ddThh:mm:ss ],tinymce-article-deleted-images^array^[ ['File_ID/filename'] ],file-extension^string,user-token^string,cfid^string,cftoken^string,upload-type^string^[ 'gallery' || 'avatar' ],Content-Type^string^[ 'image/jpeg' || 'image/png' || 'image/gif' ],Authorization^string^[ Bearer (API Token) ]",
		body:"^binary"
	  },
	  put:{
		requestHeader:"image-path^string,name^string,title^string,description^string,tags^json^[ array [{display:'value'&comma;value:'value'}] ],publish-article-date^date^[ yyyy-mm-ddThh:mm:ss ],tinymce-article-deleted-images^array^[ ['File_ID/filename'] ],submitArticleNotification^tinyInt,Content-Type^string^[ 'application/json' ],userToken^string,Authorization^string^[ Bearer (API Token) ],X-HTTP-METHOD-OVERRIDE^string^[ 'PUT' [use POST in Curl method] ]",
		body:"article^binary^[ json ]"
	  },
	  delete:{
		requestHeader:"userToken^string,Authorization^string^[ Bearer (API Token) ],X-HTTP-METHOD-OVERRIDE^string^[ 'DELETE' [use POST in Curl method] ]",
		body:""
	  }
	},
	imageUnapprovedCollection:{
	  get:{
		requestHeader:"userToken^string",
		body:""
	  }
	},
	imageApprovedCollection:{
	  get:{
		requestHeader:"userToken^string",
		body:""
	  }
	},
	jwtMember:{
	  get:{
		requestHeader:"Authorization^string^[ Bearer (API Token) ]",
		body:""
	  }
	},
	likeMember:{
	  post:{
		requestHeader:"userToken^string,Authorization^string^[ Bearer (API Token) ]",
		body:""
	  }
	},
	oauthMember:{
	  post:{
		requestHeader:"email^string,password^string,commentToken^string,theme^string^[ ['#local.themeObj['dark']#'&comma;'#local.themeObj['light']#'] ]",
		body:""
	  }
	},
	pageBySearchCollection:{
	  get:{
		requestHeader:"term^string",
		body:""
	  }
	},
	pageByTagCollection:{
	  get:{
		requestHeader:"userToken^string",
		body:""
	  }
	},
	pageByTitleCollection:{
	  get:{
		requestHeader:"userToken^string",
		body:""
	  }
	},
	pageCollection:{
	  get:{
		requestHeader:"userToken^string",
		body:""
	  }
	},
	searchCollection:{
	  get:{
		requestHeader:"term^string,userToken^string",
		body:""
	  }
	},
	themeMember:{
	  put:{
		requestHeader:"theme^string^[ ['#local.themeObj['dark']#'&comma;'#local.themeObj['light']#'] ],X-HTTP-METHOD-OVERRIDE^string^[ 'PUT' [use POST in Curl method] ]",
		body:""
	  }
	},
	tinymceArticleImageMember:{
	  get:{
		requestHeader:"userToken^string",
		body:""
	  },
	  post:{
		requestHeader:"filename^string,userToken^string,Authorization^string^[ Bearer (API Token) ]",
		body:""
	  },
	  delete:{
		requestHeader:"filename^string,userToken^string,Authorization^string^[ Bearer (API Token) ],X-HTTP-METHOD-OVERRIDE^string^[ 'DELETE' [use POST in Curl method] ]",
		body:""
	  }
	},
	userMember:{
	  post:{
		requestHeader:"forename^string,surname^string,email^string,password^string,cfid^string,cftoken^string,testEmail^boolean,cookieAcceptance^tinyInt",
		body:""
	  },
	  put:{
		requestHeader:"forename^string,surname^string,password^string,emailNotification^tinyInt,theme^string^[ ['#local.themeObj['dark']#'&comma;'#local.themeObj['light']#'] ],userid^integer,Authorization^string^[ Bearer (API Token) ],X-HTTP-METHOD-OVERRIDE^string^[ 'PUT' [use POST in Curl method] ]",
		body:""
	  },
	  delete:{
		requestHeader:"userid^integer,Authorization^string^[ Bearer (API Token) ],X-HTTP-METHOD-OVERRIDE^string^[ 'DELETE' [use POST in Curl method] ]",
		body:""
	  }
	}
  };
	  
  local.queryObj = new Query();	 
  local.queryObj.setDatasource(request.domain_dsn);
  local.queryObj = queryObj.execute(sql="SELECT * FROM tblProfanity WHERE Title NOT REGEXP '[[:punct:]]+'");
  local.queryObj = local.queryObj.getResult();
  request.profanityList = "";
  if(local.queryObj.RecordCount) {
	request.profanityList = ListChangeDelims(ValueList(local.queryObj.Title),'|');
  }
  
  if(REFindNoCase("/debug.cfm",CGI.SCRIPT_NAME)){
	if(NOT isLocalhost(CGI.REMOTE_ADDR)){
	  if(NOT ISDEFINED("url.appReload") OR (ISDEFINED("url.appReload") AND url.appReload NEQ request.appreloadkey)){
		cflocation(url="index.cfm",addtoken="no");
	  }
	}
  }
  

</cfscript>