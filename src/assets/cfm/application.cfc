<cfcomponent>
	<cfscript>

		this.name = hash( getCurrentTemplatePath() );
		this.applicationTimeout = CreateTimeSpan( 2, 0, 0, 0 );
		this.clientManagement = true;
		this.clientStorage = "registry";
		this.setClientCookies = true;
		this.sessionManagement = true;
		this.sessionTimeout = CreateTimeSpan(0,1,0,0);
		this.setDomainCookies = false;
		
		this.currentTemplatePathDirectory = getDirectoryFromPath( getCurrentTemplatePath() );
		this.mappings = {
		  "/components" = this.currentTemplatePathDirectory & "components\"
		};

		function onApplicationStart() {

		  return true;
		  
		}

		function onSessionStart() {
		}		

		function onRequestStart( targetpath ) {
			
		  var local = StructNew();
		  local.identity = "parent";
		  
		  include "on-request-start-application.cfm";
		  		  
		  return true;
		  
		}
		
		function onRequest( string targetPage ) {
		  include arguments.targetPage;
		}
		
		function onRequestEnd() {
		}
		
		function onSessionEnd( struct SessionScope, struct ApplicationScope ) {
		}
		
		function onApplicationEnd( struct ApplicationScope ) {
		}
		
		/*function onError( any Exception, string EventName ) {
			
		}*/

	</cfscript>
</cfcomponent>