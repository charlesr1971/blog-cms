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
	local.query2 = QueryNew("Id,ParentId,Directory,Name,GroupId,Empty");
	if(local.queryResult1.RecordCount){
	  for(local.row in local.queryResult1){
		QueryAddRow(local.query2);
		QuerySetCell(local.query2,"Id",local.queryResult1.CurrentRow);
		QuerySetCell(local.query2,"ParentId","");
		QuerySetCell(local.query2,"Directory",local.row.Directory);
		QuerySetCell(local.query2,"Name",local.row.Name);
		QuerySetCell(local.query2,"GroupId","");
		cfdirectory(action="list",directory=local.row.Directory & "\" & local.row.Name,name="local.query3",type="file",recurse="no");
		if(local.query3.RecordCount){
		  QuerySetCell(local.query2,"Empty",0);
		}
		else{
		  QuerySetCell(local.query2,"Empty",1);
		}
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
		QuerySetCell(local.query2,"Empty",1);
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
	local.queryService = new query();
	local.queryService.setDBType("query");
	local.queryService.setAttributes(sourceQuery=local.query2);
	local.queryService.addParam(name="ParentId",value=0,cfsqltype="cf_sql_varchar"); 
	local.objQueryResult = local.queryService.execute(sql="SELECT * FROM sourceQuery WHERE ParentId = :ParentId");
	local.queryResult5 = local.objQueryResult.getResult();
	if(local.queryResult5.RecordCount){
	  for(local.rowParent in local.queryResult5){
		local.queryService1 = new query();
		local.queryService1.setName("aQuery");
		local.queryService1.setDBType("query");
		local.queryService1.setAttributes(sourceQuery=local.query2);
		local.objQueryResult1 = local.queryService1.execute(sql="SELECT * FROM sourceQuery WHERE ParentId<>0 AND GroupId=#local.rowParent.GroupId# AND Empty=0");
		local.queryResult6 = local.objQueryResult1.getResult();
		if(local.queryResult6.RecordCount){
		  if(local.query2.RecordCount){
			for(local.rowChild in local.query2){
			  if(CompareNoCase(local.rowParent.Id,local.rowChild.Id) EQ 0){
				local.query2['Empty'][local.query2.CurrentRow] = 0;
				break;
			  }
			}
		  }
		}
		else{
		  if(local.query2.RecordCount){
			for(local.rowChild in local.query2){
			  if(CompareNoCase(local.rowParent.Id,local.rowChild.Id) EQ 0){
				local.query2['Empty'][local.query2.CurrentRow] = 1;
				break;
			  }
			}
		  }
		}		
	  }
	}
	if(local.query2.RecordCount){
	  for(local.rowChild in local.query2){
		if(CompareNoCase(ListLast(local.rowChild.Directory,"\"),"categories") EQ 0){
		  local.query2['Empty'][local.query2.CurrentRow] = 0;
		}
	  }
	}
	return local.query2;
  }


  public any function ConvertDirectoryQueryToArray(required query query, numeric parentId = 0, array directories = ArrayNew(1), array nestedDirectories = ArrayNew(1), string parents = "", boolean addEmptyFlag = false) output="true" { 
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
		if(arguments.addEmptyFlag){
		  local.directory = local.directory & "^" & local.row.Empty;
		}
		if(NOT Len(Trim(local.row.Name))){
		  ArrayAppend(local.directories,local.directory);
		  local.nestedDirectories = ArrayNew(1);
		}
		else{
		  if(NOT ListFindNoCase(local.parents,ListFirst(local.directory,"^"))){
			ArrayAppend(local.nestedDirectories,local.directory);
			ArrayAppend(local.directories,local.nestedDirectories);
		  }
		}
		local.directories = ConvertDirectoryQueryToArray(query=arguments.query,parentId=local.row.Id,directories=local.directories,nestedDirectories=local.nestedDirectories,parents=local.parents,addEmptyFlag=arguments.addEmptyFlag);
	  }
	}
	return local.directories;
  }
  
  
  public any function CleanArray(array directories = ArrayNew(1), boolean formatWithKeys = false, boolean flattenParentArray = false) output="true" {
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
	  if(arguments.flattenParentArray){
		local.categories = {};
		for (local.index=1;local.index LTE ArrayLen(local.directories);local.index=local.index+1) {
		  local.obj = local.directories[local.index];
		  for(local.key in local.obj){
			local.categories[local.key] = local.obj[local.key];
		  }
		}
		local.directories = local.categories;
	  }
	  return local.directories;
  }
  
  
  public any function UpdateCategories(struct currentObj = {}, struct newObj = {}, boolean addEmptyFlag = false, boolean formatWithKeys = false, boolean flattenParentArray = false) output="true" {
	var local = {};
	local.error = "";
	local.new = StructNew();
	local.timestamp = DateFormat(Now(),'yyyymmdd') & TimeFormat(Now(),'HHmmss');
	for(local.currentChild in arguments.currentObj) {
	  local.currentChildEmpty = ListLast(local.currentChild,"^"); 
	  local.currentChildOriginalPath = REReplaceNoCase(ListFirst(local.currentChild,"^"),"[\\]+","/","ALL");
	  if(StructKeyExists(arguments.newObj,"data") AND IsArray(arguments.newObj['data']) AND ArrayLen(arguments.newObj['data']) AND IsStruct(arguments.newObj['data'][1]) AND StructKeyExists(arguments.newObj['data'][1],"children") AND IsArray(arguments.newObj['data'][1]['children']) AND ArrayLen(arguments.newObj['data'][1]['children'])){
        local.new['categories'] = arguments.newObj['data'][1]['children'];
		for (local.newChild=1;local.newChild LTE ArrayLen(arguments.newObj['data'][1]['children']);local.newChild=local.newChild+1) {
		  local.childObj = arguments.newObj['data'][1]['children'][local.newChild];		  
		  if(StructKeyExists(local.childObj,"empty") AND StructKeyExists(local.childObj,"isDeleted") AND StructKeyExists(local.childObj,"item") AND StructKeyExists(local.childObj,"originalPath") AND StructKeyExists(local.childObj,"path")){
			local.newGrandChildren = ArrayNew(1);
			if(StructKeyExists(local.childObj,"children") AND IsArray(local.childObj['children'])){
			  local.newGrandChildren = local.childObj['children'];
			}
			local.newChildEmpty = local.childObj['empty'];
			local.newChildIsDeleted = LCase(local.childObj['isDeleted']) EQ 'yes' ? true : false;
			local.newChildCategory = local.childObj['item'];
			if(CompareNoCase(Trim(local.childObj['originalPath']),"[empty string]") EQ 0) {
			  local.childObj['originalPath'] = "";
			}
			local.newChildOriginalPath = REReplaceNoCase(ListFirst(local.childObj['originalPath'],"^"),"[//]+","/","ALL");
			local.newChildPath = REReplaceNoCase(ListFirst(local.childObj['path'],"^"),"[//]+","/","ALL");
			if(CompareNoCase(local.currentChildOriginalPath,local.newChildOriginalPath) EQ 0){
			  if(CompareNoCase(local.currentChildOriginalPath,local.newChildPath) NEQ 0){
				local.directoryName = request.filepath & REReplaceNoCase(local.currentChildOriginalPath,"[/]+","\","ALL");
				local.newDirectoryName = request.filepath & REReplaceNoCase(local.newChildPath,"[/]+","\","ALL");
				if(DirectoryExists(local.directoryName) AND NOT DirectoryExists(local.newDirectoryName)){
				  try{
					cflock (name="rename_directory_" & local.timestamp, type="exclusive", timeout="30") {
					  cfdirectory(action="rename",directory=local.directoryName,newdirectory=local.newDirectoryName);
					}
				  }
				  catch( any e ){
					local.error = e.message;
				  }
				}
			  }
			}
			if(NOT Len(Trim(local.newChildOriginalPath)) AND Len(Trim(local.newChildPath))){
			  local.directoryName1 = request.filepath & REReplaceNoCase(local.newChildPath,"[/]+","\","ALL");
			  if(NOT DirectoryExists(local.directoryName1)){
				try{
				  cflock (name="create_directory_" & local.timestamp, type="exclusive", timeout="30") {
					cfdirectory(action="create",directory=local.directoryName1);
				  }
				  local.directoryName2 = request.filepath & REReplaceNoCase(local.newChildPath,"[/]+","\","ALL") & "\miscellaneous";
				  if(DirectoryExists(local.directoryName1) AND NOT DirectoryExists(local.directoryName2)){
					cflock (name="create_directory_" & local.timestamp, type="exclusive", timeout="30") {
					  cfdirectory(action="create",directory=local.directoryName2);
					}
				  }
				}
				catch( any e ){
				  local.error = e.message;
				}
			  }
			}
			if(local.currentChildEmpty AND local.newChildIsDeleted AND local.newChildEmpty AND Len(Trim(local.newChildPath))){
			  local.directoryName = request.filepath & REReplaceNoCase(local.newChildPath,"[/]+","\","ALL");
			  if(DirectoryExists(local.directoryName)){
				//WriteOutput('<strong>DELETE: child: local.directoryName:</strong> ' & local.directoryName & '<br /><br />');
				/*try{
				  cflock (name="delete_directory_" & local.timestamp, type="exclusive", timeout="30") {
					cfdirectory(action="delete",directory=local.directoryName);
				  }
				}
				catch( any e ){
				  local.error = e.message;
				}*/
			  }
			}
			if(CompareNoCase(local.currentChildOriginalPath,local.newChildOriginalPath) EQ 0){
			  if(IsArray(arguments.currentObj[local.currentChild]) AND ArrayLen(arguments.currentObj[local.currentChild])){
				for (local.currentGrandChildIdx=1;local.currentGrandChildIdx LTE ArrayLen(arguments.currentObj[local.currentChild]);local.currentGrandChildIdx=local.currentGrandChildIdx+1) {
				  local.currentGrandChild = arguments.currentObj[local.currentChild][local.currentGrandChildIdx];
				  local.currentGrandChildEmpty = ListLast(local.currentGrandChild,"^");
				  local.currentGrandChildOriginalPath = REReplaceNoCase(ListFirst(local.currentGrandChild,"^"),"[\\]+","/","ALL");
				  if(IsArray(local.newGrandChildren)){
					for (local.newGrandChild=1;local.newGrandChild LTE ArrayLen(local.newGrandChildren);local.newGrandChild=local.newGrandChild+1) {
					  local.grandChildObj = local.newGrandChildren[local.newGrandChild];
					  if(IsStruct(local.grandChildObj) AND StructKeyExists(local.grandChildObj,"empty") AND StructKeyExists(local.grandChildObj,"isDeleted") AND StructKeyExists(local.grandChildObj,"item") AND StructKeyExists(local.grandChildObj,"originalPath") AND StructKeyExists(local.grandChildObj,"path")){
						local.newGrandChildEmpty = local.grandChildObj['empty'];
						local.newGrandChildIsDeleted = LCase(local.grandChildObj['isDeleted']) EQ 'yes' ? true : false;
						local.newGrandChildCategory = local.grandChildObj['item'];
						if(CompareNoCase(Trim(local.grandChildObj['originalPath']),"[empty string]") EQ 0) {
						  local.grandChildObj['originalPath'] = "";
						}
						local.newGrandChildOriginalPath = REReplaceNoCase(ListFirst(local.grandChildObj['originalPath'],"^"),"[//]+","/","ALL");
						local.newGrandChildPath = REReplaceNoCase(ListFirst(local.grandChildObj['path'],"^"),"[//]+","/","ALL");
						if(CompareNoCase(local.currentGrandChildOriginalPath,local.newGrandChildOriginalPath) EQ 0){
						  if(CompareNoCase(local.currentGrandChildOriginalPath,local.newGrandChildPath) NEQ 0){
							local.directoryName = request.filepath & REReplaceNoCase(local.currentGrandChildOriginalPath,"[/]+","\","ALL");
							local.newDirectoryName = request.filepath & REReplaceNoCase(local.newGrandChildPath,"[/]+","\","ALL");
							if(DirectoryExists(local.directoryName) AND NOT DirectoryExists(local.newDirectoryName)){
							  try{
								cflock (name="rename_directory_" & local.timestamp, type="exclusive", timeout="30") {
								  cfdirectory(action="rename",directory=local.directoryName,newdirectory=local.newDirectoryName);
								}
							  }
							  catch( any e ){
								local.error = e.message;
								WriteDump(var=local.error);
							  }
							}
							local.directoryName = request.filepath & REReplaceNoCase(local.newChildPath,"[/]+","\","ALL") & "\" & ListLast(local.currentGrandChildOriginalPath,"/");
							if(DirectoryExists(local.directoryName) AND NOT DirectoryExists(local.newDirectoryName)){
							  try{
								cflock (name="rename_directory_" & local.timestamp, type="exclusive", timeout="30") {
								  cfdirectory(action="rename",directory=local.directoryName,newdirectory=local.newDirectoryName);
								}
							  }
							  catch( any e ){
								local.error = e.message;
							  }
							}
						  }
						}
						if(NOT Len(Trim(local.newGrandChildOriginalPath)) AND Len(Trim(local.newGrandChildPath))){
						  local.directoryName = request.filepath & REReplaceNoCase(local.newGrandChildPath,"[/]+","\","ALL");
						  if(NOT DirectoryExists(local.directoryName)){
							try{
							  cflock (name="create_directory_" & local.timestamp, type="exclusive", timeout="30") {
								cfdirectory(action="create",directory=local.directoryName);
							  }
							}
							catch( any e ){
							  local.error = e.message;
							}
						  }
						}
						if(local.currentGrandChildEmpty AND local.newGrandChildIsDeleted AND local.newGrandChildEmpty AND Len(Trim(local.newGrandChildPath))){
						  local.directoryName = request.filepath & REReplaceNoCase(local.newGrandChildPath,"[/]+","\","ALL");
						  if(DirectoryExists(local.directoryName)){
							//WriteOutput('<strong>DELETE: grandchild: local.directoryName:</strong> ' & local.directoryName & '<br /><br />');
							/*try{
							  cflock (name="delete_directory_" & local.timestamp, type="exclusive", timeout="30") {
								cfdirectory(action="delete",directory=local.directoryName);
							  }
							}
							catch( any e ){
							  local.error = e.message;
							}*/
						  }
						}
					  }
					}
				  }
				}
			  }
			}
		  }
		}
	  }
	}
	if(NOT Len(Trim(local.error))){
	  local.qGetDirPlusId = ParseDirectory(path=request.filepath & "/categories");
	  local.directories = CleanArray(directories=ConvertDirectoryQueryToArray(query=local.qGetDirPlusId,addEmptyFlag=arguments.addEmptyFlag),formatWithKeys=arguments.formatWithKeys,flattenParentArray=arguments.flattenParentArray);
	}
	else{
	  local.directories = StructNew();
	  local.directories['error'] = local.error;
	}
	return local.directories;
  }
  
  
  public string function CapFirst(string str = "", boolean first = false) output="true" {
	var local = {};
	if(Len(arguments.str) GT 1){
	  if(arguments.first){
		local.string = Trim(UCase(Left(arguments.str,1)) & Right(arguments.str,Len(arguments.str)-1));
	  }
	  else{
		local.string = Trim(UCase(Left(arguments.str,1)) & LCase(Right(arguments.str,Len(arguments.str)-1)));
	  }
	}
	else{
	  local.string = Trim(UCase(Left(arguments.str,1)));
	}
	return Trim(local.string);
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
	return Trim(local.string);
  }
  
  
  public string function CapFirstAll(string str = "") output="true" {
	var local = {};
	local.string = "";
	for(local.i = 1; local.i LTE ListLen(arguments.str," "); local.i = local.i + 1){
	  local.item = ListGetAt(arguments.str,local.i," ");
	  local.string = local.string & " " & CapFirst(local.item);
	}
	return Trim(local.string);
  }
  
  public string function AbbreviateString(string inputString = "", numeric outputStringLength = 20, boolean ellipsis = true) output="true" {
	  var result = "";
	  var dots = "...";
	  var s = arguments.inputString;
	  var slength = Len(s);
	  var smaxlength = arguments.outputStringLength;
	  var sy = 0;
	  var rvs = "";
	  var rms = "";
	  if(slength GTE smaxlength){
		sy = slength - smaxlength;
		rvs = Reverse(s);
		rms = RemoveChars(rvs, 1, sy);
		if(arguments.ellipsis){
		  result = Reverse(rms) & dots;
		}
		else{
		  result = Reverse(rms);
		}
	  }
	  else{
		result = arguments.inputString;
	  }
	return Trim(result);
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
	return Trim(local.string);
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
  
  public string function ListToTags(string string = "") output="false" {
	var result = "";
	var local = {};
	local.tagsArray = [];
    if(Len(Trim(arguments.string))){
	  local.tagArray = ListToArray(arguments.string);
      if(IsArray(local.tagArray)){
		for (local.index=1;local.index LTE ArrayLen(local.tagArray);local.index=local.index+1) {
		  var local.obj = {};
		  local.obj['display'] = local.tagArray[local.index];
		  local.obj['value'] = local.tagArray[local.index];
		  ArrayAppend(local.tagsArray,local.obj);
		}
	  }
	}
	local.tagsArray = TagsSort(local.tagsArray);
	result = SerializeJson(local.tagsArray);
	return result;
  }
  
  public string function TagifyTagsToTags(string string = "") output="false" {
	var result = "";
	var local = {};
	local.tagsArray = [];
	local.tags = arguments.string;
	local.tagList = "";
    if(Len(Trim(local.tags)) AND IsJSON(local.tags)){
	  local.tagArray = DeserializeJSON(arguments.string);
      if(IsArray(local.tagArray)){
		for (local.index=1;local.index LTE ArrayLen(local.tagArray);local.index=local.index+1) {
		  if(IsStruct(local.tagArray[local.index]) AND NOT StructIsEmpty(local.tagArray[local.index]) AND StructKeyExists(local.tagArray[local.index],"value")){
            local.obj = {};
			local.obj['display'] = local.tagArray[local.index]['value'];
			local.obj['value'] = local.tagArray[local.index]['value'];
			ArrayAppend(local.tagsArray,local.obj);
		  }
		}
	  }
	}
	result = SerializeJson(local.tagsArray);
	return result;
  }
  
  public string function TagsToList(string string = "", boolean isList = false) output="false" {
	var result = "";
	var local = {};
	if(arguments.isList){
	  arguments.string = SerializeJson(ListToArray(arguments.string));
	}
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
  
  public string function TinymceArticleChangeImages(string html = "", string srcBefore = "", string srcAfter = "") output="false" {
	var local = {};
	local.regex = "(.*<img\s+[^>]*?src=[#chr(34)##chr(39)#]+)#arguments.srcBefore#([#chr(34)##chr(39)#]+.*)";
	local.result = REReplaceNoCase(arguments.html,local.regex,"\1#arguments.srcAfter#\2");
	return local.result;
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
  
  
  public struct function GetRandomTwitterCard() output="true" {
	var local = {};
	local.result = {};
	local.timestamp = DateFormat(Now(),'yyyymmdd') & TimeFormat(Now(),'HHmmss');
	local.filename = "";
	local.filedirectory = "";
	local.filepath = "";
	local.filecontent = "";
	local.currentFilename = ListLast(request.twittercard,"/");
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
	if(Len(Trim(local.filecontent))){
	  local.result['path'] = local.filepath;
	  local.result['url'] = local.filecontent;
	  cflock (name="twittercard", type="exclusive", timeout="30") {
		application.twittercard = local.filecontent;
	  }
	}
	return local.result;
  }
  
  public string function FormatJSON(string str = "", boolean stripHTML = true) output="true" {
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
	var lastClose = '';
	var relPos = 1;
	var	absPos = 0;
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
	  if (char == '}' OR char == ']') {
		fjson &= newLine;
		pos = pos - 1;
		for (var j=1; j<pos; j++) {
		  fjson &= indentStr;
		}
	  }
	  fjson &= char;    
	  if (char == '{' OR char == '[' OR (char == ',' AND (NOT ArrayLen(ignoreCommaPosArr) OR (ArrayLen(ignoreCommaPosArr) AND !ArrayFind(ignoreCommaPosArr,i))))) {
		ignoreCommaPosArr = [];
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
  
  public struct function CreateTheme(string theme = "") output="false" {
	var local = {};
    local.result = {
	  'default' = 'theme-1-dark',
	  'id' = 1,
      'stem' = 'theme-1',
      'light' = 'theme-1-light',
      'dark' = 'theme-1-dark'
	};
    local.result['default'] = arguments.theme;
    local.themeArray = ListToArray(arguments.theme,'-');
	if(ArrayLen(local.themeArray) EQ 3){
	  local.result['id'] = local.themeArray[2];
	  ArrayDeleteAt(local.themeArray,ArrayLen(local.themeArray));
	  local.theme = ArrayToList(local.themeArray,'-');
	  local.result['stem'] = local.theme;
	  local.result['light'] = local.theme & '-light';
	  local.result['dark'] = local.theme & '-dark';
	}
    return local.result;
  }
  
  public struct function GetMaterialThemeData(string theme = "") output="false" {
	var local = {};
	local.result = {};
    local.materialThemeData = createTheme(theme=arguments.theme);
	if(StructKeyExists(local.materialThemeData,"stem")){
	  for (var local.i = 1; local.i LTE ArrayLen(request.materialThemeData); local.i++) {
		local.materialThemeDataObj = request.materialThemeData[local.i];
		if(CompareNoCase(local.materialThemeDataObj['themeName'],local.materialThemeData['stem']) EQ 0){
		  local.result = local.materialThemeDataObj;
		}
	  }
	}
    return local.result;
  }
  
  public string function GetMaterialThemePrimaryColour(string theme = "") output="false" {
	var local = {};
	local.result = "";
    local.materialThemeDataObj = getMaterialThemeData(theme=arguments.theme);
	if(StructKeyExists(local.materialThemeDataObj,"primaryHex")){
	  local.result = local.materialThemeDataObj['primaryHex'];
	}
    return local.result;
  }
  
  public numeric function GetRandomAdminUserID(string roleid = "7") output="false" {
	var local = {};
	local.result = 0;
	try{
	  local.queryObj = new query();
	  local.queryObj.setDatasource(request.domain_dsn);
	  local.queryObj.addParam(name="Role_ID",value=arguments.roleid,cfsqltype="cf_sql_integer",list="yes");
	  local.queryObj = local.queryObj.execute(sql="SELECT * FROM tblUser WHERE Role_ID IN (:Role_ID)");
	  local.queryObj = local.queryObj.getResult(); 
	  if(local.queryObj.RecordCount) {
		 local.pos = RandRange(1,local.queryObj.RecordCount); 
		 local.result = Val(ListGetAt(ValueList(local.queryObj.User_ID),local.pos));
	  } 
	}
	catch( any e ) {
	  local.queryObj = new query();
	  local.queryObj.setDatasource(request.domain_dsn);
	  local.queryObj.addParam(name="Role_ID",value=7,cfsqltype="cf_sql_integer");
	  local.queryObj = local.queryObj.execute(sql="SELECT * FROM tblUser WHERE Role_ID  = :Role_ID");
	  local.queryObj = local.queryObj.getResult(); 
	  if(local.queryObj.RecordCount) {
		 local.pos = RandRange(1,local.queryObj.RecordCount); 
		 local.result = Val(ListGetAt(ValueList(local.queryObj.User_ID),local.pos));
	  } 
	}
    return local.result;
  }
  
  public boolean function HasProfanity(string string = "") output="false" {
	var local = {};
	local.result = false;
	local.string = REReplaceNoCase(arguments.string,"[[:punct:]]","","ALL");
	local.array = ListToArray(local.string," ");
	for (var local.i = 1; local.i LTE ArrayLen(local.array);local.i++) {
	  if(ListFindNoCase(request.profanityList,Trim(local.array[local.i]),"|")){
		local.result = true;
		break;
	  }
	}
	return local.result;
  }
  
  public boolean function IsWebImageFile(string path = "") output="false" {
	var local = {};
	local.result = false;
	local.files = createObject("java","java.nio.file.Files");
	local.file = createObject("java","java.io.File").init(arguments.path);
	try {
	  local.mime = local.files.probeContentType(local.file.toPath());
	  switch(local.mime){
		case "image/jpeg":
		  local.result = true;
		  break;
		case "image/jpg":
		  local.result = true;
		  break;
		case "image/png":
		  local.result = true;
		  break;
		case "image/gif":
		  local.result = true;
		  break;
	  }
	} 
	catch (any e) {
	}
	return local.result;
  }
  
  
  public string function SeoTitleFormat(string title = "") output="false" {
	var local = {};
	local.result = arguments.title;
    local.result = Trim(LCase(local.result));
	local.result = REReplaceNoCase(local.result,"[\s]+","-","ALL");
    return local.result;
  }
  
  public string function BuildSitemap(boolean writeFile = false, boolean unapproved = false) output="false" {
	  var local = {};
	  local.result = "";
	  local.timestamp = DateFormat(Now(),'yyyymmdd') & TimeFormat(Now(),'HHmmss');
	  local.newline = Chr(13) & Chr(10);
	  local.onetab = Chr(9);
	  local.twotab = Chr(9) & Chr(9);
	  local.threetab = Chr(9) & Chr(9) & Chr(9);
	  local.queryObj = new Query();	 
	  local.queryObj.setDatasource(request.domain_dsn);
	  if(arguments.unapproved){
		local.queryObj.addParam(name="Approved",value="1,0",cfsqltype="cf_sql_tinyint",list="yes"); 
	  }
	  else{
		local.queryObj.addParam(name="Approved",value=1,cfsqltype="cf_sql_tinyint"); 
	  }
	  local.queryObj.addParam(name="Article",value="",cfsqltype="cf_sql_longvarchar"); 
	  if(arguments.unapproved){
		local.queryObj = local.queryObj.execute(sql="SELECT * FROM tblFile WHERE Approved IN (:Approved) AND Article <> :Article");
	  }
	  else{
		local.queryObj = local.queryObj.execute(sql="SELECT * FROM tblFile WHERE Approved = :Approved AND Article <> :Article");
	  }
	  local.queryObj = local.queryObj.getResult(); 
	  if(local.queryObj.RecordCount) {
		savecontent variable="local.result" { 
		  WriteOutput('<?xml version="1.0" encoding="UTF-8"?>' & local.newline & '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' & local.newline & local.onetab & '<url>' & local.newline & local.twotab & '<loc>' & request.remotedomainurl & '</loc>' & local.newline & local.onetab & '</url>' & local.newline & ''); 
		  for(local.row in local.queryObj){
			  WriteOutput(local.onetab & '<url>' & local.newline & local.twotab & '<loc>' & request.remotedomainurl & '/' & request.catalogRouterAlias & '/' & local.row['File_ID']  & '/' & SeoTitleFormat(title=local.row['Title']) & '</loc>' & local.newline & local.onetab & '</url>' & local.newline & ''); 
		  }
		  WriteOutput('</urlset>'); 
		}
	  }
	  if(arguments.writeFile){
		cflock (name="write_document_#local.timestamp#", type="exclusive", timeout="30") {
		  FileWrite(request.webrootfilepath & "\sitemap.xml",local.result);
		}
	  }
	  return local.result;
  }
  
  
  public array function QueryToArray(query query = QueryNew(""), boolean isColumnNameUpperCase = false) output="false" {
	var local = {};
	var rows = [];
	for(local.obj in arguments.query) {
		local.temp = {};
		for(local.key in local.obj) {
		  if(NOT arguments.isColumnNameUpperCase) {	
			local.temp[LCase(local.key)] = local.obj[local.key];
		  }
		  else{
			local.temp[UCase(local.key)] = local.obj[local.key];
		  }
		}
		ArrayAppend(rows,local.temp);
	}
	return rows;
  }
  
  public struct function GenerateSimulationData() output="false" {
	var local = StructNew();
    var result = StructNew();
    StructInsert(result,"forename","");
    StructInsert(result,"surname","");
    StructInsert(result,"email","");
    StructInsert(result,"password","");
    local.forename = " Cary,Henrietta,Sonia,Sabrina,Lori,Flora,Daryl,Mattie,Eduardo,Tyrone,Guadalupe,Crystal,Vicky,Darnell,Luz,Saul,Alexis,Rhonda,Leigh,Cristina,Ashley,Brittany,Sammy,Lyle,Geraldine,Carmen,Tom,Candace,Elena,Hector,Marion,Carlton,Mandy,Judy,Heather,Josefina,Lionel,Vincent,Billy,Alexandra,Lynette,Edith,Gina,Melinda,Conrad,Marvin,Sandy,Josephine,Debra,Leslie,Rosie,Terrence,Rudy,Jaime,Sylvia,Benjamin,Freddie,Loretta,Lucy,Jack,Edwin,Domingo,Marion,Jeannette,Marian,Milton,Mae,Donald,Sherry,Ronald,Miguel,Nora,Angela,Beverly,Glenn,Terence,Thelma,Oscar,Dustin,Dolores,Beth,Carla,Jason,Candice,Betsy,Wendy,Megan,Winston,Carol,Brandy,Mario,Lindsay,Grady,Johnnie,Wayne,Kristine,Johanna,Teresa,Ignacio,Mindy,Otis,Natalie,Faye,Levi,Woodrow,Pearl,Stacy,Joanna,Jared,Kyle,Dominic,Travis,Sheila,Freda,Ramona,Winifred,Erin,Lola,Felix,Dan,Dawn,Bruce,Gary,Homer,Cameron,Jimmy,Matt,Alberto,Delia,Robin,Brooke,Cheryl,Clint,Marcia,Lucille,Daisy,Linda,Jody,Angelica,Archie,Pablo,Marcella,Abraham,Tommie,Annette,Dwight,Rodney,Rudolph,Sherri,Greg,Nina,Irene,Bessie,Gabriel,Alfredo,Brad,Ian,Marianne,Charles,Mamie,Robyn,Richard,Maxine,Kristy,Lance,Jake,Keith,Bonnie,Bob,Lora,Lena,Marco,Manuel,Rex,Dave,Rosa,Alton,Darin,Marguerite,Jay,Byron,Jill,Carl,Lynne,Derrick,Jeanne,Virgil,Timothy,Eugene,Brandi,Tim,Janice,Nicolas,Jessica,Kerry,Sylvester,Roman,Gretchen,Nancy,Lela,Jaime,Andrea,Maryann,Lisa,Helen,Pat,Darla,Paulette,Melanie,Charlie,Tara,Sophia,Kenneth,Mona,Cecelia,Chris,Shelley,Isabel,Orville,Erma,Gregg,Antonio,Enrique,Janet,Vivian,Wilbert,Dana,Jacob,Joey,Amber,Guadalupe,Amos,Elaine,Eva,Meghan,Elbert,Hattie,Mabel,Wendell,Victoria,Tina,Barbara,Seth,Preston,Jeffery,Jon,Essie,Shannon,Emma,Constance,Susan,Christie,Melba,Joy,Rochelle,Randall,Tommy,Maggie,Ella,Jackie,Pedro,June,Sam,Laura,Darrel,Ginger,Tonya,Nicholas,Dwayne,Tracy,Jeremiah,Julian,Brian,Fernando,Herbert,Jenna,Edmund,Dorothy,Bill,Van,Cody,Tony,Edna,Miranda,Benny,Yvette,Johnny,Leon,Karl,Lydia,Leland,Stephen,Dianna,Reginald,Carolyn,Salvador,Ruth,Leslie,Charlotte,Sharon,Elias,Courtney,Wesley,Kayla,Kevin,Mary,Sue,Valerie,Juan,Lula,Kathryn,Susie,Antoinette,Harry,Adrian,Gail,Rene,Dexter,Billie,Ron,Neil,Jenny,Madeline,Victor,Faith,Cecil,Albert,Luther,Barry,Bernard,Duane,Sergio,Joanne,Ramon,Gerald,Erik,Marlene,Jamie,Hope,Darrell,Jerome,Mildred,Sally,Ruby,Doug,Clinton,Rosalie,Frances,Rodolfo,Christine,Margarita,Theodore,Josh,Bernadette,Lucia,Robin,Leah,Maurice,Alyssa,Javier,Charlene,Rebecca,Donnie,Michele,Darren,Nichole,Cornelius,Angelina,Anna,Katherine,Doris,Jonathon,Ollie,Donna,Rachael,Ricky,Rolando,Sheryl,Heidi,Lorene,Janis,Darryl,Angel,Stella,Hilda,Eloise,Willard,Pamela,Kristin,Felicia,Raymond,Wilfred,Laverne,Noel,Emily,Cesar,Erick,Lowell,Stephanie,Mike,Nicole,Ismael,Elsie,Sadie,Emmett,Shannon,Myrtle,Iris,Salvatore,Margaret,Claire,Mark,Damon,Kristi,Arlene,Terri,Karen,Delbert,Clifford,Max,Randal,Jacquelyn,Roosevelt,Olive,Erika,Martha,Nathaniel,Leroy,Dixie,Estelle,Rosemarie,Clara,Vanessa,Ora,Juanita,Luis,Brandon,Nettie,Juana,Meredith,Andy,Annie,Sheldon,Kent,Wm,Timmy,Andres";
	local.surname = " Warren,Wade,Ray,Webster,Benson,Allen,Fowler,Dawson,Castro,Graham,Colon,Carlson,Williamson,Brock,Ortiz,Ballard,Dennis,Norman,Frank,Olson,Salazar,Mason,Nash,Houston,Shelton,Phelps,Mckenzie,Elliott,Young,Carpenter,Davis,Rodriquez,Lee,Bailey,Harris,Baker,Andrews,Townsend,Lucas,Morton,Moody,Diaz,Rogers,Harvey,Stokes,Steele,Crawford,Valdez,Obrien,Goodwin,Hogan,Love,Garner,Howell,Peters,Wise,Flowers,Clarke,Pope,Adams,Dean,Gibson,Mann,Wilkins,Mccoy,James,May,Riley,Porter,Mcbride,Jefferson,Mccormick,Malone,Zimmerman,Santiago,Dixon,Richards,Alvarez,Hayes,Lamb,Berry,Carson,Singleton,Tucker,Bryant,Curry,Gilbert,Mills,Johnson,Lane,Newton,Estrada,Lewis,Gardner,Lyons,Figueroa,Becker,Watkins,Carr,Morris,Cox,Ortega,Fleming,Wagner,French,Conner,Clark,Torres,Copeland,Mckinney,Cain,Martinez,Clayton,Hunter,Ferguson,Kelley,Schwartz,Stevens,Snyder,Brown,Delgado,Henry,Rice,Ryan,Tyler,Huff,Garcia,Fitzgerald,Marshall,King,Rodgers,Ross,Dunn,Maldonado,Leonard,Harrington,Lloyd,Reese,Munoz,Cannon,Jenkins,Patterson,Bowers,Lambert,Fernandez,Freeman,Hernandez,Morgan,Neal,White,Parks,Welch,Reynolds,Fields,Hopkins,Blair,Abbott,Logan,Palmer,Simon,Taylor,Adkins,Tate,Anderson,Day,Francis,Sparks,Flores,Wolfe,Joseph,Morales,Gomez,Russell,Wheeler,Mccarthy,Byrd,Wong,Grant,Thompson,Schneider,Fisher,Ingram,Gonzales,Robinson,Pratt,Frazier,Burton,Parker,Arnold,Evans,Massey,Carter,Parsons,Mack,Sims,Walsh,Paul,Yates,Jones,Gross,Ward,Webb,Cooper,Moran,Sherman,Fox,Hill,Griffin,Scott,Jimenez,Cruz,Moore,Vargas,Woods,Wells,Smith,Craig,Baldwin,Watson,Perry,Powell,Austin,Allison,Marsh,Horton,Wilkerson,Wright,Barnett,Hodges,Jackson,Davidson,Rowe,Richardson,Manning,Hale,Morrison,Cobb,Stone,Keller,Vaughn,Ford,Simmons,Holloway,Hardy,Boone,Armstrong,Garrett,Schultz,Jacobs,Greer,Owen,Chavez,Lynch,Cummings,Martin,Mcguire,Newman,Rivera,Kim,Gordon,Alvarado,Thornton,Walters,Fletcher,Moss,Caldwell,Holmes,Bishop,Hawkins,Drake,Osborne,Henderson,Miller,Bell,Walton,Guerrero,Lopez,Graves,Blake,Foster,Nguyen,Mcgee,Todd,Luna,Lawson,Carroll,Sharp,Matthews,Hunt,Strickland,Garza,Harrison,Williams,Johnston,Bass,Jennings,Myers,Bates,Reeves,Kennedy,Howard,Reid,Burns,Powers,Cole,Buchanan,Jensen,Poole,Wilson,Bradley,Holland,Holt,Gibbs,Nunez,Hughes,Hanson,Sandoval,Rose,George,Rhodes,Cunningham,Goodman,Vasquez,Turner,Larson,Cohen,Castillo,Hall,Murray,Nelson,Robertson,Potter,Bennett,Gregory,Thomas,Simpson,Norton,Herrera,Spencer,Barker,Medina,Stevenson,Hamilton,Haynes,Bryan,Briggs,Park,Perkins,Gill,Barton,Daniel,West,Waters,Vega,Hammond,Mendez,Owens,Hampton,Bush,Little,Patrick,Klein,Miles,Perez,Sutton,Doyle,Stanley,Mendoza,Pierce,Hudson,Silva,Hicks,Ramirez,Bridges,Brady,Walker,Christensen,Jordan,Lindsey,Roberts,Alexander,Hoffman,Chapman,Pena,Ramsey,Pearson,Floyd,Farmer,Schmidt,Wood,Duncan,Robbins,Norris,Washington,Swanson,Hines,Edwards,Daniels,Burgess,Weaver,Erickson,Fuller,Mullins,Douglas,Cross,Moreno,Shaw,Summers,Terry,Bowman,Gutierrez,Reyes,Watts,Lowe,Underwood,Page,Ruiz,Harmon,Reed,Barrett,Brooks,Campbell,Oliver,Franklin,Higgins,Casey,Knight,Tran,Ball,Meyer,Collins,Ramos,Mclaughlin,Greene,Hubbard,Saunders,Wallace,Hart,Price,Green,Patton,Payne,Bowen,Kelly,Stephens,Chandler,Griffith,Aguilar,Gray,Warner,Pittman,Soto,Black,Sanders,Roberson,Peterson,Roy,Stewart,Mathis,Rios,Cortez,Willis,Glover,Banks,Barnes,Long,Lawrence,Barber,Ellis,Montgomery,Collier,Hansen,Santos,Murphy,Burke,Brewer,Boyd,Romero,Phillips,Chambers,Quinn,Cook,Mcdaniel,Maxwell,Padilla,Rodriguez,Beck,Mcdonald,Butler,Curtis,Gonzalez,Nichols,Sullivan,Mitchell,Guzman,Weber,Coleman,Sanchez,Harper";
    result.forename = ListGetAt(local.forename,RandRange(1,ListLen(local.forename)));
    result.surname = ListGetAt(local.surname,RandRange(1,ListLen(local.surname)));
    result.email = Left(LCase(result.forename),1) & "." & LCase(result.surname) & "@" & request.remoteHost;
    result.password = LCase(result.forename) & LCase(result.surname);
	return result;
  }
  
  
</cfscript>