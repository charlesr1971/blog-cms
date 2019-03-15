<cfcomponent extends="taffy.core.api">
	<cfscript>

		this.name = hash(getCurrentTemplatePath());
		
		this.mappings['/resources'] = expandPath('./resources');
		this.mappings['/taffy'] = expandPath('./taffy');
		this.mappings['/components'] = expandPath('../../../components');
		
		this.currentTemplatePathDirectory = getDirectoryFromPath( getCurrentTemplatePath() );
		
		variables.framework = {};
		variables.framework.debugKey = "debug";
		variables.framework.reloadKey = "reload";
		variables.framework.reloadPassword = "false";
		variables.framework.docs.APIName = "API Documentation";
		variables.framework.docs.APIVersion = "1.0.0";
		
		function onApplicationStart(){
			return super.onApplicationStart();
		}

		function onRequestStart(TARGETPATH){
			var local = StructNew();
			local.identity = "child";
			
			request.environment = "development";
  
			if(NOT isLocalhost(CGI.REMOTE_ADDR)){
			  request.environment = "production";
			}
						
			if(CompareNoCase(request.environment,"production") EQ 0){
			  variables.framework.reloadOnEveryRequest = true;
			  variables.framework.reloadPassword = this.name;
			  variables.framework.disableDashboard = true;
			}
			
			if(CompareNoCase(request.environment,"production") EQ 0 AND StructKeyExists(url,variables.framework.reloadKey) AND CompareNoCase(url[variables.framework.reloadKey],this.name) EQ 0){
			  variables.framework.disableDashboard = false;
			}
						
			variables.framework.showDocsWhenDashboardDisabled = true;
			
			include "../../../on-request-start-application.cfm";
			
			variables.framework.allowCrossDomain = request.ngAccessControlAllowOrigin;
						
			/*if(NOT StructKeyExists(application,"utils") OR request.appreloadValidated) {
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
			}*/
			
			return super.onRequestStart(TARGETPATH);
			
		}

		// this function is called after the request has been parsed and all request details are known
		function onTaffyRequest(verb, cfc, requestArguments, mimeExt){
			// this would be a good place for you to check API key validity and other non-resource-specific validation
			return true;
		}

	</cfscript>
</cfcomponent>
