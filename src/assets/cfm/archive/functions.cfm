<cfscript>


  public query function ParseDirectory(required string path, string type = "dir") output="true" {
	  
	var local = {};
	
	var aQuery = "";
	  		
	cfdirectory(action="list",directory=arguments.path,name="local.query1",sort="Directory, Name ASC",type=arguments.type,recurse="yes");

	local.queryService = new query();
	local.queryService.setDBType("query");
	local.queryService.setAttributes(sourceQuery=local.query1);
	local.objQueryResult = local.queryService.execute(sql="SELECT Directory, Name FROM sourceQuery");
	local.queryResult1 = local.objQueryResult.getResult();
	
	local.query2 = QueryNew("Id,ParentId,Directory,Name,GroupId");	
	
	if(local.queryResult1.RecordCount){
	  for(local.row in local.queryResult1){
		QueryAddRow(local.query2);
		QuerySetCell(local.query2,"Id",local.queryResult1.CurrentRow);
		QuerySetCell(local.query2,"ParentId","");
		QuerySetCell(local.query2,"Directory",local.row.Directory);
		QuerySetCell(local.query2,"Name",local.row.Name);
		QuerySetCell(local.query2,"GroupId","");
	  }
	}
	
	local.queryService = new query();
	local.queryService.setDBType("query");
	local.queryService.setAttributes(sourceQuery=local.query2);
	local.objQueryResult = local.queryService.execute(sql="SELECT * FROM sourceQuery");
	local.queryResult2 = local.objQueryResult.getResult();
	
	local.maxid = local.query2.RecordCount + 1;
		
	local.parentDirectories = ListRemoveDuplicates(ValueList(local.queryResult2.Directory),",",true);
	
	for(local.item in ListToArray(local.parentDirectories)){
	  local.queryService = new query();
	  local.queryService.setDBType("query");
	  local.queryService.setAttributes(sourceQuery=local.query2);
	  local.queryService.addParam(name="Directory",value=local.item,cfsqltype="cf_sql_varchar"); 
	  local.objQueryResult = local.queryService.execute(sql="SELECT * FROM sourceQuery WHERE Directory = :Directory");
	  local.queryResult3 = local.objQueryResult.getResult();
	  if(local.queryResult3.RecordCount){
		QueryAddRow(local.query2); 
		QuerySetCell(local.query2,"Id",local.maxid);
		QuerySetCell(local.query2,"ParentId",0);
		QuerySetCell(local.query2,"Directory",local.queryResult3.Directory);
		QuerySetCell(local.query2,"Name","");
		QuerySetCell(local.query2,"GroupId",0);
		local.maxid = maxid + 1;
	  }
	}
		
	local.queryService = new query();
	local.queryService.setDBType("query");
	local.queryService.setAttributes(sourceQuery=local.query2);
	local.queryService.addParam(name="ParentId",value=0,cfsqltype="cf_sql_varchar"); 
	local.objQueryResult = local.queryService.execute(sql="SELECT * FROM sourceQuery WHERE ParentId = :ParentId");
	local.queryResult4 = local.objQueryResult.getResult();
	
	if(local.queryResult4.RecordCount){
	  for(local.rowParent in local.queryResult4){
		for(local.rowChild in local.query2){
		  if(CompareNoCase(local.rowParent.Directory,local.rowChild.Directory) EQ 0 AND local.rowChild.ParentId NEQ 0){
			local.query2['ParentId'][local.query2.CurrentRow] = local.rowParent.Id;
			local.query2['GroupId'][local.query2.CurrentRow] = local.rowParent.Id;
		  }
		}
	  }
	  for(local.rowParent in local.queryResult4){
		for(local.rowChild in local.query2){
		  if(CompareNoCase(local.rowParent.Directory,local.rowChild.Directory) EQ 0 AND local.rowChild.ParentId EQ 0){
			local.query2['GroupId'][local.query2.CurrentRow] = local.rowParent.Id;
		  }
		}
	  }
	  
	}
		
	return local.query2;
	
  }


  public any function ConvertDirectoryQueryToArray(required query query, numeric parentId = 0, array directories = ArrayNew(1), array nestedDirectories = ArrayNew(1), string parents = "") output="true" { 
  
	var local = {};
	
	var aQuery = "";
		
	local.directories = arguments.directories;
	local.nestedDirectories = arguments.nestedDirectories;
	local.parents = arguments.parents;
	
	local.queryService = new query();
	local.queryService.setName("aQuery");
	local.queryService.setDBType("query");
	local.queryService.setAttributes(sourceQuery=arguments.query);
	local.objQueryResult = local.queryService.execute(sql="SELECT * FROM sourceQuery WHERE ParentId=0");
	local.queryResult = local.objQueryResult.getResult();
	
	if(NOT Len(Trim(local.parents))){
	  local.queryService = new query();
	  local.queryService.setName("aQuery");
	  local.queryService.setDBType("query");
	  local.queryService.setAttributes(sourceQuery=arguments.query);
	  local.objQueryResult = local.queryService.execute(sql="SELECT * FROM sourceQuery WHERE ParentId=0");
	  local.queryResult = local.objQueryResult.getResult();
	  if(local.queryResult.RecordCount){
		for(local.row in local.queryResult){
		  local.directory = Trim(ReplaceNoCase(local.row.Directory & "\" & local.row.Name,request.filepath,""));
		  local.directory = REReplaceNoCase(local.directory,"(.*)\\[\s]*$","\1","ALL");
		  local.parents = ListAppend(local.parents,local.directory);
		}
	  }
	}
	
	local.queryService = new query();
	local.queryService.setName("aQuery");
	local.queryService.setDBType("query");
	local.queryService.setAttributes(sourceQuery=arguments.query);
	local.objQueryResult = local.queryService.execute(sql="SELECT * FROM sourceQuery WHERE ParentId=#arguments.parentId#");
	local.queryResult = local.objQueryResult.getResult();
	
	if(local.queryResult.RecordCount){
	  for(local.row in local.queryResult){
		local.directory = Trim(ReplaceNoCase(local.row.Directory & "\" & local.row.Name,request.filepath,""));
		local.directory = REReplaceNoCase(local.directory,"(.*)\\[\s]*$","\1","ALL");
		if(NOT Len(Trim(local.row.Name))){
		  ArrayAppend(local.directories,local.directory);
		  local.nestedDirectories = ArrayNew(1);
		}
		else{
			if(NOT ListFindNoCase(local.parents,local.directory)){
			  ArrayAppend(local.nestedDirectories,local.directory);
			  ArrayAppend(local.directories,local.nestedDirectories);
			}
		}
		local.directories = ConvertDirectoryQueryToArray(query=arguments.query,parentId=local.row.Id,directories=local.directories,nestedDirectories=local.nestedDirectories,parents=local.parents);
	  }
	}
	
	return local.directories;

  }
  
  
  public any function CleanArray(array directories = ArrayNew(1), boolean formatWithKeys = false) output="true" {
	  
	  var local = {};
	  
	  local.directories = arguments.directories;
	  
	  local.temp = Duplicate(local.directories);
	  local.index = 1;
	
	  for (local.index=1;local.index LTE ArrayLen(local.directories);local.index=local.index+1) {
		if(IsArray(local.directories[local.index]) AND ArrayIsDefined(local.directories,local.index + 1) AND IsArray(local.directories[local.index + 1])){
		  ArrayDelete(local.temp,local.directories[local.index]);
		}
	  }
	  
	  local.directories = local.temp;
	  
	  if(arguments.formatWithKeys){
		
		local.temp = ArrayNew(1);
		for (local.index=1;local.index LTE ArrayLen(local.directories);local.index=local.index+1) {
		  
		  if(IsSimpleValue(local.directories[local.index]) AND ArrayIsDefined(local.directories,local.index + 1) AND IsArray(local.directories[local.index + 1])){
			local.struct = {};
			StructInsert(local.struct,local.directories[local.index],local.directories[local.index + 1]);
			ArrayAppend(local.temp,local.struct);
		  }
		  
		}
		local.directories = local.temp;
		
	  }
	  else{
		
		local.array = ArrayNew(1);
		  
		for (local.index=1;local.index LTE ArrayLen(local.directories);local.index=local.index+1) {
		  
		  if(IsSimpleValue(local.directories[local.index]) AND ArrayIsDefined(local.directories,local.index + 1) AND IsArray(local.directories[local.index + 1])){
			local.temp = ArrayNew(1);
			ArrayAppend(local.temp,local.directories[local.index]);
			ArrayAppend(local.temp,local.directories[local.index + 1]);
			ArrayAppend(local.array,local.temp);
		  }
		  
		}
		
		local.directories = local.array;
		
	  }
	  
	  return local.directories;
  }
  
  
  public string function CapFirst(string str = "") output="true" {
	var local = {};
	if(Len(arguments.str) GT 1){
	  /*WriteOutput(arguments.str & "<br />");*/
	  local.string = Trim(UCase(Left(arguments.str,1)) & LCase(Right(arguments.str,Len(arguments.str)-1)));
	}
	else{
	  local.string = Trim(UCase(Left(arguments.str,1)));
	}
	return local.string;
  }
  
  public string function CapFirstSentence(string str = "", boolean all = false) output="true" {
	var local = {};
	if(NOT arguments.all) {
	  if(Len(arguments.str) GT 1){
		local.string = Trim(UCase(Left(arguments.str,1)) & Right(arguments.str,Len(arguments.str)-1));
	  }
	  else{
		local.string = Trim(UCase(Left(arguments.str,1)));
	  }
	}
	else{
		local.string = "";
		local.stringFixer = arguments.str;
		local.stringFixerBreaker = REMatchNoCase('\w.+?[.?!]+|\w.+$',local.stringFixer);
		if(ArrayLen(local.stringFixerBreaker)){
			for (local.index=1;local.index LTE ArrayLen(local.stringFixerBreaker);local.index=local.index+1) {
				local.sentence = local.stringFixerBreaker[local.index];
				local.string = local.string & ReplaceNoCase(local.sentence,Left(local.sentence,1),UCase(Left(local.sentence,1))) & " ";
			}
		}
	}
	return local.string;
  }
  
  
  public string function CapFirstAll(string str = "") output="true" {
	  
	var local = {};
	local.string = "";
	
	for(local.i = 1; local.i LTE ListLen(arguments.str," "); local.i = local.i + 1){
	  local.item = ListGetAt(arguments.str,local.i," ");
	  local.string = local.string & " " & CapFirst(local.item);
	}
	
	return local.string;
	
  }
  
  
  public string function FormatTitle(string str = "") output="true" {
	  
	var local = {};
	local.wordlist = "a,amid,an,and,anti,as,at,but,by,down,for,from,in,into,like,near,nor,of,off,on,onto,or,over,past,per,plus,so,than,the,to,up,upon,via,with,yet";
	local.wordlist = "a,aboard,about,above,across,after,against,ahead,along,amid,amidst,among,and,around,as,aside,at,athwart,atop,barring,because,before,behind,below,beneath,beside,besides,between,beyond,but,by,circa,concerning,despite,down,during,except,excluding,far,following,for,from,in,including,inside,into,like,minus,near,nor,notwithstanding,of,off,on,onto,opposite,or,out,outside,over,past,per,plus,prior,regarding,regardless,save,since,so,than,the,through,till,to,toward,towards,under,underneath,unlike,until,up,upon,versus,via,with,within,without,yet";
	
	local.string = CapFirstAll((Trim(arguments.str)));
	local.string = REReplaceNoCase(local.string,"[\s]+"," ","ALL");
	
	for(local.i = 1; local.i LTE ListLen(local.wordlist); local.i = local.i + 1){
	  local.string = ReplaceNoCase(local.string," " & ListGetAt(local.wordlist,local.i) & " "," " & ListGetAt(local.wordlist,local.i) & " ","ALL");
	}
		
	if(ListLen(local.string," ")){
	  local.string = ListSetAt(local.string,ListLen(local.string," "),CapFirst(ListGetAt(local.string,ListLen(local.string," ")," "))," ");
	  local.string = ListSetAt(local.string,1,CapFirst(ListGetAt(local.string,1," "))," ");
	}
	
	return local.string;
	
  }
  
  
  public string function Encrypts(string string = "", string key = request.crptographykey, string algorithm = request.crptographyalgorithm, string encoding = request.crptographyencoding) output="false" {
	  var result = "";
	  if(arguments.string NEQ "" AND arguments.key NEQ "") {
        try{
          result = Encrypt(arguments.string,arguments.key,arguments.algorithm,arguments.encoding);
		}
		catch( any e ) {
		}
	  }
    return result;
  }

	
  public string function Hashed(string string = "", any object = "") output="false" {
	var result = "";
	if(arguments.string NEQ "") {
	  if(ISOBJECT(arguments.object)) {
		try{
		  result = arguments.object.hashpw(arguments.string,arguments.object.gensalt());
		}
		catch( any e ) {
		}
	  }
	}
	return result;
  }

	
  public boolean function HashMatched(string string = "", string hashed = "", any object = "") output="false" {
	var result = false;
	if(arguments.string NEQ "" AND arguments.hashed NEQ "") {
	  if(ISOBJECT(arguments.object)) {
		try{
		  result = arguments.object.checkpw(arguments.string,arguments.hashed);
		  if(CompareNoCase(result,"Yes") EQ 0 || (IsBoolean(result) AND result)){
			result = true;
		  }
		  else{
			result = false;
		  }
		}
		catch( any e ) {
		}
	  }
	}
	return result;
  }
  
  public string function TagsToList(string string = "") output="false" {
	var result = "";
	var local = {};
	local.tags = arguments.string;
	local.tagList = "";
    if(Len(Trim(local.tags)) AND IsJSON(local.tags)){
	  local.tagArray = DeserializeJSON(arguments.string);
      if(IsArray(local.tagArray)){
		for (local.index=1;local.index LTE ArrayLen(local.tagArray);local.index=local.index+1) {
		  if(IsStruct(local.tagArray[local.index]) AND NOT StructIsEmpty(local.tagArray[local.index]) AND StructKeyExists(local.tagArray[local.index],"value")){
            local.tagList = ListAppend(local.tagList,local.tagArray[local.index]['value']);
		  }
		}
	  }
	}
	result = local.tagList;
	return result;
  }
  
  public array function TagsSort(array array = []) output="false" {
	var result = arguments.array;
	var local = {};
	ArraySort(arguments.array, function(a,b) {
	  return compare(a.value, b.value);
	});
	return arguments.array;
  }
  
  public string function FormatTags(string string = "") output="false" {
	var result = "";
	var local = {};
	if(Len(Trim(arguments.string)) AND IsJSON(arguments.string)){
	  local.tags = DeserializeJson(arguments.string);
	  if(IsArray(tags)){
		local.tags = TagsSort(local.tags);
		local.tags = SerializeJson(local.tags);
		local.tags = Trim(LCase(local.tags));
		local.tags = REReplaceNoCase(local.tags,"[\s]+","","ALL");
	  }
	  result = local.tags;
	}
	return result;
  }
  
  public string function FormatCommentIn(string string = "") output="false" {
	var result = arguments.string;
	var local = {};
	if(Len(Trim(arguments.string))){
	  arguments.string = REReplaceNoCase(arguments.string,"<[^>]*>","","ALL");
	  result = arguments.string;
	}
	return result;
  }
  
  public string function FormatCommentOut(string string = "") output="false" {
	var result = arguments.string;
	var local = {};
	if(Len(Trim(arguments.string))){
	  arguments.string = REReplaceNoCase(arguments.string,"\n","<br />","ALL");
	  result = arguments.string;
	}
	return result;
  }
  
   public string function FormatTextForDatabase(string string = "", string texttype = "html", string tags = "html", boolean trimalltags = true, boolean addscripttag = true) output="false" {
	 var result = arguments.string;
	 var htmltaglist = arguments.tags;
	 var i = "";
	 if(FindNoCase("html",arguments.texttype)){
	  result = REReplace(result,"[[:space:]]{2,}"," ","all");
      result = REReplace(result,"(>)[\s]+(<)","\1\2","ALL");
      if(htmltaglist NEQ ""){
		for (i in ListToArray(htmltaglist, ",")) { 
          result = REReplace(result,"(<#i#[^>]*>)[\s]+\b","\1","ALL");
          result = REReplace(result,"\b([\.\?\!\:]*)[\s]+(</#i#>)","\1\2","ALL");
		}
	  }
      else{
        if(arguments.trimalltags){
          result = REReplace(result,"(<[A-Za-z][^>]*>)[\s]+\b","\1","ALL");
          result = REReplace(result,"\b([\.\?\!\:]*)[\s]+(</[^>]*>)","\1\2","ALL");
		}
	  }
	}
	else if(FindNoCase("css",arguments.texttype)){
	  result = REReplace(result,"[\t\n\f\r]+","","ALL");
      result = REReplace(result,"([{|}])[\s]+\b","\1","ALL");
	  result = REReplace(result,"\b[\s]+([{|}])","\1","ALL");
      result = REReplace(result,"(;)[\s]+(})","\1\2","ALL");
      result = REReplace(result,"(;)[\s]+\b","\1","ALL");
      result = REReplace(result,"(})[\s]+(\.)","\1\2","ALL");
      result = REReplace(result,"(})[\s]+(##)","\1\2","ALL");
      result = REReplace(result,"({)[\s]+(})","\1\2","ALL");
	}
	else if(FindNoCase("script",arguments.texttype)){
	  result = Trim(result);
	  result = REReplaceNoCase(result,'<[^>]*>','',"ALL");
      result = Trim(result);
      result = REReplace(result,"[\t\n\f\r]+","","ALL");
      result = REReplace(result,"\b[\s]+([[:punct:]])","\1","ALL");
      result = REReplace(result,"([[:punct:]])[\s]+\b","\1","ALL");
      result = REReplace(result,"([[:punct:]])[\s]+([[:punct:]])","\1\2","ALL");
      if(arguments.addscripttag){
		result = REReplaceNoCase(result,'(.*)','<script>\1</script>',"ALL");
	  }
    }
	 result = Trim(result);
	 return result;
   }
   
   public date function CreateDateTimeFromMomentDate(string string = "") output="false" {
	var result = Now();
	var local = {};
	if(Len(Trim(arguments.string))){
	  arguments.string = REReplaceNoCase(arguments.string,"(.*)T.*","\1","ALL");
	  if(ListLen(arguments.string,"-") EQ 3){
		 local.year = ListGetAt(arguments.string,1,"-");
		 local.month = ListGetAt(arguments.string,2,"-");
		 local.day = ListGetAt(arguments.string,3,"-");
		 if(ISNUMERIC(local.year) AND local.year GTE Year(Now()) AND ISNUMERIC(local.month) AND local.month LTE 12 AND ISNUMERIC(local.day) AND local.day LTE DaysInMonth(CreateDate(local.year,local.month,1))){
		 	result = CreateDateTime(local.year,local.month,local.day,Hour(Now()),Minute(Now()),Second(Now()));
			if(NOT ISDATE(result)){
			  result = Now();
			}
		 }
	  }
	}
	return result;
  }
  
  public void function RemoveTinymceArticleImage(array array = "") output="false" {
	var local = {};
	if(ArrayLen(arguments.array)){
	  for (local.index=1;local.index LTE ArrayLen(arguments.array);local.index=local.index+1) {
		local.source = request.filepath & "\article-images\" & Trim(arguments.array[local.index]);
		//writeDump(var=local.source); 
		if(FileExists(local.source)){
		  local.timestamp = DateFormat(Now(),'yyyymmdd') & TimeFormat(Now(),'HHmmss');
		  lock name="delete_file_#local.timestamp#" type="exclusive" timeout="30" { 
			FileDelete(local.source);
		  }
		}
	  }
	}
  }
  
  public array function TinymceArticleImages(string html = "") output="false" {
	var local = {};
	local.document = arguments.html;
	local.regex = "<img\s+[^>]*?src=(#chr(34)#|#Chr(39)#)([^#Chr(39)##chr(34)#]+)";
	local.matcher = createObject("component","components.PatternMatcher").init(local.regex,local.document);
	local.documentFilenameArray = ArrayNew(1);
	while(local.matcher.find()){
	  local.src = local.matcher.group(2);
	  local.filename = ListLast(local.src,"/");
	  ArrayAppend(local.documentFilenameArray,local.filename);
	}
	return local.documentFilenameArray;
  }
  
  public void function RemoveTinymceArticleOrphanImage(string html = "", numeric fileid = 0) output="false" {
	var local = {};
	local.document = arguments.html;
	local.documentFilenameArray = TinymceArticleImages(local.document);
	local.orphanFilenameArray = ArrayNew(1);
	if(DirectoryExists(request.filepath & "\article-images\" & arguments.fileid)) {
	  local.query = DirectoryList(request.filepath & "\article-images\" & arguments.fileid,false,"query","*.png|*.gif|*.jpg|*.jpeg","asc");
	  if(local.query.RecordCount){
		for(local.row in local.query){ 
		  if(NOT ArrayFindNoCase(local.documentFilenameArray,local.row.Name)){
			ArrayAppend(local.orphanFilenameArray,local.row.Name);
		  }
		}
	  }
	}
	if(ArrayLen(local.orphanFilenameArray)){
	  for(local.i = 1;local.i <= ArrayLen(local.orphanFilenameArray);local.i++){
		if(Len(Trim(local.orphanFilenameArray[local.i]))){
		  local.source = request.filepath & "\article-images\" & arguments.fileid & "\" & local.orphanFilenameArray[local.i];
		  if(FileExists(local.source)){
			local.timestamp = DateFormat(Now(),'yyyymmdd') & TimeFormat(Now(),'HHmmss');
			lock name="delete_file_#local.timestamp#" type="exclusive" timeout="30" {
			  FileDelete(local.source);
			}
		  }
		}
	  }
	}
  }
  
  
  public string function EncryptJwt(string usertoken = "", string jwtid = "", struct data = {}) output="true" {
	var local = {};
	local.jwtString = "";
	local.sub = request.title;
	if(StructKeyExists(arguments.data,"forename") AND Len(Trim(arguments.data['forename'])) AND StructKeyExists(arguments.data,"surname") AND Len(Trim(arguments.data['surname']))){
	  local.sub = CapFirst(arguments.data['forename']) & " " & CapFirst(arguments.data['surname']);
	}
	local.claimset = {iss=request.absoluteBaseUrl,sub=local.sub,aud=request.absoluteBaseUrl,exp=DateAdd("s",(1000 * 60 * request.jwtexpiryminutes),Now()),nbf=Now(),iat=Now(),jti=arguments.jwtid,claim={json=SerializeJson({userToken=arguments.usertoken})}};
	local.JwtSignEncrypt = request.encrypter.init(claimSet=local.claimset,javaLoaderClassPath="",jarSystemPath="",useJavaLoader=true,javaLoaderInstance=request.jwtjavaloader);
	//writeDump(var=local.JwtSignEncrypt);
	local.secretKeyEncoded = local.JwtSignEncrypt.GetSecretKeyEncoded();
	local.jwtString = local.JwtSignEncrypt.Encrypt(secretKeyEncoded=local.secretKeyEncoded);
    if(Len(Trim(local.jwtString)) AND IsBinary(local.secretKeyEncoded)){
	  local.queryObj = new query();
	  local.queryObj.setDatasource(request.domain_dsn);
	  local.queryObj.addParam(name="Secret_key",value=local.secretKeyEncoded,cfsqltype="cf_sql_blob"); 
	  local.queryObj.addParam(name="Jwt_ID",value=arguments.jwtid,cfsqltype="cf_sql_varchar");
	  local.queryObj.addParam(name="User_token",value=arguments.usertoken,cfsqltype="cf_sql_varchar");
	  local.queryObj = local.queryObj.execute(sql="UPDATE tblUserToken SET Secret_key = :Secret_key, Jwt_ID = :Jwt_ID  WHERE User_token = :User_token");
	}
	return local.jwtString;
  }
  
  public struct function DecryptJwt(string usertoken = "", string jwtString = "", boolean refreshExpiredToken = false) output="false" {
	var local = {};
	local.data = {};
	local.data['jwtAuthenticated'] = false;
	local.data['jwtError'] = "";
	local.data['userToken'] = "";
	local.jwtString = arguments.jwtString;
	local.JwtSignEncrypt = request.encrypter.init(javaLoaderClassPath="",jarSystemPath="",useJavaLoader=true,javaLoaderInstance=request.jwtjavaloader);
    if(Len(Trim(local.jwtString))){
	  local.queryObj = new query();
	  local.queryObj.setDatasource(request.domain_dsn);
	  local.queryObj.addParam(name="User_token",value=arguments.usertoken,cfsqltype="cf_sql_varchar");
	  local.queryObj = local.queryObj.execute(sql="SELECT * FROM tblUserToken WHERE User_token = :User_token");
	  local.queryObj = local.queryObj.getResult(); 
	  if(local.queryObj.RecordCount AND IsBinary(local.queryObj.Secret_key)) {
		local.decryptedJwtString = local.JwtSignEncrypt.Decrypt(jwtString=local.jwtString,secretKeyEncoded=local.queryObj.Secret_key);
        if(IsStruct(local.decryptedJwtString) AND StructkeyExists(local.decryptedJwtString,"jti") AND StructkeyExists(local.decryptedJwtString,"json") AND IsJson(local.decryptedJwtString['json'])){
		  local.obj = DeserializeJson(local.decryptedJwtString['json']);
          local.usertoken = "";
          if(StructkeyExists(local.obj,"usertoken")){
			local.usertoken = local.obj['usertoken'];
		  }
          if(CompareNocase(local.usertoken,local.queryObj.User_token) EQ 0 AND CompareNocase(local.decryptedJwtString['jti'],local.queryObj.Jwt_ID) EQ 0){
			local.data['jwtAuthenticated'] = true;
			local.data['userToken'] = local.usertoken;
		  }
		}
	  }
	}
	if(NOT local.data['jwtAuthenticated']){
	  local.data['jwtError'] = "User's JWT Token cannot be verified";
	}
	else{
	  if(local.JwtSignEncrypt.HasExpired()){
		if(NOT arguments.refreshExpiredToken){
		  local.data['jwtAuthenticated'] = false;
		  local.data['jwtError'] = "User's JWT Token has expired";
		}
		else{
		  local.jwtString = EncryptJwt(usertoken=arguments.usertoken,jwtid=local.queryObj.Jwt_ID);
		}
	  }
	}
	return local.data;
  }
  
  public string function GetJwtString(string string = "") output="false" {
	var local = {};
	local.string = REReplaceNoCase(Trim(arguments.string),"^[\s]*Bearer[\s]*","");
	return local.string;
  }
  
  public struct function TwitterCardRotator() output="true" {
	var local = {};
	local.result = {};
	local.timestamp = DateFormat(Now(),'yyyymmdd') & TimeFormat(Now(),'HHmmss');
	local.filename = "";
	local.filedirectory = "";
	local.filepath = "";
	local.filecontent = "";
	cflock (name="read_document_#local.timestamp#", type="readonly", timeout="30") {
	  local.document = FileRead(ExpandPath("../../") & "\index.html");
	}
	local.result['documentBefore'] = local.document;
	//WriteDump(var=local.document,abort=true);
	local.content = "";
	local.regex1 = ".*<meta\s+property\s*=\s*(#Chr(34)#|#Chr(39)#)og:image(#Chr(34)#|#Chr(39)#)\s+content=(#Chr(34)#|#Chr(39)#)([^#Chr(39)##Chr(34)#]+)[^>]*?.*";
	local.regex2 = "(.*<meta\s+property\s*=\s*(#Chr(34)#|#Chr(39)#)og:image(#Chr(34)#|#Chr(39)#)\s+content=(#Chr(34)#|#Chr(39)#))([^#Chr(39)##Chr(34)#]+)([^>]*?.*)";
	local.matcher = createObject("component","components.PatternMatcher").init(local.regex1,local.document);
	local.documentFilenameArray = ArrayNew(1);
	while(local.matcher.find()){
	  local.src = local.matcher.group(4);
	  local.filename = ListLast(local.src,"/"); 
	  ArrayAppend(local.documentFilenameArray,local.filename);
	}
	if(ArrayLen(local.documentFilenameArray)){
	  local.content = local.documentFilenameArray[1];
	}
	if(Len(Trim(local.content))){
	  local.currentFilename = local.content;
	  local.query = QueryNew("Name,Directory");
	  local.query1 = DirectoryList(request.filepath & "\categories\",true,"query","*.png|*.gif|*.jpg|*.jpeg","asc");
	  if(local.query1.RecordCount){
		for(local.row in local.query1){ 
		  QueryAddRow(local.query);
		  QuerySetCell(local.query,"Name",local.row.Name);
		  QuerySetCell(local.query,"Directory",local.row.Directory);
		}
	  }
	  local.query2 = DirectoryList(request.filepath & "\twitter-cards\",true,"query","*.png|*.gif|*.jpg|*.jpeg","asc");
	  if(local.query2.RecordCount){
		for(local.row in local.query2){ 
		  QueryAddRow(local.query);
		  QuerySetCell(local.query,"Name",local.row.Name);
		  QuerySetCell(local.query,"Directory",local.row.Directory);
		}
	  }
	  //WriteDump(var=local.query,abort=true);
	  if(local.query.RecordCount){
		local.rangeEnd = local.query.RecordCount;
		local.filename = "";
		while(local.filename == ""){
		  local.randomRow = RandRange(1,local.rangeEnd);
		  local.randomFilename = local.query['Name'][local.randomRow];
		  local.randomDirectory = local.query['Directory'][local.randomRow];
		  if(CompareNoCase(local.randomFilename,local.currentFilename) NEQ 0){
			local.filename = local.randomFilename;
			local.filedirectory = local.randomDirectory;
			local.filepath = local.filedirectory & "\" & local.filename;
		  }
		}
	  }
	  if(FileExists(local.filepath)){
		local.filecontenturi = REReplaceNoCase(local.filepath,".*(\\twitter-cards\\.*)","\1");
		if(REFindNoCase(".*(\\categories\\.*)",local.filepath)){
		  local.filecontenturi = REReplaceNoCase(local.filepath,".*(\\categories\\.*)","\1");
		}
		local.filecontenturi = REReplaceNoCase(local.filecontenturi,"[\\]+","/","ALL");
		local.filecontent = request.remoteuploadfolder & local.filecontenturi;
	  }
	}
	//WriteDump(var=local.filecontent,abort=true);
	if(Len(Trim(local.filecontent))){
	  local.document = REReplaceNoCase(local.document,local.regex2,"\1#local.filecontent#\6");
	  if(Len(Trim(local.document))){
		cflock (name="write_document_#local.timestamp#", type="exclusive", timeout="30") {
		  FileWrite(ExpandPath("../../") & "\index.html",local.document);
		}
		local.result['path'] = local.filepath;
		local.result['url'] = local.filecontent;
		local.result['documentAfter'] = local.document;
		cflock (name="twittercard", type="exclusive", timeout="30") {
		  application.twittercard = local.filecontent;
		}
		cfhttp(url=request.ngIframeSrc,method="get",result="local.ping");
		local.result['ping'] = local.ping;
	  }
	}
	return local.result;
  }
  
  public string function formatJSON(string str = "", boolean stripHTML = true) output="true" {
    var fjson = '';
    var pos = 0;
	var regex1 = ':"([^"]+)?.*';
	var regex2 = '.*(:"[{]+?.*[}]+?"|:"[[]+?.*[]]+?").*';
    var strLen = len(arguments.str);
    var indentStr = chr(9); // Adjust Indent Token If you Like
    var newLine = chr(10); // Adjust New Line Token If you Like <BR>
	var string =  '';
	var temp =  '';
	var prev = '';
	var prevprev = '';
	var char = '';
	var commaPosArr = [];
	var ignoreCommaPosArr = [];
	var ignoreSquareBracketPosArr = [];
	var ignoreBracesPosArr = [];
	var lastClose = '';
	var relPos = 1;
	var	absPos = 0;
	var openSquareBracket = 0;
	var closeSquareBracket = 0;
	var openBrace = 0;
	var closeBrace = 0;
	var relPosList =  '';
	if(arguments.stripHTML) {
	  arguments.str = REReplaceNoCase(arguments.str,'<[^>]*>','','ALL');
	}
    for (var i=1; i<strLen; i++) {
	  char = mid(arguments.str,i,1);
	  if(i == 1){
		if(char == '{'){
		  lastClose = '}';
		}
		else if (char == '['){
		  lastClose = ']';
		}
	  }
	  prev = '';
	  if(i != 1){
		prev = mid(arguments.str,i-1,1);
	  }
	  prevprev = '';
	  if(i > 2){
		prevprev = mid(arguments.str,i-2,1);
	  }
	  
	  if(prev == ':' AND char == '"'){
		string = mid(arguments.str,i-1,(strLen-(i+1)));
		string = REReplaceNoCase(string,regex1,'\1');
		temp = string;
		relPos = 1;
		absPos = 0;
		while(relPos != 0){
		  relPos = FindNoCase(',',temp);
		  temp = Mid(temp,relPos + 1,Len(temp)-relPos);
		  absPos += relPos;
		  ArrayAppend(ignoreCommaPosArr,i + absPos);
		}
	  }
	  
	  if(prevprev == ':' AND prev == '"' AND char == '['){
		string = mid(arguments.str,i-2,(strLen-(i+2)));
		string = REReplaceNoCase(string,regex2,'\1');
		//WriteDump(var=string);
		temp = string;
		relPos = 1;
		absPos = 0;
		while(relPos != 0){
		  relPosList = '' & FindNoCase('[',temp) & ',' & FindNoCase(']',temp) & ',' & FindNoCase('{',temp) & ',' & FindNoCase('}',temp) & ',' & FindNoCase(',',temp) & '';
		  relPos = ListSort(relPosList,"numeric","asc");
		  if(ListValueCount(relPos,0) NEQ ListLen(relPos)){
			relPos = ListFilter(relPos,function(num){
			   return num != 0;
			});
		  }
		  relPos = ListFirst(relPos);
		  temp = Mid(temp,relPos + 1,Len(temp)-relPos);
		  absPos += relPos;
		  ArrayAppend(ignoreSquareBracketPosArr,(i - 3) + absPos);
		}
		WriteDump(var=ignoreSquareBracketPosArr);
	  }

	  /*if(prevprev == ':' AND prev == '"' AND char == '{'){
		string = mid(arguments.str,i-1,(strLen-i));
		string = REReplaceNoCase(string,regex2,'\1');
		temp = string;
		relPos = 1;
		absPos = 0;
		while(relPos != 0){
		  relPos = FindNoCase('{',temp);
		  temp = Mid(temp,relPos + 1,Len(temp)-relPos);
		  absPos += relPos;
		  ArrayAppend(ignoreBracesPosArr,i + absPos);
		}
	  }*/
	  
	  //fjson &= '<span class="char-number">' & i & '</span>';
	  
	  
	  if ((char == '}' AND (NOT ArrayLen(ignoreSquareBracketPosArr) OR (ArrayLen(ignoreSquareBracketPosArr) AND !ArrayFind(ignoreSquareBracketPosArr,i)))) OR (char == ']' AND (NOT ArrayLen(ignoreSquareBracketPosArr) OR (ArrayLen(ignoreSquareBracketPosArr) AND !ArrayFind(ignoreSquareBracketPosArr,i)))) ) {
		fjson &= newLine;
		pos = pos - 1;
		for (var j=1; j<pos; j++) {
		  fjson &= indentStr;
		}
	  }
	  fjson &= char;    
	  if ((char == '{' AND (NOT ArrayLen(ignoreSquareBracketPosArr) OR (ArrayLen(ignoreSquareBracketPosArr) AND !ArrayFind(ignoreSquareBracketPosArr,i)))) OR (char == '[' AND (NOT ArrayLen(ignoreSquareBracketPosArr) OR (ArrayLen(ignoreSquareBracketPosArr) AND !ArrayFind(ignoreSquareBracketPosArr,i)))) || (char == ',' AND (NOT ArrayLen(ignoreCommaPosArr) OR (ArrayLen(ignoreCommaPosArr) AND !ArrayFind(ignoreCommaPosArr,i))) AND (NOT ArrayLen(ignoreSquareBracketPosArr) OR (ArrayLen(ignoreSquareBracketPosArr) AND !ArrayFind(ignoreSquareBracketPosArr,i))))   ) {
		ignoreCommaPosArr = [];
		ignoreSquareBracketPosArr = [];
		fjson &= newLine;
		if (char == '{' || char == '[') {
		  pos = pos + 1;
		}
		for (var k=1; k<pos; k++) {
		  fjson &= indentStr;
		}
	  }
    }
	if(lastClose != ''){
	  fjson &= newLine & lastClose;
	}
    return Trim(fjson);
  }
  
  
</cfscript>