<cfoutput>

  <cfinclude template="../functions.cfm">
  
  <cfparam name="testImageFilename" default="test-image-upload.jpg" />
  <cfparam name="testImageContentType" default="image/jpg" />
  <cfparam name="restApiEndpoint" default="#request.restApiEndpoint#" />
  <cfparam name="imagememberposttagslist" default="" />
  <cfparam name="imagememberputtagslist" default="" />
  <cfparam name="authorization" default="" />
  <cfparam name="userToken" default="" />
  <cfparam name="userMemberDelete" default="false" />
  <cfparam name="themeObj" default="#createTheme(request.theme)#">
  <cfparam name="theme" default="#themeObj['default']#" />
  
  <cfset restApiService = createObject('component','components.restApiService')>
  
  <cfif StructKeyExists(url,"userMemberDelete") AND url.userMemberDelete>
    <cfset session['userMemberDelete'] = true>
    <cflocation url="../components/restApiService.cfm" addtoken="no" />
  </cfif>
  
  <cfif StructKeyExists(session,"userMemberDelete") AND session.userMemberDelete>
	<cfset userMemberDelete = session['userMemberDelete']>
  </cfif>
  
  <cfif (StructKeyExists(session,"userMemberDelete") AND session.userMemberDelete) OR StructKeyExists(url,"reset")>
    <cfset StructDelete(session,"usertoken")>
    <cfset StructDelete(session,"authorization")>
    <cfset StructDelete(session,"userMemberDelete")>
  </cfif>

  <cfif StructKeyExists(session,"usertoken") AND Len(Trim(session['usertoken']))>
    <cfset userToken = session['usertoken']>
  </cfif>
  
  <cfif StructKeyExists(session,"authorization") AND Len(Trim(session['authorization']))>
    <cfset authorization = session['authorization']>
  </cfif>
  
  <cfif StructKeyExists(form,"usertoken") AND Len(Trim(form['usertoken']))>
    <cfset userToken = form['usertoken']>
    <cfset session['usertoken'] = userToken>
  </cfif>
  
  <cfif StructKeyExists(form,"authorization") AND Len(Trim(form['authorization']))>
    <cfset authorization = form['authorization']>
    <cfset session['authorization'] = authorization>
  </cfif>
  
  <cfif StructKeyExists(form,"usertoken") AND Len(Trim(form['usertoken'])) AND StructKeyExists(form,"authorization") AND Len(Trim(form['authorization']))>
    <cflocation url="../components/restApiService.cfm" addtoken="no" />
  </cfif>

  <cfif StructKeyExists(url,"httpRequest") AND StructKeyExists(url,"verb")>
    <cfif ListFindNoCase("imageMember,tinymceArticleImageMember",url['httpRequest']) AND CompareNoCase(url['verb'],"post") EQ 0>
    <cfelse>
	  <cfset StructAppend(session,url)>
      <cfset StructAppend(session,form)>
      <cflocation url="../components/restApiService.cfm" addtoken="no" />
    </cfif>
  </cfif>
  
  <cfif StructKeyExists(session,"httpRequest") AND StructKeyExists(session,"verb")>
    <cfloop collection="#session#" item="key">
      <cfif NOT ListFindNoCase("authorization,userToken,userMemberDelete,imageMember_post_binaryfileobj_data,tinymceArticleImageMember_post_binaryfileobj_data",key)>
        <cfset variables[key] = session[key]>
        <cfset StructDelete(session,key)>
      </cfif>
    </cfloop>
  </cfif>
  
  <cfif StructKeyExists(variables,"imageMember_post_tags")>
	<cfset imagememberposttagslist = TagifyTagsToTags(variables.imageMember_post_tags)>
  </cfif>
    
  <cfif StructKeyExists(variables,"imageMember_put_tags")>
	<cfset imagememberputtagslist = TagifyTagsToTags(variables.imageMember_put_tags)>
  </cfif>
  
  <cfset headerbackground = getMaterialThemePrimaryColour(theme=request.theme)>
  
  <cfif CompareNoCase(theme,themeObj['light']) EQ 0>
    <cfset bodybackground = "rgb(255, 255, 255)">
    <cfset leftbackground = "##ffffff">
    <cfset leftafterbackgroundimage = "linear-gradient(to bottom, rgba(255,255,255, 0), rgba(255,255,255, 1) 90%)">
    <cfset leftfillplaceholderbackground = "##f2f2f2">
    <cfset linkindexlistitem = "rgba(0, 0, 0, 0.75)">
    <cfset linkindexlistitemcurrenthover = "##f5f5f5">
    <cfset rippleafterbackgroundimage = "radial-gradient(circle, ##E0E0E0 10%, transparent 10.01%)">
  <cfelse>
	<cfset bodybackground = "rgb(255, 255, 255)">
    <cfset leftbackground = "##424242">
    <cfset leftafterbackgroundimage = "linear-gradient(to bottom, rgba(66,66,66, 0), rgba(66,66,66, 1) 90%)">
    <cfset leftfillplaceholderbackground = "##4c4c4c">
    <cfset linkindexlistitem = "rgba(255, 255, 255, 1)">
    <cfset linkindexlistitemcurrenthover = "##494949">
    <cfset rippleafterbackgroundimage = "radial-gradient(circle, ##fff 10%, transparent 10.01%)">
  </cfif>
  
  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
      
  <html xmlns="http://www.w3.org/1999/xhtml" class="no-js">
    
    <head>
      
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=yes">
      <title>REST API Service Examples</title>
      
      <link href="../../font/font-awesome-4.7.0/css/font-awesome.min.css" rel="stylesheet">
      
      <link rel="stylesheet" href="../../js/highlight.js/styles/default.css">
      <link rel="stylesheet" href="../../js/jquery-ui-1.10.3.custom/css/jquery-ui-themes-1.10.3/themes/smoothness/jquery-ui.css" type="text/css" media="screen" />
      <link rel="stylesheet" href="../../js/tagify/tagify.css">
      <link rel="stylesheet" href="../../js/perfect-scrollbar/css/perfect-scrollbar.css">
      <link href="https://fonts.googleapis.com/css?family=Roboto:300,400,500" rel="stylesheet">
      <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">
      
      <script src="../../js/jquery.js" type="text/javascript"></script>
      <script src="../../js/jquery-ui-1.10.3.custom/js/jquery-ui-1.10.3.custom.js" type="text/javascript"></script>
      
      <script src="../../js/js-cookie/src/js.cookie.js" type="text/javascript"></script>
      <script src="../../js/tinymce/tinymce.min.js" type="text/javascript"></script>
      <script src="../../js/greensock-js/src/minified/TweenMax.min.js" type="text/javascript"></script>
      <script src="../../js/mobile-detect/mobile-detect.js" type="text/javascript"></script>
      <script src="../../js/tagify/tagify.min.js" type="text/javascript"></script>
      <script src="../../js/perfect-scrollbar/js/perfect-scrollbar.min.js" type="text/javascript"></script>
      
      
      <script type="text/javascript">
	  
		// global variables
		
		var $md = new MobileDetect(window.navigator.userAgent);
		
		var $tagifyimagememberposttags = null;
		var $tagifyimagememberputtags = null;
		
		console.log("$md.mobile(): ",$md.mobile());
		
		var $tagifyConfig = {
			delimiters: ",| ",
			maxTags: 6,
			enabled: 3,
			maxItems: 5
		}
	  
		var $consoleDebug = false;
		var $ajaxdataDebug = false;
		
		var $style_formats = [
          {title: 'Headers', items: [
            {title: 'Header 1', format: 'h1'},
            {title: 'Header 2', format: 'h2'},
            {title: 'Header 3', format: 'h3'},
            {title: 'Header 4', format: 'h4'},
            {title: 'Header 5', format: 'h5'},
            {title: 'Header 6', format: 'h6'}
          ]},
          {title: 'Inline', items: [
            {title: 'Bold', icon: 'bold', format: 'bold'},
            {title: 'Italic', icon: 'italic', format: 'italic'},
            {title: 'Underline', icon: 'underline', format: 'underline'},
            {title: 'Strikethrough', icon: 'strikethrough', format: 'strikethrough'},
            {title: 'Superscript', icon: 'superscript', format: 'superscript'},
            {title: 'Subscript', icon: 'subscript', format: 'subscript'},
            {title: 'Code', icon: 'code', format: 'code'}
          ]},
          {title: 'Blocks', items: [
            {title: 'Paragraph', format: 'p'},
            {title: 'Blockquote', format: 'blockquote'},
            {title: '...', block: 'div', classes: 'tinymce-divider-after-plugin'},
            {title: 'Div', format: 'div'},
            {title: 'Pre', format: 'pre'}
          ]},
          {title: 'Alignment', items: [
            {title: 'Left', icon: 'alignleft', format: 'alignleft'},
            {title: 'Center', icon: 'aligncenter', format: 'aligncenter'},
            {title: 'Right', icon: 'alignright', format: 'alignright'},
            {title: 'Justify', icon: 'alignjustify', format: 'alignjustify'}
          ]}
        ];
		
		var $theme = createTheme('#theme#');
		
		// utility functions
	  
		function capitalizeFirstLetter(string) {
		  return string.charAt(0).toUpperCase() + string.slice(1);
		}
		
		function tagsToList(tags) {
		  var result = "";
		  var tags = tags !== '' ? JSON.parse(tags) : '';
		  var tagArray = [];
		  if($consoleDebug){
			console.log('tagsToList(): tags 1 ',tags);
		  }
		  if($.isArray(tags)){
			if($consoleDebug){
			  console.log('tagsToList(): tags 2 ',tags);
			}
			for (i=0;i < tags.length;i++) {
			  if(!$.isEmptyObject(tags[i]) && 'value' in tags[i]){
				tagArray.push(tags[i]['value']);
			  }
			}
		  }
		  result = tagArray.join();
		  return result;
		}	
		
		function transformaTag(value){
		  return {display:value,value:value};
		}	
		
		function sortMenuArray(array,order) {
		  var array = (arguments[0] != null) ? arguments[0] : [];
		  var order = (arguments[1] != null) ? arguments[1] : 'asc';
		  var result = [];
		  if($.isArray(array) && array.length){
			  
			if(order === 'asc'){
			  result = array.sort(function(a,b){
				var nameA = a.name.toLowerCase();
				var nameB = b.name.toLowerCase();
				if (nameA < nameB){
				  return -1 ;
				}
				if (nameA > nameB){
				  return 1;
				}
				return 0;
			  });
			}
			else{
			  result = array.sort(function(a,b){
				var nameA = a.name.toLowerCase();
				var nameB = b.name.toLowerCase();
				if (nameA > nameB){
				  return -1 ;
				}
				if (nameA < nameB){
				  return 1;
				}
				return 0;
			  });
			}
		  }
		  return result;
		}
		
		function toggleMenu() {
		  var linkindex = $('##link-index');
		  var viewportwidth = parseInt($(window).width());
		  var viewportheight = parseInt($(window).height());
		  var overlay = '<div id="menu-overlay" class="menu-overlay"></div>';
		  if(linkindex.length && linkindex.css('left') === '-' + viewportwidth + 'px'){
			TweenMax.to('##link-index', 1, {left:'0px', ease:Expo.easeOut});
			//$(document.body).css({'position':'fixed','top':'0px','left':'-80%','overflow':'hidden','height':viewportheight + 'px'});
			$(document.body).css({'position':'fixed','overflow':'hidden','width':parseInt(viewportwidth - 40) + 'px','height':viewportheight + 'px'});
			$('.hljs').css({'overflow':'hidden'});
			$(document.body).append(overlay);
			var overlayEl = $('.menu-overlay');
			if(overlayEl.length){
			  overlayEl.css({'width':viewportwidth + 'px','height':(viewportheight * 2) + 'px'});
			  overlayEl.addClass('menu-overlay-show');
			}
		  }
		  else{
			$(document.body).css({'position':'','overflow':'','width':'','height':''});
			$('.hljs').css({'overflow':''});
			var overlayEl = $('.menu-overlay');
			if(overlayEl.length){
			  overlayEl.remove();
			}
			TweenMax.to('##link-index', 1, {left:'-' + viewportwidth + 'px', ease:Expo.easeOut});
		  }
		}
		
		function buildMenu() {
		  var linkindex = $('##link-index');
		  var leftfill = $('##left-fill');
		  var right = $('##right');
		  var rightDom = document.getElementById('right');
		  var rightheight = 0;
		  var securitycredentials = $('##security-credentials');
		  var securitycredentialsheight = securitycredentials.height();
		  var viewportwidthOffset = 0;
		  var viewportheightOffset = 84;
		  if($consoleDebug){
			console.log('buildMenu(): securitycredentialsheight ',securitycredentialsheight);
		  }
		  var linkindexlistcontainerstyle = !$md.mobile() ? ' style="display:none;"' : '';
		  var linkindexcontent = '<div id="link-index-list-container"' + linkindexlistcontainerstyle + '><div id="link-index-list-inner"><ul class="link-index-list">';
		  var viewportwidth = parseInt($(window).width());
		  var viewportheight = parseInt($(window).height() - viewportheightOffset);
		  if($consoleDebug){
			console.log('buildMenu(): viewportwidth: ',viewportwidth,' viewportheight: ',viewportheight);
		  }
		  var showmenu = false;
		  var nameArray = [];
		  var namesArray = [];
		  if(right.length && rightDom && securitycredentials.length && !isNaN(securitycredentialsheight) && securitycredentialsheight > 0){
			rightheight = parseInt(rightDom.clientHeight + securitycredentialsheight);
		  }
		  if($consoleDebug){
			console.log('buildMenu(): rightheight ',rightheight,' rightDom.clientHeight: ',rightDom.clientHeight,' rightDom: ',rightDom);
		  }
		  right.css({'height':rightheight + 'px'});
		  $('a.component-anchor').each(function(index,el){
			var nameAttr = $(this).attr('name');
			var hasNameAttr = typeof nameAttr !== typeof undefined && nameAttr !== false ? true : false;
			var linkObj = {};
			linkObj['name'] = nameAttr;
			linkObj['element'] = $(this);
			nameArray.push(linkObj);
			namesArray.push(nameAttr);
		  });
		  nameArray = sortMenuArray(nameArray,'asc');
		  namesArray = namesArray.sort();
		  var names = namesArray.join(',');
		  if($consoleDebug){
			console.log('buildMenu(): nameArray ',nameArray);
			console.log('buildMenu(): names ',names);
		  }
		  $.each(nameArray,function(index,el){
			var element  = el['element'];
			var nameAttr = element.attr('name');
			var hasNameAttr = typeof nameAttr !== typeof undefined && nameAttr !== false ? true : false;
			if(hasNameAttr){
			  var nameArr = nameAttr.split('-');
			  if(nameArr.length === 2){
				showmenu = true;
				var title = capitalizeFirstLetter(nameArr[0]);
				var verb = nameArr[1].toUpperCase();
				<cfif StructKeyExists(variables,"httpRequest") AND StructKeyExists(variables,"verb")>
				  if(title.toLowerCase() === '#LCase(variables.httpRequest)#' && verb.toLowerCase() === '#LCase(variables.verb)#'){
					var link = '<li id="menu-link-' + nameAttr + '"><a class="link-index-list-item-current ripple" href="##' + nameAttr + '">' + title + ': ' + verb + '</a></li>';
				  }
				  else{
					var link = '<li id="menu-link-' + nameAttr + '"><a class="ripple" href="##' + nameAttr + '">' + title + ': ' + verb + '</a></li>';
				  }
				<cfelse>
				  if(index === 0){
					var link = '<li id="menu-link-' + nameAttr + '"><a class="link-index-list-item-current ripple" href="##' + nameAttr + '">' + title + ': ' + verb + '</a></li>';
				  }
				  else{
					var link = '<li id="menu-link-' + nameAttr + '"><a class="ripple" href="##' + nameAttr + '">' + title + ': ' + verb + '</a></li>';
				  }
				</cfif>
				linkindexcontent += link;
			  }
			}
		  });
		  linkindexcontent += '</ul></div></div>';
		  if(!showmenu){
			$('##user-token-warning').html('Please login via the website and then refresh this page. Finally, submit the \'Security Credentials\' form');
			$('##user-token-warning').fadeIn();
		  }
		  if(leftfill.length && linkindex.length && showmenu){
			linkindex.append(linkindexcontent);
			if($md.mobile()){
			  linkindex.css({'left':'-' + viewportwidth + 'px'});
			}
			var linkindexlistcontainer = $('##link-index-list-container');
			var linkindexlistinner = $('##link-index-list-inner');
			if(linkindexlistcontainer.length && linkindexlistinner.length){
			  if(!$md.mobile()){
				linkindexlistcontainer.fadeIn('slow',function(){
				  leftfill.fadeOut('slow',function(){
					var linkindexlistcontainerheight = linkindexlistcontainer.height();
					var linkindexlistcontainerheight = viewportheight < linkindexlistcontainerheight ? viewportheight : linkindexlistcontainerheight;
					if($consoleDebug){
					  console.log('buildMenu(): linkindexlistcontainerheight: desktop ',linkindexlistcontainerheight);
					}
					linkindexlistcontainer.css({'height':linkindexlistcontainerheight + 'px'});
					var container = $('##link-index-list-container');
					var containerDom = document.querySelector('##link-index-list-container');
					if(containerDom){
					  var ps = new PerfectScrollbar(containerDom);
					}
					<cfif StructKeyExists(variables,"httpRequest") AND StructKeyExists(variables,"verb")>
					  if(container.length){
						var menulink = $('##menu-link-#variables.httpRequest#-#variables.verb#');
						if(menulink.length){
						  var menulinkTopPos = menulink.position()['top'];
						  if($consoleDebug){
							console.log('menulink: ',menulink);
							console.log('menulinkTopPos: ',menulinkTopPos);
						  }
						  //container.scrollTop = menulinkTopPos;
						  container.animate({ scrollTop: menulinkTopPos});
						}
					  }
					</cfif>
				  });  
				});
			  }
			  else{
				  var linkindexlistinnerheight = linkindexlistinner.height();
				  var linkindexlistinnerheight = viewportheight < linkindexlistinnerheight ? viewportheight : linkindexlistinnerheight;
				  if($consoleDebug){
					console.log('buildMenu(): linkindexlistinnerheight: mobile ',linkindexlistinnerheight);
				  }
				  linkindexlistinner.css({'height':linkindexlistinnerheight + 'px'});
			  }
			}
		  }
		  if($consoleDebug){
			console.log('buildMenu(): end ');
		  }
		}
				
		function showComponentContainer(name) {
		  var component = $('a[name="' + name + '"] + div.component-container');
		  var prev = $('a[name="' + name + '"]').prev();
		  $('a[name] + div.component-container').each(function(index){
			$(this).css({'display':'none'});
		  });
		  if(component.length && prev.length){
			component.fadeIn();
		  }
		}
		
		function createTheme(theme) {
		  var result = {
			default: 'theme-1-dark',
			id: 1,
			stem: 'theme-1',
			light: 'theme-1-light',
			dark: 'theme-1-dark'
		  };
		  if($consoleDebug) {
			console.log('createTheme(): theme ',theme);
		  }
		  if(theme !== '') {
			result['default'] = theme;
			var themeArray = theme.split('-');
			if(Array.isArray(themeArray) && themeArray.length === 3){
			  result['id'] = parseInt(themeArray[1]);
			  themeArray.pop();
			  var _theme = themeArray.join('-');
			  result['stem'] = _theme;
			  result['light'] = _theme + '-light';
			  result['dark'] = _theme + '-dark';
			}
		  }
		  if($consoleDebug) {
			console.log('createTheme(): result ',result);
		  }
		  return result;
		}
		
		function setElementProperties(type) {
		  var element = document.documentElement;
		  $theme = createTheme(type);
		  if($theme['id'] === 1){
			element.style.setProperty('--header-background', '##607d8b');
		  }
		  else{
			element.style.setProperty('--header-background', '##e91e63');
		  }
		  if(type === "#themeObj['light']#"){
			element.style.setProperty('--body-background', 'rgb(255, 255, 255)');
			element.style.setProperty('--left-background', '##ffffff');
			element.style.setProperty('--left-after-background-image', 'linear-gradient(to bottom, rgba(255,255,255, 0), rgba(255,255,255, 1) 90%)');
			element.style.setProperty('--left-fill-placeholder-background', '##f2f2f2');
			element.style.setProperty('--link-index-list-item', 'rgba(0, 0, 0, 0.75)');
			element.style.setProperty('--link-index-list-item-current-hover', '##f5f5f5');
			element.style.setProperty('--ripple-after-background-image', 'radial-gradient(circle, ##E0E0E0 10%, transparent 10.01%)');
		  }
		  else{
			element.style.setProperty('--body-background', 'rgb(255, 255, 255)');
			element.style.setProperty('--left-background', '##424242');
			element.style.setProperty('--left-after-background-image', 'linear-gradient(to bottom, rgba(66,66,66, 0), rgba(66,66,66, 1) 90%)');
			element.style.setProperty('--left-fill-placeholder-background', '##4c4c4c');
			element.style.setProperty('--link-index-list-item', 'rgba(255, 255, 255, 1)');
			element.style.setProperty('--link-index-list-item-current-hover', '##494949');
			element.style.setProperty('--ripple-after-background-image', 'radial-gradient(circle, ##fff 10%, transparent 10.01%)');
		  }
		}

		// tagify functions
		
		function tagifyimagememberposttagsOnInput(e){
		  var value = e.detail;
		  $tagifyimagememberposttags.settings.whitelist.length = 0;
		  var url = '#restApiEndpoint#/autocompleteTags/' + value + '/true';
		  fetch(url)
		  .then(data => {
			var res  = data.json();
			return res;
		  })
		  .then(function(whitelist){
			$tagifyimagememberposttags.settings.whitelist = whitelist;
			$tagifyimagememberposttags.dropdown.show.call($tagifyimagememberposttags,value);
		  })
		}
		
		function tagifyimagememberputtagsOnInput(e){
		  var value = e.detail;
		  $tagifyimagememberputtags.settings.whitelist.length = 0;
		  var url = '#restApiEndpoint#/autocompleteTags/' + value + '/true';
		  fetch(url)
		  .then(data => {
			var res  = data.json();
			return res;
		  })
		  .then(function(whitelist){
			$tagifyimagememberputtags.settings.whitelist = whitelist;
			$tagifyimagememberputtags.dropdown.show.call($tagifyimagememberputtags,value);
		  })
		}
		
		// cookies
	  	  
		var cookies = Cookies.get();
		var authorization = '';
		if('jwtToken' in cookies) {
		  authorization = cookies['jwtToken'];
		}
		if($consoleDebug){
		  console.log('authorization: ',authorization);
		}
		var userToken = '';
		if('userToken' in cookies) {
		  userToken = cookies['userToken'];
		}
		if($consoleDebug){
		  console.log('userToken: ',userToken);
		}
		<cfif StructKeyExists(variables,"userMemberDelete") AND variables.userMemberDelete>
		  Cookies.remove('jwtToken');
		  Cookies.remove('userToken');
		  authorization = '';
		  userToken = '';
		</cfif>
		var theme = '#theme#';
		if('theme' in cookies) {
		  theme = cookies['theme'];
		}
		if($consoleDebug){
		  console.log('theme: ',theme);
		}
		
		// detect tab window focus
		
		$(window).focus(function() {
		  var theme = 'theme' in cookies ? Cookies.get('theme') : '#theme#';
		  var usermemberputtheme = $('##userMember_put_theme');
		  if(usermemberputtheme.length){
			usermemberputtheme.val(theme);
		  }
		  setElementProperties(theme);
		  if($consoleDebug){
			console.log('$(window).focus: theme: ',theme);
		  }
		});
		
		// ajax functions
		
		function commentCollection_get_page(fileUuid) {
		  var url = '#restApiEndpoint#/pages/' + fileUuid;
		  var commentcollectiongetpage = $('##commentCollection_get_page');
		  var content = '';
		  $.ajax({
			url: url,
			success: function (response) {
			  var data = response;
			  if($ajaxdataDebug){
				console.log('commentCollection_get_page(): data 1 ',data);
			  }
			  if(!$.isEmptyObject(data) && 'pages' in data && data['pages'] > 0){
				if($ajaxdataDebug){
				  console.log('commentCollection_get_page(): data 2 ',data);
				}
				for(var i = 0;i<data['pages'];i++){
				  <cfif StructKeyExists(variables,"commentCollection_get_page")>
					if((i + 1) == '#variables.commentCollection_get_page#'){
					  content += '<option value="' + (i + 1)  + '" selected="selected">' + (i + 1)  + '</option>';
					}
					else{
					  content += '<option value="' + (i + 1)  + '">' + (i + 1)  + '</option>';
					}
				  <cfelse>
					content += '<option value="' + (i + 1)  + '">' + (i + 1)  + '</option>';
				  </cfif>
				}
			  }
			  if(commentcollectiongetpage.length){
				commentcollectiongetpage.html(content);
			  }
			},
			error: function (jqXHR,textStatus,errorMessage) {
			  console.log('ERROR: commentCollection_get_page(): ajax',errorMessage);
			}
		  });
		}		
		
		function imageMember_put(fileUuid) {
		  var url = '#restApiEndpoint#/image/' + fileUuid;
		  var imageMemberputimagepath = $('##imageMember_put_imagepath');
		  var imageMemberputname = $('##imageMember_put_name');
		  var imageMemberputtitle = $('##imageMember_put_title');
		  var imageMemberputdescription = $('##imageMember_put_description');
		  var imageMemberputarticle = $('##imageMember_put_article');
		  var imageMemberputtags = $('##imageMember_put_tags');
		  var imageMemberputtagshidden = $('##imageMember_put_tags_hidden');
		  var imageMemberputpublisharticledate = $('##imageMember_put_publisharticledate');
		  var content = '';
		  if($consoleDebug){
			console.log('imageMember_put(): fileUuid ',fileUuid);
		  }
		  $.ajax({
			url: url,
			headers: {'userToken': userToken},
			success: function (response) {
			  var data = response;
			  if($ajaxdataDebug){
				console.log('imageMember_put(): data 1 ',data);
			  }
			  if(!$.isEmptyObject(data) && 'imagePath' in data && 'author' in data && 'title' in data && 'description' in data && 'article' in data && 'tags' in data && 'publishArticleDate' in data && 'error' in data && data['error'] === ''){
				if($ajaxdataDebug){
				  console.log('imageMember_put(): data 2 ',data);
				}
				if(imageMemberputimagepath.length){
				  var imagePath = data['imagePath'].split('/');
				  if($.isArray(imagePath)){
					var imagepath = imagePath.pop();
					if($consoleDebug){
					  console.log('imageMember_put(): imagePath 1 ',imagePath);
					}
					imagePath = imagePath.join('/');
					imagePath = '/' + imagePath;
					if($consoleDebug){
					  console.log('imageMember_put(): imagePath 2 ',imagePath);
					}
					$('##imageMember_put_imagepath option[value="' + imagePath + '"]').prop('selected', true);
				  }
				}
				if(imageMemberputname.length){
				  imageMemberputname.val(data['author']);
				}
				if(imageMemberputtitle.length){
				  imageMemberputtitle.val(data['title']);
				}
				if(imageMemberputdescription.length){
				  imageMemberputdescription.val(data['description']);
				}
				if(imageMemberputarticle.length){
				  imageMemberputarticle.val(data['article']);
				}
				if(imageMemberputtags.length){
				  if($consoleDebug){
					console.log("imageMember_put(): data['tags'] ",data['tags']);
				  }
				  var tags = tagsToList(data['tags']);
				  if($consoleDebug){
					console.log('imageMember_put(): tags ',tags);
				  }
				  var input = document.querySelector('##imageMember_put_tags');
				  if(!$tagifyimagememberputtags){
					$tagifyimagememberputtags = new Tagify(input,{
					  delimiters: $tagifyConfig['delimiters'],
					  maxTags: $tagifyConfig['maxTags'],
					  whitelist: [],
					  dropdown: {
						enabled: $tagifyConfig['enabled'],
						maxItems: $tagifyConfig['maxItems']
					  }
					});
					$tagifyimagememberputtags.on('input', tagifyimagememberputtagsOnInput);
				  }
				  if($consoleDebug){
					console.log('imageMember_put(): $tagifyimagememberputtags ',$tagifyimagememberputtags);
				  }
				  $tagifyimagememberputtags.removeAllTags();
				  $tagifyimagememberputtags.addTags(tags);
				}
				if(imageMemberputpublisharticledate.length){
				  imageMemberputpublisharticledate.val(data['publishArticleDate']);
				}
			  }
			},
			error: function (jqXHR,textStatus,errorMessage) {
			  console.log('ERROR: imageMember_put(): ajax',errorMessage);
			}
		  });
		}
		
		function imageMember_imagepath(verb) {
		  var url = '#restApiEndpoint#/category';
		  var imageMembeimagepath = $('##imageMember_' + verb + '_imagepath');
		  var content = '';
		  $.ajax({
			url: url,
			success: function (response) {
			  var data = response;
			  if($ajaxdataDebug){
				console.log('imageMember_imagepath(): data 1 ',data);
			  }
			  if(!$.isEmptyObject(data)){
				if($ajaxdataDebug){
				  console.log('imageMember_imagepath(): data 2 ',data);
				}
				for(var i = 0;i<data.length;i++){
				  var optgroup = data[i][0];
				  var array = data[i][1];
				  var label = optgroup.split('//');
				  if($.isArray(label)){
					label = label[label.length-1];
				  }
				  content += '<optgroup label="' + label + '">';
				  for(var ii = 0;ii<array.length;ii++){
					var value =  array[ii].replace(/[/]+/g,'/');
					var text =  array[ii].split('//');
					if($.isArray(text)){
					  text = text[text.length-1];
					}
					<cfif StructKeyExists(variables,"imageMember_post_imagepath") OR StructKeyExists(session,"imageMember_post_imagepath")>
					  <cfif StructKeyExists(variables,"imageMember_post_imagepath")>
						if(value == '#variables.imageMember_post_imagepath#' && verb === 'post'){
						  content += '<option value="' + value + '" selected="selected">' + text + '</option>';
						}
						else{
						  content += '<option value="' + value + '">' + text + '</option>';
						}
					  </cfif>
					  <cfif StructKeyExists(session,"imageMember_post_imagepath")>
						if(value == '#session.imageMember_post_imagepath#' && verb === 'post'){
						  content += '<option value="' + value + '" selected="selected">' + text + '</option>';
						}
						else{
						  content += '<option value="' + value + '">' + text + '</option>';
						}
					  </cfif>
					<cfelseif StructKeyExists(variables,"imageMember_put_imagepath")>
					  if(value == '#variables.imageMember_put_imagepath#' && verb === 'put'){
						content += '<option value="' + value + '" selected="selected">' + text + '</option>';
					  }
					  else{
						content += '<option value="' + value + '">' + text + '</option>';
					  }  
					<cfelse>
					  content += '<option value="' + value + '">' + text + '</option>';
					</cfif>
				  }
				  content += '</optgroup>';
				}
			  }
			  if(imageMembeimagepath.length){
				imageMembeimagepath.html(content);
			  }
			},
			error: function (jqXHR,textStatus,errorMessage) {
			  console.log('ERROR: imageMember_imagepath(): ajax',errorMessage);
			}
		  });
		}
		
		function imageCollection_get_page() {
		  var url = '#restApiEndpoint#/pages/images/' + userToken;
		  var imagecollectiongetpage = $('##imageCollection_get_page');
		  var content = '';
		  $.ajax({
			url: url,
			success: function (response) {
			  var data = response;
			  if($ajaxdataDebug){
				console.log('imageCollection_get_page(): data 1 ',data);
			  }
			  if(!$.isEmptyObject(data) && 'pages' in data && data['pages'] > 0){
				if($ajaxdataDebug){
				  console.log('imageCollection_get_page(): data 2 ',data);
				}
				for(var i = 0;i<data['pages'];i++){
				  <cfif StructKeyExists(variables,"imageCollection_get_page")>
					if((i + 1) == '#variables.imageCollection_get_page#'){
					  content += '<option value="' + (i + 1)  + '" selected="selected">' + (i + 1)  + '</option>';
					}
					else{
					  content += '<option value="' + (i + 1)  + '">' + (i + 1)  + '</option>';
					}
				  <cfelse>
					content += '<option value="' + (i + 1)  + '">' + (i + 1)  + '</option>';
				  </cfif>
				}
			  }
			  if(imagecollectiongetpage.length){
				imagecollectiongetpage.html(content);
			  }
			},
			error: function (jqXHR,textStatus,errorMessage) {
			  console.log('ERROR: imageCollection_get_page(): ajax',errorMessage);
			}
		  });
		}
		
		function imageUnapprovedCollection_get_page() {
		  var url = '#restApiEndpoint#/pages/unapproved/userid/' + userToken;
		  var imagecollectiongetpage = $('##imageUnapprovedCollection_get_page');
		  var content = '';
		  $.ajax({
			url: url,
			success: function (response) {
			  var data = response;
			  if($ajaxdataDebug){
				console.log('imageUnapprovedCollection_get_page(): data 1 ',data);
			  }
			  if(!$.isEmptyObject(data) && 'pages' in data && data['pages'] > 0){
				if($ajaxdataDebug){
				  console.log('imageUnapprovedCollection_get_page(): data 2 ',data);
				}
				for(var i = 0;i<data['pages'];i++){
				  <cfif StructKeyExists(variables,"imageUnapprovedCollection_get_page")>
					if((i + 1) == '#variables.imageUnapprovedCollection_get_page#'){
					  content += '<option value="' + (i + 1)  + '" selected="selected">' + (i + 1)  + '</option>';
					}
					else{
					  content += '<option value="' + (i + 1)  + '">' + (i + 1)  + '</option>';
					}
				  <cfelse>
					content += '<option value="' + (i + 1)  + '">' + (i + 1)  + '</option>';
				  </cfif>
				}
			  }
			  if(imagecollectiongetpage.length){
				imagecollectiongetpage.html(content);
			  }
			},
			error: function (jqXHR,textStatus,errorMessage) {
			  console.log('ERROR: imageUnapprovedCollection_get_page(): ajax',errorMessage);
			}
		  });
		}
		
		
		function imageApprovedCollection_get_page() {
		  var url = '#restApiEndpoint#/pages/approved/userid/' + userToken;
		  var imagecollectiongetpage = $('##imageApprovedCollection_get_page');
		  var content = '';
		  $.ajax({
			url: url,
			success: function (response) {
			  var data = response;
			  if($ajaxdataDebug){
				console.log('imageApprovedCollection_get_page(): data 1 ',data);
			  }
			  if(!$.isEmptyObject(data) && 'pages' in data && data['pages'] > 0){
				if($ajaxdataDebug){
				  console.log('imageApprovedCollection_get_page(): data 2 ',data);
				}
				for(var i = 0;i<data['pages'];i++){
				  <cfif StructKeyExists(variables,"imageApprovedCollection_get_page")>
					if((i + 1) == '#variables.imageApprovedCollection_get_page#'){
					  content += '<option value="' + (i + 1)  + '" selected="selected">' + (i + 1)  + '</option>';
					}
					else{
					  content += '<option value="' + (i + 1)  + '">' + (i + 1)  + '</option>';
					}
				  <cfelse>
					content += '<option value="' + (i + 1)  + '">' + (i + 1)  + '</option>';
				  </cfif>
				}
			  }
			  if(imagecollectiongetpage.length){
				imagecollectiongetpage.html(content);
			  }
			},
			error: function (jqXHR,textStatus,errorMessage) {
			  console.log('ERROR: imageApprovedCollection_get_page(): ajax',errorMessage);
			}
		  });
		}
		
		function searchCollection_get_page(loaded) {
		  var url = '#restApiEndpoint#/pages/search/' + userToken;
		  var searchcollectiongetpage = $('##searchCollection_get_page');
		  var searchcollectiongetterm = $('##searchCollection_get_term');
		  var content = '';
		  var term = '';
		  if(searchcollectiongetterm.length){
			<cfif StructKeyExists(variables,"searchCollection_get_term")>
			  if(loaded){
				term = '#variables.searchCollection_get_term#';
			  }
			  else{
				term = searchcollectiongetterm.val();
			  }
			<cfelse>
			  term = searchcollectiongetterm.val();
			</cfif>
			if($consoleDebug){
			  console.log('searchCollection_get_page(): term ',term);
			}
		  }
		  $.ajax({
			url: url,
			headers: {'term': term},
			success: function (response) {
			  var data = response;
			  if($ajaxdataDebug){
				console.log('searchCollection_get_page(): data 1 ',data);
			  }
			  if(!$.isEmptyObject(data) && 'pages' in data && data['pages'] > 0){
				if($ajaxdataDebug){
				  console.log('searchCollection_get_page(): data 2 ',data);
				}
				for(var i = 0;i<data['pages'];i++){
				  <cfif StructKeyExists(variables,"searchCollection_get_page")>
					if((i + 1) == '#variables.searchCollection_get_page#'){
					  content += '<option value="' + (i + 1)  + '" selected="selected">' + (i + 1)  + '</option>';
					}
					else{
					  content += '<option value="' + (i + 1)  + '">' + (i + 1)  + '</option>';
					}
				  <cfelse>
					content += '<option value="' + (i + 1)  + '">' + (i + 1)  + '</option>';
				  </cfif>
				}
			  }
			  if(searchcollectiongetpage.length){
				searchcollectiongetpage.html(content);
			  }
			},
			error: function (jqXHR,textStatus,errorMessage) {
			  console.log('ERROR: searchCollection_get_page(): ajax',errorMessage);
			}
		  });
		}		
		
		function tinymceArticleImageMember_delete_filename(fileid) {
		  var url = '#restApiEndpoint#/tinymcearticleimage/' + fileid;
		  var tinymcearticleimagememberdeletefilename = $('##tinymceArticleImageMember_delete_filename');
		  var content = '';
		  $.ajax({
			url: url,
			headers: {'checkDirectory':true},
			success: function (response) {
			  var data = response;
			  if($ajaxdataDebug){
				console.log('tinymceArticleImageMember_delete_filename(): data 1 ',data);
			  }
			  if(!$.isEmptyObject(data) && 'tinymceArticleImages' in data && $.isArray(data['tinymceArticleImages'])){
				if($ajaxdataDebug){
				  console.log('tinymceArticleImageMember_delete_filename(): data 2 ',data);
				}
				for(var i = 0;i<data['tinymceArticleImages'].length;i++){
				  <cfif StructKeyExists(variables,"tinymceArticleImageMember_delete_filename")>
					if(data['tinymceArticleImages'][i].toLowerCase() == '#LCase(variables.tinymceArticleImageMember_delete_filename)#'){
					  content += '<option value="' + data['tinymceArticleImages'][i].toLowerCase()  + '" selected="selected">' + data['tinymceArticleImages'][i].toLowerCase()  + '</option>';
					}
					else{
					  content += '<option value="' + data['tinymceArticleImages'][i].toLowerCase() + '">' + data['tinymceArticleImages'][i].toLowerCase() + '</option>';
					}
				  <cfelse>
					content += '<option value="' + data['tinymceArticleImages'][i].toLowerCase() + '">' + data['tinymceArticleImages'][i].toLowerCase() + '</option>';
				  </cfif>
				}
			  }
			  if(tinymcearticleimagememberdeletefilename.length){
				tinymcearticleimagememberdeletefilename.html(content);
			  }
			},
			error: function (jqXHR,textStatus,errorMessage) {
			  console.log('ERROR: tinymceArticleImageMember_delete_filename(): ajax',errorMessage);
			}
		  });
		}
		
		function imageByCategoryCollection_get_page(category) {
		  var url = '#restApiEndpoint#/pages/categories/' + category + '/' + userToken;
		  var imagebycategorycollectiongetpage = $('##imageByCategoryCollection_get_page');
		  var content = '';
		  $.ajax({
			url: url,
			success: function (response) {
			  var data = response;
			  if($ajaxdataDebug){
				console.log('imageByCategoryCollection_get_page(): data 1 ',data);
			  }
			  if(!$.isEmptyObject(data) && 'pages' in data && data['pages'] > 0){
				if($ajaxdataDebug){
				  console.log('imageByCategoryCollection_get_page(): data 2 ',data);
				}
				for(var i = 0;i<data['pages'];i++){
				  <cfif StructKeyExists(variables,"imageByCategoryCollection_get_page")>
					if((i + 1) == '#variables.imageByCategoryCollection_get_page#'){
					  content += '<option value="' + (i + 1)  + '" selected="selected">' + (i + 1)  + '</option>';
					}
					else{
					  content += '<option value="' + (i + 1)  + '">' + (i + 1)  + '</option>';
					}
				  <cfelse>
					content += '<option value="' + (i + 1)  + '">' + (i + 1)  + '</option>';
				  </cfif>
				}
			  }
			  if(imagebycategorycollectiongetpage.length){
				imagebycategorycollectiongetpage.html(content);
			  }
			},
			error: function (jqXHR,textStatus,errorMessage) {
			  console.log('ERROR: imageByCategoryCollection_get_page(): ajax',errorMessage);
			}
		  });
		}
		
		function imageByDateCollection_get_page(year,month) {
		  var url = '#restApiEndpoint#/pages/dates/' + year + '/' + month + '/' + userToken;
		  var imagebydatecollectiongetpage = $('##imageByDateCollection_get_page');
		  var content = '';
		  $.ajax({
			url: url,
			success: function (response) {
			  var data = response;
			  if($ajaxdataDebug){
				console.log('imageByDateCollection_get_page(): data 1 ',data);
			  }
			  if(!$.isEmptyObject(data) && 'pages' in data && data['pages'] > 0){
				if($ajaxdataDebug){
				  console.log('imageByDateCollection_get_page(): data 2 ',data);
				}
				for(var i = 0;i<data['pages'];i++){
				  <cfif StructKeyExists(variables,"imageByDateCollection_get_page")>
					if((i + 1) == '#variables.imageByDateCollection_get_page#'){
					  content += '<option value="' + (i + 1)  + '" selected="selected">' + (i + 1)  + '</option>';
					}
					else{
					  content += '<option value="' + (i + 1)  + '">' + (i + 1)  + '</option>';
					}
				  <cfelse>
					content += '<option value="' + (i + 1)  + '">' + (i + 1)  + '</option>';
				  </cfif>
				}
			  }
			  if(imagebydatecollectiongetpage.length){
				imagebydatecollectiongetpage.html(content);
			  }
			},
			error: function (jqXHR,textStatus,errorMessage) {
			  console.log('ERROR: imageByDateCollection_get_page(): ajax',errorMessage);
			}
		  });
		}
		
		function imageByTagCollection_get_page(tag) {
		  var url = '#restApiEndpoint#/pages/tag/' + encodeURIComponent(tag);
		  var imagebytagcollectiongetpage = $('##imageByTagCollection_get_page');
		  var content = '';
		  $.ajax({
			url: url,
			headers: {'userToken':userToken},
			success: function (response) {
			  var data = response;
			  if($ajaxdataDebug){
				console.log('imageByTagCollection_get_page(): data 1 ',data);
			  }
			  if(!$.isEmptyObject(data) && 'pages' in data && data['pages'] > 0){
				if($ajaxdataDebug){
				  console.log('imageByTagCollection_get_page(): data 2 ',data);
				}
				for(var i = 0;i<data['pages'];i++){
				  <cfif StructKeyExists(variables,"imageByTagCollection_get_page")>
					if((i + 1) == '#variables.imageByTagCollection_get_page#'){
					  content += '<option value="' + (i + 1)  + '" selected="selected">' + (i + 1)  + '</option>';
					}
					else{
					  content += '<option value="' + (i + 1)  + '">' + (i + 1)  + '</option>';
					}
				  <cfelse>
					content += '<option value="' + (i + 1)  + '">' + (i + 1)  + '</option>';
				  </cfif>
				}
			  }
			  if(imagebytagcollectiongetpage.length){
				imagebytagcollectiongetpage.html(content);
			  }
			},
			error: function (jqXHR,textStatus,errorMessage) {
			  console.log('ERROR: imageByTagCollection_get_page(): ajax',errorMessage);
			}
		  });
		}
		
		function imageByUseridCollection_get_page() {
		  var url = '#restApiEndpoint#/pages/userid/' + userToken;
		  var imagebyuseridcollectiongetpage = $('##imageByUseridCollection_get_page');
		  var content = '';
		  $.ajax({
			url: url,
			success: function (response) {
			  var data = response;
			  if($ajaxdataDebug){
				console.log('imageByUseridCollection_get_page(): data 1 ',data);
			  }
			  if(!$.isEmptyObject(data) && 'pages' in data && data['pages'] > 0){
				if($ajaxdataDebug){
				  console.log('imageByUseridCollection_get_page(): data 2 ',data);
				}
				for(var i = 0;i<data['pages'];i++){
				  <cfif StructKeyExists(variables,"imageByUseridCollection_get_page")>
					if((i + 1) == '#variables.imageByUseridCollection_get_page#'){
					  content += '<option value="' + (i + 1)  + '" selected="selected">' + (i + 1)  + '</option>';
					}
					else{
					  content += '<option value="' + (i + 1)  + '">' + (i + 1)  + '</option>';
					}
				  <cfelse>
					content += '<option value="' + (i + 1)  + '">' + (i + 1)  + '</option>';
				  </cfif>
				}
			  }
			  if(imagebyuseridcollectiongetpage.length){
				imagebyuseridcollectiongetpage.html(content);
			  }
			},
			error: function (jqXHR,textStatus,errorMessage) {
			  console.log('ERROR: imageByUseridCollection_get_page(): ajax',errorMessage);
			}
		  });
		}
		
		// document ready event
		
		$(document).ready(function() {
			
		  var theme = 'theme' in cookies ? Cookies.get('theme') : '#theme#';
		  var usermemberputtheme = $('##userMember_put_theme');
		  if(usermemberputtheme.length){
			usermemberputtheme.val(theme);
		  }
		  setElementProperties(theme);
			
		  $('##usertoken').val(userToken);
		  $('##authorization').val(authorization);
		  var userMemberDelete = false;
		  <cfif StructKeyExists(variables,"userMemberDelete") AND variables.userMemberDelete>
			$('##usertoken').val('');
			$('##authorization').val('');
			userMemberDelete = true;
		  </cfif>
		  <cfif StructKeyExists(variables,"usertoken") AND Len(Trim(variables['usertoken'])) AND StructKeyExists(variables,"authorization") AND Len(Trim(variables['authorization']))>
			if(!userMemberDelete){
			  if($('##usertoken').val().toLowerCase().trim() !== "#LCase(Trim(variables.usertoken))#" || $('##authorization').val().toLowerCase().trim() !== "#LCase(Trim(variables.authorization))#"){
				$('##user-token-warning').html('User token or API token has expired. Please resubmit the form below.');
				$('##user-token-warning').fadeIn();
				var commentMemberget = $('##commentMember-get');
				if(commentMemberget.length){
				  commentMemberget.css({'display':'none'});
				}
			  }
			}
			else{
			  $('##user-token-warning').html('User account deleted. Please create a new account.');
			  $('##user-token-warning').fadeIn();
			  var commentMemberget = $('##commentMember-get');
			  if(commentMemberget.length){
				commentMemberget.css({'display':'none'});
			  }
			}
		  </cfif>
		  
		  // animate header logo
		  
		  TweenMax.from('##logo', 1, {opacity:0, scale: 0, ease:Elastic.easeOut, delay: 1}, {opacity:1, scale: 10, ease:Elastic.easeOut, delay: 1}, 0.2);
		  
		  // show component & locate hash
		  
		  <cfif StructKeyExists(variables,"httpRequest") AND StructKeyExists(variables,"verb")>
			showComponentContainer('#variables.httpRequest#-#variables.verb#');
			window.location.hash = '#variables.httpRequest#-#variables.verb#';
		  </cfif>
		  
		  <cfif StructKeyExists(url,"httpRequest") AND StructKeyExists(url,"verb")>
			showComponentContainer('#url.httpRequest#-#url.verb#');
			window.location.hash = '#url.httpRequest#-#url.verb#';
		  </cfif>
			
		  // menu
		  
		  buildMenu();
		  
		  // event listeners
		  
		  $(document).on('click','##link-index-list-container i.fa-bars',function(event){
			$('.link-index-list').fadeToggle();
		  });
		  
		  $('div.param-container div.param-value').on('click',function(event){
			$(this).toggleClass('param-value param-value-full');
		  });
		  
		  $('div.curl-container div.curl-url').on('click',function(event){
			$(this).toggleClass('curl-url curl-url-full');
		  });
		  
		  $('##commentCollection_get_fileUuid').on('change',function(event){
			commentCollection_get_page($(this).val());
		  });
		  
		  $('##imageMember_put_fileUuid').on('change',function(event){
			imageMember_put($(this).val());
		  });
		  		  
		  commentCollection_get_page($('##commentCollection_get_fileUuid').val());
		  
		  imageMember_imagepath('post');
		  imageMember_imagepath('put');
		  
		  setTimeout(function(){
			imageMember_put($('##imageMember_put_fileUuid').val());
		  },1000);
		  
		  imageCollection_get_page();
		  
		  $('##searchCollection_get_term').on('blur',function(event){
			searchCollection_get_page(false);
		  });
		  
		  searchCollection_get_page(true);
		  
		  $('##tinymceArticleImageMember_delete_fileid').on('change',function(event){
			tinymceArticleImageMember_delete_filename($(this).val());
		  });
		  
		  tinymceArticleImageMember_delete_filename(<cfif StructKeyExists(variables,"tinymceArticleImageMember_delete_fileid")>#variables.tinymceArticleImageMember_delete_fileid#<cfelse>$('##tinymceArticleImageMember_delete_fileid').val()</cfif>);
		  
		  $('##imageByCategoryCollection_get_category').on('change',function(event){
			imageByCategoryCollection_get_page($(this).val());
		  });
		  
		  imageByCategoryCollection_get_page(<cfif StructKeyExists(variables,"imageByCategoryCollection_get_category")>'#variables.imageByCategoryCollection_get_category#'<cfelse>$('##imageByCategoryCollection_get_category').val()</cfif>);
		  
		  $('##imageByDateCollection_get_year').on('change',function(event){
			imageByDateCollection_get_page($(this).val(),$('##imageByDateCollection_get_month').val());
		  });
		  
		  $('##imageByDateCollection_get_month').on('change',function(event){
			imageByDateCollection_get_page($('##imageByDateCollection_get_year').val(),$(this).val());
		  });
		  
		  imageByDateCollection_get_page(<cfif StructKeyExists(variables,"imageByDateCollection_get_year")>#variables.imageByDateCollection_get_year#<cfelse>$('##imageByDateCollection_get_year').val()</cfif>,<cfif StructKeyExists(variables,"imageByDateCollection_get_month")>#variables.imageByDateCollection_get_month#<cfelse>$('##imageByDateCollection_get_month').val()</cfif>);
		  
		  $('##imageByTagCollection_get_tag').on('change',function(event){
			imageByTagCollection_get_page($(this).val());
		  });
		  
		  imageByTagCollection_get_page(<cfif StructKeyExists(variables,"imageByTagCollection_get_tag")>'#variables.imageByTagCollection_get_tag#'<cfelse>$('##imageByTagCollection_get_tag').val()</cfif>);
		  
		  
		  imageByUseridCollection_get_page();
		  
		  imageUnapprovedCollection_get_page()
		  
		  $('ul.link-index-list li a').on('click',function(event){
			var attr = $(this).attr('href').replace('##','');
			$('ul.link-index-list li a').removeClass('link-index-list-item-current');
			$(this).addClass('link-index-list-item-current');
			if($consoleDebug){
			  console.log('attr: ',attr);
			}
			showComponentContainer(attr);
			if($md.mobile()){
			  toggleMenu();
			}
		  });
		  
		  $('a.top').on('click',function(event){
			document.body.scrollTop = 0; // For Safari
			document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
		  });
		  
		  $('##menu').on('click touch',function(event){
			toggleMenu();
		  });
		  
		  $(document).on('click touch','##menu-overlay',function(event){
			console.log('event',event);
			toggleMenu();
		  });

		  $('.inputfile').each(function(){
			  var $input = $(this);
			  var name = $input.attr('name');
			  var $label = $input.next('label');
			  var labelVal = $label.html();
			  var imageMemberpostfilename = $('##imageMember_post_filename');
			  var tinymceArticleImageMemberpostfilename = $('##tinymceArticleImageMember_post_filename');
			  $input.on('change',function(e){
				  if($consoleDebug){
					console.log('$input: ',$input);
				  }
				  var fileName = '';
				  if( this.files && this.files.length > 1 ){
					fileName = (this.getAttribute('data-multiple-caption') || '').replace('{count}', this.files.length);
				  }
				  else if(e.target.value){
					fileName = e.target.value.split('\\').pop();
				  }
				  if(fileName){
					$label.find('span').html(fileName);
					if(name.toLowerCase() === 'imagemember_post_binaryfileobj'){
					  if(imageMemberpostfilename.length){
						imageMemberpostfilename.val(fileName);
					  }
					}
					if(name.toLowerCase() === 'tinymcearticleimagemember_post_binaryfileobj'){
					  if(tinymceArticleImageMemberpostfilename.length){
						tinymceArticleImageMemberpostfilename.val(fileName);
					  }
					}
				  }
				  else{
					$label.html(labelVal);
				  }
			  });
			  // Firefox bug fix
			  $input
			  .on('focus',function(){$input.addClass('has-focus' );})
			  .on('blur',function(){$input.removeClass('has-focus');});
		  });
		  		  
		  var imageMemberPostBinaryFileObjContainer = $('##imageMember-post-binaryFileObj-container');
		  var imageMemberPostBinaryFileObjContainerwidth = $('##imageMember-post-binaryFileObj-container-width');
		  var imageMemberPostBinaryFileObjContainershow1 = $('##imageMember-post-binaryFileObj-container-show-1');
		  var imageMemberPostBinaryFileObjContainershow2 = $('##imageMember-post-binaryFileObj-container-show-2');
		  var imageMemberPostBinaryFileObjContainershow3 = $('##imageMember-post-binaryFileObj-container-show-3');
		  var imageMemberPostBinaryFileObjContainerhide = $('##imageMember-post-binaryFileObj-container-hide');
		  var imageMemberPostBinaryFileObj = $('##img_imageMember_post_binaryFileObj');
		  
		  if(imageMemberPostBinaryFileObjContainer.length && imageMemberPostBinaryFileObjContainerwidth.length && imageMemberPostBinaryFileObjContainershow1.length && imageMemberPostBinaryFileObjContainershow2.length && imageMemberPostBinaryFileObjContainershow3.length && imageMemberPostBinaryFileObjContainerhide.length && imageMemberPostBinaryFileObj.length){
			if($consoleDebug){
			  console.log('imageMemberPostBinaryFileObj: ',imageMemberPostBinaryFileObj);
			}
			var imageMemberPostBinaryFileObjContainerwidthwidth = imageMemberPostBinaryFileObjContainerwidth.width();
			var imageMemberPostBinaryFileObjContainershowwidth = 0;
			var imageMemberPostBinaryFileObjWidth = imageMemberPostBinaryFileObj.width(); 
			var imageMemberPostBinaryFileObjHeight = imageMemberPostBinaryFileObj.height();
			if($consoleDebug){
			  console.log('imageMemberPostBinaryFileObjWidth: ',imageMemberPostBinaryFileObjWidth);
			  console.log('imageMemberPostBinaryFileObjHeight: ',imageMemberPostBinaryFileObjHeight);
			}
			var aspectratio = parseFloat(imageMemberPostBinaryFileObjWidth/imageMemberPostBinaryFileObjHeight);
			if($consoleDebug){
			  console.log('aspectratio: ',aspectratio);
			}
			var imageMemberPostBinaryFileObjContainershow2Width = imageMemberPostBinaryFileObjContainershow2.width();
			if($consoleDebug){
			  console.log('imageMemberPostBinaryFileObjContainershow2Width: ',imageMemberPostBinaryFileObjContainershow2Width);
			}
			var imageMemberPostBinaryFileObjContainershow2Height = parseInt(imageMemberPostBinaryFileObjContainershow2Width/aspectratio);
			if($consoleDebug){
			  console.log('imageMemberPostBinaryFileObjContainershow2Height: ',imageMemberPostBinaryFileObjContainershow2Height);
			}
			imageMemberPostBinaryFileObjContainershowwidth = parseInt(((imageMemberPostBinaryFileObjContainerwidthwidth - imageMemberPostBinaryFileObjContainershow2Width)-40)/2);
			if($consoleDebug){
			  console.log('imageMemberPostBinaryFileObjContainerwidthwidth: ',imageMemberPostBinaryFileObjContainerwidthwidth);
			}
			if($consoleDebug){
			  console.log('imageMemberPostBinaryFileObjContainershowwidth: ',imageMemberPostBinaryFileObjContainershowwidth);
			}
			if(!$md.mobile()){
			  imageMemberPostBinaryFileObjContainershow1.css({'width': imageMemberPostBinaryFileObjContainershowwidth + 'px','height': imageMemberPostBinaryFileObjContainershow2Height + 'px'});
			  imageMemberPostBinaryFileObjContainershow2.css({'height': imageMemberPostBinaryFileObjContainershow2Height + 'px'});
			  imageMemberPostBinaryFileObjContainershow3.css({'width': imageMemberPostBinaryFileObjContainershowwidth + 'px','height': imageMemberPostBinaryFileObjContainershow2Height + 'px'});
			  imageMemberPostBinaryFileObjContainer.css({'height': imageMemberPostBinaryFileObjContainershow2Height + 'px'});
			}
			imageMemberPostBinaryFileObjContainershow2.append(imageMemberPostBinaryFileObj);
			imageMemberPostBinaryFileObj.css({'width': '100%','height': '','opacity': 0}); 
			imageMemberPostBinaryFileObjContainer.css({'display': 'block'});			
			if(!$md.mobile()){
			  imageMemberPostBinaryFileObjContainershow1.css({'display': 'block'});
			  imageMemberPostBinaryFileObjContainershow3.css({'display': 'block'});
			}
			imageMemberPostBinaryFileObjContainershow2.css({'display': 'block'});
			TweenMax.staggerFromTo(".imageMember-post-binaryFileObj-container-show", 1, {scale:0, ease:Elastic.easeOut, opacity: 0, delay:1}, {scale:1, ease:Elastic.easeOut, opacity: 1, delay:1}, 0.2, imageMemberPostTweenMaxCompleteAll);
		  }
		  
		  function imageMemberPostTweenMaxCompleteAll(){
			TweenMax.fromTo('##img_imageMember_post_binaryFileObj', 1, {scale:0, ease:Elastic.easeOut, opacity: 0, delay:1}, {scale:1, ease:Elastic.easeOut, opacity: 1, delay:1});
		  }

		  var tinymceArticleImageMemberPostBinaryFileObjContainer = $('##tinymceArticleImageMember-post-binaryFileObj-container');
		  var tinymceArticleImageMemberPostBinaryFileObjContainerwidth = $('##tinymceArticleImageMember-post-binaryFileObj-container-width');
		  var tinymceArticleImageMemberPostBinaryFileObjContainershow1 = $('##tinymceArticleImageMember-post-binaryFileObj-container-show-1');
		  var tinymceArticleImageMemberPostBinaryFileObjContainershow2 = $('##tinymceArticleImageMember-post-binaryFileObj-container-show-2');
		  var tinymceArticleImageMemberPostBinaryFileObjContainershow3 = $('##tinymceArticleImageMember-post-binaryFileObj-container-show-3');
		  var tinymceArticleImageMemberPostBinaryFileObjContainerhide = $('##tinymceArticleImageMember-post-binaryFileObj-container-hide');
		  var tinymceArticleImageMemberPostBinaryFileObj = $('##img_tinymceArticleImageMember_post_binaryFileObj');
		  
		  if(tinymceArticleImageMemberPostBinaryFileObjContainer.length && tinymceArticleImageMemberPostBinaryFileObjContainerwidth.length && tinymceArticleImageMemberPostBinaryFileObjContainershow1.length && tinymceArticleImageMemberPostBinaryFileObjContainershow2.length && tinymceArticleImageMemberPostBinaryFileObjContainershow3.length && tinymceArticleImageMemberPostBinaryFileObjContainerhide.length && tinymceArticleImageMemberPostBinaryFileObj.length){
			if($consoleDebug){
			  console.log('tinymceArticleImageMemberPostBinaryFileObj: ',tinymceArticleImageMemberPostBinaryFileObj);
			}
			var tinymceArticleImageMemberPostBinaryFileObjContainerwidthwidth = tinymceArticleImageMemberPostBinaryFileObjContainerwidth.width();
			var tinymceArticleImageMemberPostBinaryFileObjContainershowwidth = 0;
			var tinymceArticleImageMemberPostBinaryFileObjWidth = tinymceArticleImageMemberPostBinaryFileObj.width(); 
			var tinymceArticleImageMemberPostBinaryFileObjHeight = tinymceArticleImageMemberPostBinaryFileObj.height();
			if($consoleDebug){
			  console.log('tinymceArticleImageMemberPostBinaryFileObjWidth: ',tinymceArticleImageMemberPostBinaryFileObjWidth);
			  console.log('tinymceArticleImageMemberPostBinaryFileObjHeight: ',tinymceArticleImageMemberPostBinaryFileObjHeight);
			}
			var aspectratio = parseFloat(tinymceArticleImageMemberPostBinaryFileObjWidth/tinymceArticleImageMemberPostBinaryFileObjHeight);
			if($consoleDebug){
			  console.log('aspectratio: ',aspectratio);
			}
			var tinymceArticleImageMemberPostBinaryFileObjContainershow2Width = tinymceArticleImageMemberPostBinaryFileObjContainershow2.width();
			if($consoleDebug){
			  console.log('tinymceArticleImageMemberPostBinaryFileObjContainershow2Width: ',tinymceArticleImageMemberPostBinaryFileObjContainershow2Width);
			}
			var tinymceArticleImageMemberPostBinaryFileObjContainershow2Height = parseInt(tinymceArticleImageMemberPostBinaryFileObjContainershow2Width/aspectratio);
			if($consoleDebug){
			  console.log('tinymceArticleImageMemberPostBinaryFileObjContainershow2Height: ',tinymceArticleImageMemberPostBinaryFileObjContainershow2Height);
			}
			tinymceArticleImageMemberPostBinaryFileObjContainershowwidth = parseInt(((tinymceArticleImageMemberPostBinaryFileObjContainerwidthwidth - tinymceArticleImageMemberPostBinaryFileObjContainershow2Width)-40)/2);
			if($consoleDebug){
			  console.log('tinymceArticleImageMemberPostBinaryFileObjContainerwidthwidth: ',tinymceArticleImageMemberPostBinaryFileObjContainerwidthwidth);
			}
			if($consoleDebug){
			  console.log('tinymceArticleImageMemberPostBinaryFileObjContainershowwidth: ',tinymceArticleImageMemberPostBinaryFileObjContainershowwidth);
			}
			if(!$md.mobile()){
			  tinymceArticleImageMemberPostBinaryFileObjContainershow1.css({'width': tinymceArticleImageMemberPostBinaryFileObjContainershowwidth + 'px','height': tinymceArticleImageMemberPostBinaryFileObjContainershow2Height + 'px'});
			  tinymceArticleImageMemberPostBinaryFileObjContainershow2.css({'height': tinymceArticleImageMemberPostBinaryFileObjContainershow2Height + 'px'});
			  tinymceArticleImageMemberPostBinaryFileObjContainershow3.css({'width': tinymceArticleImageMemberPostBinaryFileObjContainershowwidth + 'px','height': tinymceArticleImageMemberPostBinaryFileObjContainershow2Height + 'px'});
			  tinymceArticleImageMemberPostBinaryFileObjContainer.css({'height': tinymceArticleImageMemberPostBinaryFileObjContainershow2Height + 'px'});
			}
			tinymceArticleImageMemberPostBinaryFileObjContainershow2.append(tinymceArticleImageMemberPostBinaryFileObj);
			tinymceArticleImageMemberPostBinaryFileObj.css({'width': '100%','height': '','opacity': 0}); 
			tinymceArticleImageMemberPostBinaryFileObjContainer.css({'display': 'block'});			
			if(!$md.mobile()){
			  tinymceArticleImageMemberPostBinaryFileObjContainershow1.css({'display': 'block'});
			  tinymceArticleImageMemberPostBinaryFileObjContainershow3.css({'display': 'block'});
			}
			tinymceArticleImageMemberPostBinaryFileObjContainershow2.css({'display': 'block'});
			TweenMax.staggerFromTo(".tinymceArticleImageMember-post-binaryFileObj-container-show", 1, {scale:0, ease:Elastic.easeOut, opacity: 0, delay:1}, {scale:1, ease:Elastic.easeOut, opacity: 1, delay:1}, 0.2, tinymceArticleImageMemberPostTweenMaxCompleteAll);
		  }
		  
		  function tinymceArticleImageMemberPostTweenMaxCompleteAll(){
			TweenMax.fromTo('##img_tinymceArticleImageMember_post_binaryFileObj', 1, {scale:0, ease:Elastic.easeOut, opacity: 0, delay:1}, {scale:1, ease:Elastic.easeOut, opacity: 1, delay:1});
		  }

		  $("##imageMember_put_publisharticledate").datepicker({dateFormat: "yy-mm-dd"});
		  
		});	
		
		// anchor offset for fixed header
		
		(function(document, history, location) {
		  var HISTORY_SUPPORT = !!(history && history.pushState);
		
		  var anchorScrolls = {
			ANCHOR_REGEX: /^##[^ ]+$/,
			OFFSET_HEIGHT_PX: 84,
		
			/**
			 * Establish events, and fix initial scroll position if a hash is provided.
			 */
			init: function() {
			  this.scrollToCurrent();
			  $(window).on('hashchange', $.proxy(this, 'scrollToCurrent'));
			  $('body').on('click', 'a', $.proxy(this, 'delegateAnchors'));
			  if($consoleDebug){
				console.log('this: ',this);
			  }
			},
		
			/**
			 * Return the offset amount to deduct from the normal scroll position.
			 * Modify as appropriate to allow for dynamic calculations
			 */
			getFixedOffset: function() {
			  return this.OFFSET_HEIGHT_PX;
			},
		
			/**
			 * If the provided href is an anchor which resolves to an element on the
			 * page, scroll to it.
			 * @param  {String} href
			 * @return {Boolean} - Was the href an anchor.
			 */
			scrollIfAnchor: function(href, pushToHistory) {
			  var match, anchorOffset;
		
			  if(!this.ANCHOR_REGEX.test(href)) {
				return false;
			  }
		
			  match = document.getElementById(href.slice(1));
			  
			  if($consoleDebug){
				console.log('href: ',href);
				console.log('match: ',match);
			  }
		
			  if(match) {
				anchorOffset = $(match).offset().top - this.getFixedOffset();
				$('html, body').animate({ scrollTop: anchorOffset});
		
				// Add the state to history as-per normal anchor links
				if(HISTORY_SUPPORT && pushToHistory) {
				  history.pushState({}, document.title, location.pathname + href);
				}
			  }
		
			  return !!match;
			},
			
			/**
			 * Attempt to scroll to the current location's hash.
			 */
			scrollToCurrent: function(e) { 
			  if(this.scrollIfAnchor(window.location.hash) && e) {
				e.preventDefault();
			  }
			},
		
			/**
			 * If the click event's target was an anchor, fix the scroll position.
			 */
			delegateAnchors: function(e) {
			  var elem = e.target;
		
			  if(this.scrollIfAnchor(elem.getAttribute('href'), true)) {
				e.preventDefault();
			  }
			}
		  };
		
		  $(document).ready($.proxy(anchorScrolls, 'init'));
		})(window.document, window.history, window.location);
		
		// tinymce init

		var $tinymce_config = {
		  selector: "textarea.tinymce_textarea",
		  height: 250,
		  end_container_on_empty_block: true,
		  theme: 'modern',
		  plugins: ['link','paste','table','charmap','searchreplace','lists','advlist','textcolor','colorpicker','codesample','code','contextmenu','wordcount'],
		  skin: 'lightgray',
		  content_css: '../../tinymce/css/custom.css',
		  menubar: 'edit insert view format table tools',
		  toolbar: 'undo redo | styleselect | bold italic blockquote | alignleft aligncenter alignright alignjustify | bullist numlist indent outdent | fontselect | fontsizeselect | forecolor | backcolor | removeformat ',
		  style_formats: $style_formats,
		  preview_styles: false,
		  resize: false,
		  branding: false,
		  browser_spellcheck: true,
		  contextmenu: 'link inserttable | cell row column deletetable | textcolor',
		  contextmenu_never_use_native: true
		};
		
		tinymce.init($tinymce_config);
		
	  </script>
      
      <style>
	  
		:root {
		  --body-background: #bodybackground#;
		  --header-background: #headerbackground#;
		  --left-background: #leftbackground#;
		  --left-after-background-image: #leftafterbackgroundimage#;
		  --left-fill-placeholder-background: #leftfillplaceholderbackground#;
		  --link-index-list-item: #linkindexlistitem#;
		  --link-index-list-item-current-hover: #linkindexlistitemcurrenthover#;
		  --ripple-after-background-image: #rippleafterbackgroundimage#;
		}
	  
		body {
			background: var(--body-background);
			font-family: Arial, Helvetica, sans-serif;
			font-size: 16px;
			-webkit-appearance: none;
			margin: 0px;
		}
		
		header##header {
			position: fixed;
			display: block;
			top: 0px;
			left: 0px;
			width: 100%;
			height: 64px;
			background: var(--header-background);
			z-index: 5;
		}
		
		header div.header-container {
			position: absolute;
			display: inline-block;
			top: 16px;
			left: 50%;
			transform: translateX(-50%);
		}
		
		header div.header-container img {
			position: relative;
			top: -2px;
			width: 30px;
			margin-right: 5px;
			vertical-align: middle;
		}
		
		header div.header-container h1 {
			display: inline;
			font-size: 20px;
			margin: 0px;
			line-height: 32px;
			font-weight: normal;
			color: white;
			font-weight: 500;
			font-family: Roboto,"Helvetica Neue",sans-serif;
		}
		
		header div.header-container span {
			font-size: 20px;
			line-height: 32px;
			font-weight: normal;
			color: rgba(255,255,255,0.5);
			font-weight: normal;
			font-family: Roboto,"Helvetica Neue",sans-serif;
		}
		
		header##header i{
			display: none;
		}
		
		div.content {
			margin: 84px 0px 0px 0px;
		}
		
		a##top {
			display: block;
			width: 0px;
			height: 1px;
		}

		div.left {
			position: fixed;
			display: inline-block;
			top: 64px;
			width: 24%;
			height: 100%;
			min-width: 325px;
			min-height: 1px;
			background: var(--left-background);
			box-shadow: 0 8px 10px -5px rgba(0,0,0,.2), 0 16px 24px 2px rgba(0,0,0,.14), 0 6px 30px 5px rgba(0,0,0,.12);
			padding-bottom: 20px;
			z-index: 4;
		}
		
		div.left:after {
			content: "";
			position: absolute;
			z-index: 1;
			bottom : 0;
			left: 0;
			pointer-events: none;
			background-image: var(--left-after-background-image);
			width: 100%;
			height: 4em;
			z-index: 3;
		}
		
		header div.menu-header-desktop {
			position: absolute;
			display: block;
			width: 24%;
			min-width: 325px;
			height: 64px;
			background: none;
			padding: 16px 16px 16px 26px;
			font-family: Roboto,"Helvetica Neue",sans-serif;
			font-size: 20px;
			font-weight: 500;
			line-height: 32px;
			color: rgba(255, 255, 255, 1);
			box-sizing: border-box;
			z-index: 1;
		}
		
		div.left div.menu-header-mobile {
			display: none;
		}
		
		div.left-fill {
			position: absolute;
			width: 100%;
			top: 0px;
			left: 0px;
			overflow: visible;
			background: var(--left-background);
			box-sizing: border-box;
			z-index: 3;
		}
		
		div.left-fill ul.link-index-list li {
			padding: 0px 26px; 
		}
		
		div.left-fill ul.link-index-list li a {
			display: inline-block;
			height: 16px;
			background: var(--left-fill-placeholder-background);
			padding: 0px;
			margin-bottom: 16px;
			color: var(--left-fill-placeholder-background);
			box-sizing: border-box;
		}
		
		div.left-fill ul.link-index-list a:nth-of-type(1) {
			margin-top: 18px;
		}

		div.right {
			display: inline-block;
			width: 74%;
			padding-left: 40px;
			margin-left: 24%;
			box-sizing: border-box;
		}
		
		##link-index-list-container {
			position: relative;
			overflow: visible;
			z-index: 2;
		}
		  
		.ps__rail-y {
			background-color: var(--left-background) !important;

		}
		
		##link-index-list-inner {
			position: relative;
			overflow: auto;
			margin: 0px 0px 20px 0px;
			padding: 0px 0px 0px 0px;
		}


		.link-index-list {
			display: block;
			list-style: none;
			padding: 0px 0px 0px 0px;
		}
		
		.link-index-list li {
			position: relative;
			display: block;
			background: none;
			color: var(--link-index-list-item);
			text-align: left;
			font-weight: normal;
			border-radius: none;
			box-sizing: border-box;
			margin: 0px 0px 0px 0px;
			padding: 0px 0px 0px 0px;
		}
		
		.link-index-list li:before {
			position: static;
			content: '';
		}
		
		.link-index-list li a{
			position: relative;
			display: block;
			text-decoration: none;
			color: var(--link-index-list-item);
			font-weight: normal;
			padding: 16px 16px 16px 26px;
			background-color: var(--left-background);
			box-sizing: border-box;
		}
		
		.link-index-list li a.link-index-list-item-current{
			background:  var(--link-index-list-item-current-hover);
		}
		
		.link-index-list li a:hover{
			background: var(--link-index-list-item-current-hover);
		}

		.user-token-warning {
			display: block;
			padding: 15px;
			margin: 20px 0px 20px;
			background: coral;
			color: rgba(0, 0, 0, 0.75);
			text-align: left;
			font-weight: normal;
			border-radius: 5px;
			box-sizing: border-box;
		}
		
		label {
			display: block;
			padding: 15px;
			margin: 20px 0px 10px;
			background: rgba(0, 0, 0, 0.075);
			color: rgba(0, 0, 0, 0.75);
			text-align: left;
			font-weight: bold;
			border-radius: 5px;
			box-sizing: border-box;
		}
		
		input[type='text'], input[type='password'] {
			display: block;
			width: 100%;
			padding: 15px;
			margin: 20px 0px 10px;
			color: rgba(0, 0, 0, 0.75);
			text-align: left;
			border-radius: 5px;
			border: 1px solid rgba(0, 0, 0, 0.075);
			box-sizing: border-box;
			-webkit-appearance: none;
		}
		
		textarea {
			display: block;
			width: 100%;
			height: 250px;
			resize: vertical;
			padding: 15px;
			margin: 20px 0px 10px;
			color: rgba(0, 0, 0, 0.75);
			text-align: left;
			border-radius: 5px;
			border: 1px solid rgba(0, 0, 0, 0.075);
			box-sizing: border-box;
			-webkit-appearance: none;
		}
		
		/*code {
			background: rgba(255, 255, 255, 1);
		}*/
		
		.mce-custom-container {
			height: 352px;
			margin: 20px 0px;
		}
		
		div.select-container {
		  position: relative;
		}
		
		select {
			position: relative;
			display: block;
			width: 100%;
			padding: 15px 40px 15px 15px;
			margin: 20px 0px 10px;
			color: rgba(0, 0, 0, 0.75);
			text-align: left;
			border-radius: 5px;
			border: 1px solid rgba(0, 0, 0, 0.075);
			box-sizing: border-box;
			-webkit-appearance: none;
		}
		
		div.select-container .icon {
		  position: absolute;
		  top: 16px;
		  right: 15px;
		  color: rgba(0 ,0, 0, 0.75);
		  font-size: 16px;
		  font-weight: normal;
		  cursor: pointer;
		  z-index: 2;
		}
		
		.file-container {
		  position: relative;
		}
		
		.js .inputfile {
		  width: 0.1px;
		  height: 0.1px;
		  opacity: 0;
		  overflow: hidden;
		  position: absolute;
		  z-index: -1;
		}
		
		.inputfile + label {
		  width: 234px;
		  font-size: 1.25rem;
		  font-weight: 700;
		  text-overflow: ellipsis;
		  white-space: nowrap;
		  cursor: pointer;
		  display: inline-block;
		  overflow: hidden;
		  padding: 0.625rem 1.25rem;
		}
		
		.no-js .inputfile + label {
		  display: none;
		}
		
		.inputfile:focus + label,
		.inputfile.has-focus + label {
		  outline: 1px dotted ##000;
		  outline: -webkit-focus-ring-color auto 5px;
		}
		
		.inputfile + label svg {
		  width: 1em;
		  height: 1em;
		  vertical-align: middle;
		  fill: currentColor;
		  margin-top: -0.25em;
		  margin-right: 0.25em;
		}
		
		.inputfile-1 + label {
		  color: ##f1e5e6;
		  background-color: ##d3394c;
		  margin-bottom: 20px;
		  margin-top: 10px;
		}
		
		.inputfile-1:focus + label,
		.inputfile-1.has-focus + label,
		.inputfile-1 + label:hover {
		  background-color: ##722040;
		}
		
		div##imageMember-post-binaryFileObj-container-width, div##tinymceArticleImageMember-post-binaryFileObj-container-width {
			width: 100%;
			height: 1px;
		}
		
		div.imageMember-post-binaryFileObj-container, div.tinymceArticleImageMember-post-binaryFileObj-container {
			position: relative;
			margin: 20px 0px 0px;
			background:url('../../images/spinner-black-50.gif') no-repeat center center;
		}
		
		div.imageMember-post-binaryFileObj-container-show, div.tinymceArticleImageMember-post-binaryFileObj-container-show {
			width: 300px;
			padding: 0px;
			margin: 0px;
			border-radius: 5px;
			background: beige;
			box-sizing: border-box;
			opacity: 0;
			overflow: hidden;
		}
		
		div##imageMember-post-binaryFileObj-container-show-1, div##tinymceArticleImageMember-post-binaryFileObj-container-show-1 {		
			position: absolute;
			top: 0px;
			left: 0px;
			background: rgba(0, 0, 0, 0.075);
		}
		
		div##imageMember-post-binaryFileObj-container-show-2, div##tinymceArticleImageMember-post-binaryFileObj-container-show-2 {		
			position: absolute;
			top: 50%;
			left: 50%;
			transform: translate(-50%, -50%);
		}
		
		div##imageMember-post-binaryFileObj-container-show-3, div##tinymceArticleImageMember-post-binaryFileObj-container-show-3 {		
			position: absolute;
			top: 0px;
			right: 0px;
			background: rgba(0, 0, 0, 0.075);
		}
		
		div.imageMember-post-binaryFileObj-container-hide, div.tinymceArticleImageMember-post-binaryFileObj-container-hide {
			position: absolute;
			left: -10000px;
		}
		
		div.imageMember-post-binaryFileObj-container, div.tinymceArticleImageMember-post-binaryFileObj-container {
			width: 100%;
		}

		a.button, input[type='submit'] {
			display: inline-block;
			padding: 15px 30px;
			margin: 10px 0px 40px;
			background: orange;
			color: rgba(0, 0, 0, 0.75);
			text-align: center;
			font-weight: bold;
			border-radius: 5px;
			border: none;
			box-sizing: border-box;
			font-family: Arial, Helvetica, sans-serif;
			font-size: 16px;
			cursor: pointer;
			text-decoration: none;
			-webkit-appearance: none;
		}
		
		div.button-container {
			margin: 0px 0px 20px;
		}
		
		a.button {
			width: 113px;
			margin: 0px 0px 0px;
		}
		
		a.button.verb {
			margin-right: 10px;
		}
		
		a.button.clear {
			background: coral;
		}
		
		div.button-container {
			position: relative;
		}
		
		a.top {
			position: absolute;
			right: 0px;
			width: 47px;
			height: 47px;
			padding: 0px;
			vertical-align: top;
			background: yellowgreen;
		}
		
		a.top i {
			position: absolute;
			top: 50%;
			left: 50%;
			transform: translate(-50%, -50%);
		}
		
		table {
			margin-bottom: 20px;
		}
		
		div.components-container {
			scroll-snap-type: y mandatory;
			-webkit-overflow-scrolling: touch;
		}
		
		div.component-container-divider {
			display: none;
		}
		
		a.component-anchor {
			position: relative;
			display: block;
			height: 1px;
		}
		
		div.component-container {
			 display: none;
			 margin-top: 20px;
			 scroll-snap-align: start;
			-webkit-overflow-scrolling: touch;
		}
		
		h2 {
			position: relative;
			padding: 20px;
			margin: 20px 0px 0px;
			background: rgba(0, 0, 0, 0.25);
			color: rgba(0, 0, 0, 1);
			text-align: center;
			border-radius: 5px;
		}
		
		h2 strong {
			font-weight: bold;
		}
		
		h2 span {
			font-weight: normal;
		}
		
		h2 i {
			position: absolute;
			top: 22px;
			right: 20px;
			color: tomato;
		}
		
		div.param-container {
		  display: flex;
		  flex-flow: row wrap;
		  justify-content: space-between;
		}
		
		div.param-container div.param {
			padding: 15px;
			margin: 20px 0px 0px;
			background: lavenderBlush;
			color: rgba(0, 0, 0, 0.75);
			text-align: left;
			font-weight: bold;
			border-radius: 5px;
			
		}
		
		div.param-container div.param-title {
			width: 10%;
			text-align: center;
			margin-right: 10px;
			flex-grow: 1;
		}
		
		div.param-container div.param-value {
			width: 85%;
			background: snow;
			font-weight: normal;
			text-overflow: ellipsis;
			white-space: nowrap;
			overflow: hidden;
			word-break: break-all;
			word-wrap: break-word;
			box-sizing: border-box;
			flex-grow: 2;
			cursor: pointer;
		}
		
		div.param-container div.param-value-full {
			width: 85%;
			background: snow;
			font-weight: normal;
			text-overflow: none;
			overflow: visible;
			word-wrap: normal;
			box-sizing: border-box;
			cursor: pointer;
		}
		
		div.param-container div.param-value span.param-type {
			display: none;
			font-weight: bold;
			margin-right: 10px;
		}
		
		div.curl-container {
		  display: flex;
		  flex-flow: row wrap;
		  justify-content: space-between;
		}
		
		div.curl-container div.curl {
			padding: 15px;
			margin: 20px 0px 20px;
			background: cornsilk;
			color: rgba(0, 0, 0, 0.75);
			text-align: left;
			font-weight: bold;
			border-radius: 5px;
			
		}
		
		div.curl-container div.curl-title {
			width: 10%;
			text-align: center;
			margin-right: 10px;
			flex-grow: 1;
		}
		
		
		div.curl-container div.curl-url {
			width: 85%;
			font-weight: normal;
			text-overflow: ellipsis;
			white-space: nowrap;
			overflow: hidden;
			word-break: break-all;
			word-wrap: break-word;
			box-sizing: border-box;
			flex-grow: 2;
			cursor: pointer;
		}
		
		div.curl-container div.curl-url-full {
			width: 85%;
			font-weight: normal;
			text-overflow: none;
			overflow: visible;
			word-wrap: normal;
			box-sizing: border-box;
			cursor: pointer;
		}
		
		.hljs {
			background: rgba(0, 0, 0, 0.0125);
			border: 1px solid rgba(0, 0, 0, 0.05) !important;
			border-radius: 5px;
			padding: 20px !important;
			margin: 0px 0px 0px !important;
		}
		
		pre {
			margin-top: 0px !important;
		}
		
		span.token-container {
			color: sandyBrown;
		}
		
		span.data-type-container {
			color:##36F;
		}
		
		.tagify-container {
			height: 60px;
			margin: 20px 0px;
		}
		
		.tagify {
			display: block;
			width: 100%;
			height: 60px;
			padding: 5px;
			margin: 0px;
			color: rgba(0, 0, 0, 0.75);
			text-align: left;
			border-radius: 5px;
			border: 1px solid rgba(0, 0, 0, 0.075);
			box-sizing: border-box;
			-webkit-appearance: none;
		}
		
		.tagify__input {
			top: 5px;
			width: 200px;
			display: inline-block;
			vertical-align: top;
			padding: 5px;
		}
		
		.tagify tag > div {
			padding: 10px 15px;
			background: ##e5e5e5;
			min-height: 38px;
		}
		
		.tagify tag > div:hover, .tagify tag > div:before, .tagify tag > div, .tagify tag x:hover, .tagify tag x:before, .tagify tag x, .tagify tag x:hover+div:hover, .tagify tag x:hover+div:before, .tagify tag x:hover+div {
			-webkit-box-shadow: none !important;
			-webkit-animation: none !important;
			-webkit-transition: none !important;
			box-shadow: none !important;
			animation: none !important;
			transition: none !important;
		}
		
		.tagify__tag-text {
			padding-right: 10px;
		}
		
		.tagify__dropdown__item {
			padding: 12px;
		}
		
		.tagify__dropdown__item--active {
			background: lightYellow;
		}
		
		/*Create ripple effec*/

		.ripple {
			position: relative;
			overflow: hidden;
			transform: translate3d(0, 0, 0);
		}
		
		.ripple:after {
			content: "";
			display: block;
			position: absolute;
			width: 100%;
			height: 100%;
			top: 0;
			left: 0;
			pointer-events: none;
			background-image: var(--ripple-after-background-image);
			background-repeat: no-repeat;
			background-position: 50%;
			transform: scale(10, 10);
			opacity: 0;
			transition: transform .5s, opacity 1s;
		}
		
		.ripple:active:after {
			transform: scale(0, 0);
			opacity: .3;
			transition: 0s;
		}

		/* media queries */
		
		/* smart phones */
		
		@media only screen and (min-device-width : 320px) and (max-device-width : 480px) {
			
		  body {
			  margin: 0px 20px 20px;
			  font-size: 14px;
		  }
		  
		  div.menu-overlay {
			  position: fixed;
			  top: 0px;
			  right: 0px;
			  bottom: 0px;
			  left: 0px;
			  width: 100%;
			  height: 100%;
			  transition-duration: .4s;
			  transition-timing-function: cubic-bezier(.25,.8,.25,1);
			  transition-property: background,visibility;
			  background: none;
			  visibility: hidden;
			  cursor: pointer;
			  z-index: 6;
		  }
		  
		  div.menu-overlay-show {
			  background: rgba(189,189,189,.6);
			  visibility: visible;
		  }
		  
		  header##header i{
			  display: block !important;
			  position: absolute;
			  top: 20px;
			  left: 20px;
			  color: rgba(255, 255, 255, 1);
			  font-size: 24px;
			  cursor: pointer;
		  }
		  
		  header div.header-container span {
			  display: none;
		  }
			
		  div.content {
			  margin: 84px 0px 0px 0px;
		  }

		  div.left {
			  position: fixed;
			  display: inline-block;
			  top: 0px;
			  left: -1000px;
			  width: 80%;
			  height: 100%;
			  min-width: auto;
			  min-height: 1px;
			  background: var(--left-background);
			  box-sizing: border-box;
			  box-shadow: 0 8px 10px -5px rgba(0,0,0,.2), 0 16px 24px 2px rgba(0,0,0,.14), 0 6px 30px 5px rgba(0,0,0,.12);
			  z-index: 7;
		  }
		  
		  header div.menu-header-desktop {
			  display: none;
		  }
		  
		  div.left div.menu-header-mobile {
			  position: relative;
			  display: block;
			  width: 100%;
			  height: 64px;
			  background: var(--header-background);
			  padding: 16px;
			  font-family: Roboto,"Helvetica Neue",sans-serif;
			  font-size: 20px;
			  font-weight: 500;
			  line-height: 32px;
			  color: rgba(255, 255, 255, 1);
			  box-sizing: border-box;
			  z-index: 5;
		  }
		  
		  div.left-fill {
			  display: none;
		  }

		  div.right {
			  display: inline-block;
			  width: 100%;
			  padding-left: 0px;
			  margin-left: 0px;
			  box-sizing: border-box;
		  }

		  ##link-index-list-container {
			  position: relative;
			  overflow: visible;
			  z-index: 2;
		  }
		  
		  ##link-index-list-container:after {
			  content: "";
			  position: absolute;
			  z-index: 1;
			  bottom : 0;
			  left: 0;
			  pointer-events: none;
			  background-image: var(--left-after-background-image);
			  width: 100%;
			  height: 4em;
			  z-index: 3;
		  }
		  
		  ##link-index-list-inner {
			  position: relative;
			  overflow: auto;
			  margin: 0px 0px 20px 0px;
			  padding: 0px 0px 0px 0px;
			  -webkit-overflow-scrolling: touch;
			  z-index: 2;
		  }

		  .link-index-list li {
			  position: relative;
			  display: block;
			  background: none;
			  color: rgba(255, 255, 255, 1);
			  text-align: left;
			  font-weight: normal;
			  border-radius: none;
			  box-sizing: border-box;
			  margin: 0px 0px 0px 0px;
			  padding: 0px 0px 0px 0px;
		  }
		  
		  .link-index-list li:before {
			  position: static;
			  content: '';
		  }
		  
		  .link-index-list li a{
			  display: block;
			  text-decoration: none;
			  color: var(--link-index-list-item);
			  font-weight: normal;
			  padding: 16px;
			  background-color: var(--left-background);
		  }
		  
		  .link-index-list li a.link-index-list-item-current{
			  background:  var(--link-index-list-item-current-hover);
		  }
		  
		  .link-index-list li a:hover{
			  background:  var(--link-index-list-item-current-hover);
		  }

		  
		  .user-token-warning {
			  width: 100%;
		  }
			
		  label {
			   width: 100%;
		  }
		
		  input[type='text'], input[type='password'] {
			  width: 100%;
		  }
		  
		  textarea {
			  width: 100%;
			  height: 320px;
		  }
		  
		  .mce-custom-container {
			height: auto;
		  }
		  
		  select {
			  width: 100%;
		  }
		  
		  div.imageMember-post-binaryFileObj-container-show-1, div.imageMember-post-binaryFileObj-container-show-3, div.tinymceArticleImageMember-post-binaryFileObj-container-show-1, div.tinymceArticleImageMember-post-binaryFileObj-container-show-3 {
			  display: none;
		  }
		  
		  div.imageMember-post-binaryFileObj-container-show-2, div.tinymceArticleImageMember-post-binaryFileObj-container-show-2 {
			  width: 100%;
		  }
		  
		  div##imageMember-post-binaryFileObj-container-show-2, div##tinymceArticleImageMember-post-binaryFileObj-container-show-2 {		
			  position: static;
		  }
		  
		  a.button, input[type='submit'] {
			  font-size: 14px;
		  }
		  
		  h2 {
			  font-size: 16px;
			  padding: 15px;
		  }
		  
		  h2 strong {
			  display: inline-block;
			  max-width: 190px;
			  text-overflow: ellipsis;
			  white-space: nowrap;
			  overflow: hidden;
			  word-wrap: break-word;
			  vertical-align: top;
		  }
		  
		  h2 i {
			  top: 16px;
		  }
		  
		  div.param-container {
			  display: block;
			  width: 100%;
			  box-sizing: border-box;
		  }
		  
		  div.param-container div.param-title {
			  display: none;
		  }
		  
		  div.param-container div.param-value {
			  width: 100%;
		  }	
		  
		  div.param-container div.param-value-full {
			width: 100%;
		  }
		  
		  div.param-container div.param-value span.param-type {
			  display: inline-block;
		  }	  
		  
		  div.curl-container {
			  display: block;
			  width: 100%;
			  box-sizing: border-box;
		  }
		  
		  div.curl-container div.curl-title {
			  display: none;
		  }
		  
		  div.curl-container div.curl-url {
			  width: 100%;
		  }
		  
		  div.curl-container div.curl-url-full {
			  width: 100%;
		  }
		  
		  .tagify__input {
			width: 50px;
		  }
		
		}
	  
	  </style>
      
      <script>(function(e,t,n){var r=e.querySelectorAll("html")[0];r.className=r.className.replace(/(^|\s)no-js(\s|$)/,"$1js$2")})(document,window,0);</script>
      
    </head>
    
    <body>
    
      <header id="header" class="header">
        <div class="menu-header-desktop">Menu</div>
        <div class="header-container"><img id="logo" src="../../images/logo.png" /><h1>#request.title#</h1><span> | API Documentation</span></div>
        <cfif Len(Trim(userToken)) AND Len(Trim(authorization))>
          <i id="menu" class="material-icons">menu</i>
        </cfif>
      </header>
      
      <div class="content">

        <div class="component-container-divider" style="display:block;margin-top:20px;"></div>
        
        <div class="left" id="link-index">
          <div class="menu-header-mobile">Menu</div>
          <div class="left-fill" id="left-fill">
            <div>
              <ul class="link-index-list">
                <cfloop from="1" to="#ArrayLen(request.componentNameArray)#" index="i">
				  <cfset componentNameTitle = CapFirst(ListFirst(request.componentNameArray[i],"-"),true) & ": " & UCase(ListLast(request.componentNameArray[i],"-"))>
                  <li><a href="javascript:void(0);">#componentNameTitle#</a></li>
                </cfloop>
              </ul>
            </div>
          </div>
        </div>
        
        <div id="right" class="right">
        
          <div id="security-credentials">
        
            <h2 style="margin-top:0px;">Security Credentials</h2>
            
            <div id="user-token-warning" class="user-token-warning" style="display:none;"></div>
            
            <form name="securityCredentials" method="post" action="?">
              <label>User Token</label>
              <input type="text" name="usertoken" id="usertoken" placeholder="User Token" readonly />
              <label>API Token</label>
              <textarea name="authorization" id="authorization" placeholder="API Token" readonly>
              </textarea>
              <input type="submit" class="submit" value="Submit" />
            </form>
          
          </div>
          
          <cfif Len(Trim(userToken)) AND Len(Trim(authorization))>
  
            <CFQUERY NAME="qGetUserID" DATASOURCE="#request.domain_dsn#">
              SELECT * 
              FROM tblUserToken 
              WHERE User_token = <cfqueryparam cfsqltype="cf_sql_varchar" value="#userToken#">
            </CFQUERY>
            
            <cfset name = "">
            <cfset forename = "">
            <cfset surname = "">
            <cfset description = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.">
            <cfset email = "">
            <cfset password = "">
            
            <cfif qGetUserID.RecordCount>
              <CFQUERY NAME="qGetUser" DATASOURCE="#request.domain_dsn#">
                SELECT * 
                FROM tblUser
                WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUserID.User_ID#">
              </CFQUERY>
              <cfif qGetUser.RecordCount>
                <cfset name = qGetUser.Forename & " " & qGetUser.Surname>
                <cfset forename = qGetUser.Forename>
                <cfset surname = qGetUser.Surname>
                <cfset email = qGetUser.E_mail>
                <cfset password = "">
              </cfif>
            </cfif>
  
            <div class="components-container">
            
            <!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
            
              <!--- Comments --->
            
              <!--- CommentMember: GET --->
              
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="commentMember-get"></a>   
              <div id="commentMember-get" class="component-container">     
                <h2><strong>CommentMember:</strong> <span>GET</span></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>commentId</strong>: <span class="data-type-container">integer</span></div>
                </div>
                <cfset componentName = "commentMember">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/comment/<span class="token-container url-token"><cfif StructKeyExists(variables,"commentMember_get_commentid")>#variables.commentMember_get_commentid#<cfelse>{commentId}</cfif></span></div>
                </div>
                <form name="commentMember_get" method="post" action="?httpRequest=commentMember&verb=get">
                  <label style="margin-top:0px;">Comments</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="commentMember_get_commentid" id="commentMember_get_commentid" style="margin-bottom:20px;">
                      <CFQUERY NAME="qGetComment" DATASOURCE="#request.domain_dsn#">
                        SELECT * 
                        FROM tblComment 
                        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUserID.User_ID#"> 
                        ORDER BY Submission_date DESC
                      </CFQUERY>
                      <cfif qGetComment.RecordCount>
                        <cfloop query="qGetComment">
                          <option class="ellipsis" value="#qGetComment.Comment_ID#"<cfif StructKeyExists(variables,"commentMember_get_commentid") AND CompareNoCase(qGetComment.Comment_ID,variables.commentMember_get_commentid) EQ 0> selected="selected"</cfif>>#AbbreviateString(qGetComment.Comment,50)#</option>
                        </cfloop>
                      </cfif>
                    </select>
                  </div>
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"commentMember") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0 AND StructKeyExists(variables,"commentMember_get_commentid")>
                  <cfset httpRequest$ = restApiService.CommentMember(commentId=variables.commentMember_get_commentid,verb=verb)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.commentMember_get.submit();">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>
              </div>
              
                <!--- CommentMember: POST --->
        
                <cfset userid = qGetUserID.User_ID>
                <cfset replyToCommentid = 0>
                <div class="component-container-divider"></div>
                <a class="component-anchor" name="commentMember-post"></a> 
                <div id="commentMember-post" class="component-container">         
                  <h2><strong>CommentMember:</strong> <span>POST</span><i class="fa fa-lock"></i></h2>
                  <div class="param-container">
                    <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>commentId</strong>: <span class="data-type-container">integer</span></div>
                  </div>
                  <cfset componentName = "commentMember">
                  <cfset funcName = "post">
                  <cfinclude template="../requestData.cfm">
                  <div class="curl-container">
                    <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/comment/<span class="token-container url-token">0</span></div>
                  </div>
                  <form name="commentMember_post" method="post" action="?httpRequest=commentMember&verb=post">
                    <label style="margin-top:0px;">Comment</label>
                    <input type="text" name="commentMember_post_comment" id="commentMember_post_comment" placeholder="Comment" value="<cfif StructKeyExists(variables,"commentMember_post_comment")>#variables.commentMember_post_comment#</cfif>" />
                    <label>Images</label>
                    <div class="select-container">
                      <i class="fa fa-arrow-circle-down icon"></i>
                      <select name="commentMember_post_fileUuid" id="commentMember_post_fileUuid" style="margin-bottom:20px;">
                        <CFQUERY NAME="qGetFileUuid" DATASOURCE="#request.domain_dsn#">
                          SELECT * 
                          FROM tblFile INNER JOIN tblComment ON tblFile.File_ID = tblComment.File_ID
                          WHERE tblFile.User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUserID.User_ID#"> 
                          GROUP BY tblFile.File_ID 
                          ORDER BY tblFile.Submission_date DESC
                        </CFQUERY>
                        <cfif qGetFileUuid.RecordCount>
                          <cfloop query="qGetFileUuid">
                            <option value="#qGetFileUuid.File_uuid#"<cfif StructKeyExists(variables,"commentMember_post_fileUuid") AND CompareNoCase(qGetFileUuid.File_uuid,variables.commentMember_post_fileUuid) EQ 0> selected="selected"</cfif>>#qGetFileUuid.Title#</option>
                          </cfloop>
                        </cfif>
                      </select>
                    </div>
                  </form>
                  <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"commentMember") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"post") EQ 0 AND StructKeyExists(variables,"commentMember_post_fileUuid") AND StructKeyExists(variables,"commentMember_post_comment")>
                    <cfset httpRequest$ = restApiService.CommentMember(commentId=0,fileUuid=variables.commentMember_post_fileUuid,userid=userid,comment=variables.commentMember_post_comment,replyToCommentid=replyToCommentid,authorization=authorization,userToken=userToken,verb=verb)>
                    <cfinclude template="../http-request-to-json.cfm">
                    <cfinclude template="../delete-request-vars.cfm">
                  </cfif>
                  <div class="button-container"><a class="button verb" href="javascript:document.commentMember_post.submit();">POST</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>
                </div>
              
                <!--- CommentMember: DELETE --->
        
                <div class="component-container-divider"></div>
                <a class="component-anchor" name="commentMember-delete"></a>   
                <div id="commentMember-delete" class="component-container">       
                  <h2><strong>CommentMember:</strong> <span>DELETE</span><i class="fa fa-lock"></i></h2>
                  <div class="param-container">
                    <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>commentId</strong>: <span class="data-type-container">integer</span></div>
                  </div>
                  <cfset componentName = "commentMember">
                  <cfset funcName = "delete">
                  <cfinclude template="../requestData.cfm">
                  <div class="curl-container">
                    <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/comment/<span class="token-container url-token"><cfif StructKeyExists(variables,"commentMember_delete_commentid")>#variables.commentMember_delete_commentid#<cfelse>{commentId}</cfif></span></div>
                  </div>
                  <form name="commentMember_delete" method="post" action="?httpRequest=commentMember&verb=delete">
                    <label style="margin-top:0px;">Comments</label>
                    <div class="select-container">
                      <i class="fa fa-arrow-circle-down icon"></i>
                      <select name="commentMember_delete_commentid" id="commentMember_delete_commentid" style="margin-bottom:20px;">
                        <CFQUERY NAME="qGetComment" DATASOURCE="#request.domain_dsn#">
                          SELECT * 
                          FROM tblComment 
                          WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUserID.User_ID#"> 
                          ORDER BY Submission_date DESC
                        </CFQUERY>
                        <cfif qGetComment.RecordCount>
                          <cfloop query="qGetComment">
                            <option class="ellipsis" value="#qGetComment.Comment_ID#"<cfif StructKeyExists(variables,"commentMember_delete_commentid") AND CompareNoCase(qGetComment.Comment_ID,variables.commentMember_delete_commentid) EQ 0> selected="selected"</cfif>>#AbbreviateString(qGetComment.Comment,50)#</option>
                          </cfloop>
                        </cfif>
                      </select>
                    </div>
                  </form>
                  <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"commentMember") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"delete") EQ 0 AND StructKeyExists(variables,"commentMember_delete_commentid")>
                    <cfset httpRequest$ = restApiService.CommentMember(commentId=variables.commentMember_delete_commentid,authorization=authorization,userToken=userToken,verb=verb)>
                    <cfinclude template="../http-request-to-json.cfm">
                    <cfinclude template="../delete-request-vars.cfm">
                  </cfif>
                  <div class="button-container"><a class="button verb" href="javascript:document.commentMember_delete.submit();">DELETE</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>
                </div>
              
              <!--- CommentCollection: GET --->
              
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="commentCollection-get"></a> 
              <div id="commentCollection-get" class="component-container">       
                <h2><strong>CommentCollection:</strong> <span>GET</span></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>fileUuid</strong>: <span class="data-type-container">string</span></div>
                </div>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>page</strong>: <span class="data-type-container">integer</span></div>
                </div>
                <cfset componentName = "commentCollection">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/comments/<span class="token-container url-token"><cfif StructKeyExists(variables,"commentCollection_get_fileUuid")>#variables.commentCollection_get_fileUuid#<cfelse>{fileUuid}</cfif></span>/<span class="token-container url-token"><cfif StructKeyExists(variables,"commentCollection_get_page")>#variables.commentCollection_get_page#<cfelse>{page}</cfif></span></div>
                </div>
                <form name="commentCollection_get" method="post" action="?httpRequest=commentCollection&verb=get">
                  <label style="margin-top:0px;">Pages</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="commentCollection_get_page" id="commentCollection_get_page">
                    </select>
                  </div>
                  <label>Images</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="commentCollection_get_fileUuid" id="commentCollection_get_fileUuid" style="margin-bottom:20px;">
                      <CFQUERY NAME="qGetFileUuid" DATASOURCE="#request.domain_dsn#">
                        SELECT * 
                        FROM tblFile INNER JOIN tblComment ON tblFile.File_ID = tblComment.File_ID
                        WHERE tblFile.User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUserID.User_ID#"> 
                        GROUP BY tblFile.File_ID 
                        ORDER BY tblFile.Submission_date DESC
                      </CFQUERY>
                      <cfif qGetFileUuid.RecordCount>
                        <cfloop query="qGetFileUuid">
                          <option value="#qGetFileUuid.File_uuid#"<cfif StructKeyExists(variables,"commentCollection_get_fileUuid") AND CompareNoCase(qGetFileUuid.File_uuid,variables.commentCollection_get_fileUuid) EQ 0> selected="selected"</cfif>>#qGetFileUuid.Title#</option>
                        </cfloop>
                      </cfif>
                    </select>
                  </div>
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"commentCollection") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0 AND StructKeyExists(variables,"commentCollection_get_fileUuid") AND StructKeyExists(variables,"commentCollection_get_page")>
                  <cfset httpRequest$ = restApiService.CommentCollection(fileUuid=variables.commentCollection_get_fileUuid,page=commentCollection_get_page)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.commentCollection_get.submit();">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>
              </div>
              <!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
              
              
              <!--- Images --->
              
              
              <!--- ImageMember: GET --->
              
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="imageMember-get"></a>  
              <div id="imageMember-get" class="component-container">      
                <h2><strong>ImageMember:</strong> <span>GET</span></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>fileUuid</strong>: <span class="data-type-container">string</span></div>
                </div>
                <cfset componentName = "imageMember">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/image/<span class="token-container url-token"><cfif StructKeyExists(variables,"imageMember_get_fileUuid")>#variables.imageMember_get_fileUuid#<cfelse>{fileUuid}</cfif></span></div>
                </div>
                <form name="imageMember_get" method="post" action="?httpRequest=imageMember&verb=get">
                  <label style="margin-top:0px;">Images</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="imageMember_get_fileUuid" id="imageMember_get_fileUuid" style="margin-bottom:20px;">
                      <CFQUERY NAME="qGetFileUuid" DATASOURCE="#request.domain_dsn#">
                        SELECT * 
                        FROM tblFile 
                        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUserID.User_ID#"><cfif StructKeyExists(variables,"imageMember_delete_fileUuid")> AND File_uuid <> <cfqueryparam cfsqltype="cf_sql_varchar" value="#variables['imageMember_delete_fileUuid']#"></cfif> 
                        ORDER BY Submission_date DESC
                      </CFQUERY>
                      <cfif qGetFileUuid.RecordCount>
                        <cfloop query="qGetFileUuid">
                          <option value="#qGetFileUuid.File_uuid#"<cfif StructKeyExists(variables,"imageMember_get_fileUuid") AND CompareNoCase(qGetFileUuid.File_uuid,variables.imageMember_get_fileUuid) EQ 0> selected="selected"</cfif>>#qGetFileUuid.Title#</option>
                        </cfloop>
                      </cfif>
                    </select>
                  </div>
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"imageMember") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0 AND StructKeyExists(variables,"imageMember_get_fileUuid")>
                  <cfset httpRequest$ = restApiService.ImageMember(fileUuid=variables.imageMember_get_fileUuid,userToken=userToken,verb=verb)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.imageMember_get.submit();">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>
              </div>
              
              <!--- ImageMember: POST --->
              
              <cfset article = "">
              <cfset tags = "">
              <cfset publishArticleDate = DateFormat(Now(),"YYYY-MM-DD") & "T" & TimeFormat(Now(),"HH:mm:ss")>
              <cfset tinymceArticleDeletedImages = "">
              <cfset contentLength = Val(CGI.CONTENT_LENGTH)>
              <cfset cfid = "">
              <cfset cftoken = "">
              <cfset uploadType = "gallery">
              <cfset contentType = testImageContentType>
              <cfif StructKeyExists(form,"imageMember_post_filename")>
                <cfset imageMember_post_filename = form.imageMember_post_filename>
              </cfif>
              <cfif StructKeyExists(form,"imageMember_post_imagepath")>
                <cfset imageMember_post_imagepath = form.imageMember_post_imagepath>
              </cfif>
              <cfif StructKeyExists(form,"imageMember_post_name")>
                <cfset imageMember_post_name = form.imageMember_post_name>
              </cfif>
              <cfif StructKeyExists(form,"imageMember_post_title")>
                <cfset imageMember_post_title = form.imageMember_post_title>
              </cfif>
              <cfif StructKeyExists(form,"imageMember_post_description")>
                <cfset imageMember_post_description = form.imageMember_post_description>
              </cfif>
              <cfif StructKeyExists(form,"imageMember_post_uploadtype")>
                <cfset imageMember_post_uploadtype = form.imageMember_post_uploadtype>
              </cfif>
              <cfif StructKeyExists(url,"httpRequest")>
                <cfset httpRequest = url.httpRequest>
              </cfif>
              <cfif StructKeyExists(url,"verb")>
                <cfset verb = url.verb>
              </cfif>
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="imageMember-post"></a>
              <div id="imageMember-post" class="component-container">
                <h2><strong>ImageMember:</strong> <span>POST</span><i class="fa fa-lock"></i></h2>
                <div id="imageMember-post-binaryFileObj-container-width"></div>
                <div id="imageMember-post-binaryFileObj-container" class="imageMember-post-binaryFileObj-container" style="display:none;">
                  <div id="imageMember-post-binaryFileObj-container-show-1" class="imageMember-post-binaryFileObj-container-show" style="display:none;"></div>
                  <div id="imageMember-post-binaryFileObj-container-show-2" class="imageMember-post-binaryFileObj-container-show" style="display:none;"></div>
                  <div id="imageMember-post-binaryFileObj-container-show-3" class="imageMember-post-binaryFileObj-container-show" style="display:none;"></div>
                </div>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>fileUuid</strong>: <span class="data-type-container">string</span></div>
                </div>
                <cfset componentName = "imageMember">
                <cfset funcName = "post">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/image/<span class="token-container url-token">0</span></div>
                </div>
                <form name="imageMember_post" method="post" action="?httpRequest=imageMember&verb=post" enctype="multipart/form-data">
                  <label style="margin-top:0px;">Filename</label>
                  <input type="text" name="imageMember_post_filename" id="imageMember_post_filename" placeholder="Filename" value="<cfif StructKeyExists(variables,"imageMember_post_filename")>#variables.imageMember_post_filename#</cfif>" readonly />
                  <label>Image Path</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="imageMember_post_imagepath" id="imageMember_post_imagepath">
                    </select>
                  </div>
                  <label>Name</label>
                  <input type="text" name="imageMember_post_name" id="imageMember_post_name" placeholder="Name" value="<cfif StructKeyExists(variables,"imageMember_post_name")>#variables.imageMember_post_name#</cfif>"  />
                  <label>Title</label>
                  <input type="text" name="imageMember_post_title" id="imageMember_post_title" placeholder="Title" value="<cfif StructKeyExists(variables,"imageMember_post_title")>#variables.imageMember_post_title#</cfif>" />
                  <label>Description</label>
                  <textarea name="imageMember_post_description" id="imageMember_post_description" placeholder="Description"><cfif StructKeyExists(variables,"imageMember_post_description")>#variables.imageMember_post_description#</cfif></textarea>
                  <label>Tags</label>
                  <div class="tagify-container">
                    <input type="hidden" name="imageMember_post_tags" id="imageMember_post_tags" class="imageMember_post_tags" />
                  </div>
                  <script type="text/javascript">
                    var tagifyimagememberpostttagsinput = document.querySelector('##imageMember_post_tags');
                    $tagifyimagememberposttags = new Tagify(tagifyimagememberpostttagsinput,{
                      delimiters: $tagifyConfig['delimiters'],
                      maxTags: $tagifyConfig['maxTags'],
                      whitelist: [],
                      dropdown: {
                        enabled: $tagifyConfig['enabled'],
                        maxItems: $tagifyConfig['maxItems']
                      }
                    });
                    <cfif Len(Trim(imagememberposttagslist))>
                      if($tagifyimagememberposttags){
                        var tagifyimagememberposttags = tagsToList('#imagememberposttagslist#');
                        $tagifyimagememberposttags.addTags(tagifyimagememberposttags);
                      }
                    </cfif>
                    $tagifyimagememberposttags.on('input', tagifyimagememberposttagsOnInput);
                    
                  </script>
                  <label>Upload Type</label>
                  <input type="text" name="imageMember_post_uploadtype" id="imageMember_post_uploadtype" placeholder="Upload Type" value="<cfif StructKeyExists(variables,"imageMember_post_uploadtype")>#variables.imageMember_post_uploadtype#<cfelse>#uploadType#</cfif>" readonly />
                  <label>Choose File</label>
                  <div class="file-container">
                    <input type="file" name="imageMember_post_binaryfileobj" id="imageMember_post_binaryfileobj" class="js inputfile inputfile-1" data-multiple-caption="{count} files selected" placeholder="Choose File" />
                    <label for="imageMember_post_binaryfileobj"><svg xmlns="http://www.w3.org/2000/svg" width="20" height="17" viewBox="0 0 20 17"><path d="M10 0l-5.2 4.9h3.3v5.1h3.8v-5.1h3.3l-5.2-4.9zm9.3 11.5l-3.2-2.1h-2l3.4 2.6h-3.5c-.1 0-.2.1-.2.1l-.8 2.3h-6l-.8-2.2c-.1-.1-.1-.2-.2-.2h-3.6l3.4-2.6h-2l-3.2 2.1c-.4.3-.7 1-.6 1.5l.6 3.1c.1.5.7.9 1.2.9h16.3c.6 0 1.1-.4 1.3-.9l.6-3.1c.1-.5-.2-1.2-.7-1.5z"/></svg> <span>Choose a file&hellip;</span></label>
                  </div>
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"imageMember") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"post") EQ 0 AND StructKeyExists(variables,"imageMember_post_filename") AND StructKeyExists(variables,"imageMember_post_imagepath") AND StructKeyExists(variables,"imageMember_post_name") AND StructKeyExists(variables,"imageMember_post_title") AND StructKeyExists(variables,"imageMember_post_description") AND StructKeyExists(variables,"imageMember_post_uploadtype") AND Len(Trim(variables.imageMember_post_filename)) AND Len(Trim(variables.imageMember_post_imagepath)) AND Len(Trim(variables.imageMember_post_name)) AND Len(Trim(variables.imageMember_post_description))>
                  <cfif StructKeyExists(url,"httpRequest") AND CompareNoCase(url['httpRequest'],"imageMember") EQ 0 AND StructKeyExists(url,"verb") AND CompareNoCase(url['verb'],"post") EQ 0>
                    <cffile action="upload" fileField="imageMember_post_binaryfileobj" destination="#GetTempDirectory()#"> 
                    <cffile action="readBinary" file="#GetTempDirectory()#\#imageMember_post_filename#" variable="imageMember_post_binaryfileobj_data">
                    <cflock name="delete_file" type="exclusive" timeout="30">
                      <cffile action="delete"  file="#GetTempDirectory()#\#imageMember_post_filename#" />
                    </cflock>
                    <cfset session['imageMember_post_binaryfileobj_data'] = imageMember_post_binaryfileobj_data>
                    <cfif StructKeyExists(url,"httpRequest") AND StructKeyExists(url,"verb")>
                      <cfset StructAppend(session,url)>
                      <cfset StructAppend(session,form)>
                      <cflocation url="../components/restApiService.cfm" addtoken="no" />
                    </cfif>
                  </cfif>
                  <cfif StructKeyExists(session,"imageMember_post_binaryfileobj_data")>
                    <cfset fileExtension = "">
                    <cfif Len(Trim(variables.imageMember_post_filename))>
                      <cfset fileExtension = ListLast(variables.imageMember_post_filename,".")>
                      <cfset ContentType = "image/" & fileExtension>
                    </cfif>
                    <cfif Len(Trim(imagememberposttagslist))>
                      <cfset tags = imagememberposttagslist>
                    </cfif>
                    <cfif ListFindNoCase("gif,png,jpg,jpeg",fileExtension) AND IsBinary(session['imageMember_post_binaryfileobj_data'])>
                      <cfset httpRequest$ = restApiService.ImageMember(fileUuid=0,fileName=variables.imageMember_post_filename,imagePath=variables.imageMember_post_imagepath,name=variables.imageMember_post_name,title=variables.imageMember_post_title,description=variables.imageMember_post_description,article=article,tags=tags,publishArticleDate=publishArticleDate,tinymceArticleDeletedImages=tinymceArticleDeletedImages,fileExtension=fileExtension,contentLength=contentLength,cfid=cfid,cftoken=cftoken,uploadType=variables.imageMember_post_uploadtype,ContentType=ContentType,binaryFileObj=session['imageMember_post_binaryfileobj_data'],authorization=authorization,userToken=userToken,verb=verb)>
                      <cfinclude template="../http-request-to-json.cfm">
                      <cfset filename = "">
                      <cfif StructKeyExists(filecontent,"imagePath")>
                        <cfset filename = ListLast(filecontent['imagePath'],"/")>
                      </cfif>
                      <cfset imagefilepath = request.filepath & ReplaceNoCase(variables.imageMember_post_imagepath,"/","\","ALL") & "\" & filename>
                      <cfset error = false>
                      <cfif FileExists(imagefilepath)>
                        <cfset width = 0> 
                        <cfset height = 0>
                        <cftry>
                          <cfimage source="#imagefilepath#" name="img_imageMember_post_binaryFileObj_data">
                          <cfset width = Val(ImageGetWidth(img_imageMember_post_binaryFileObj_data))> 
                          <cfset height = Val(ImageGetHeight(img_imageMember_post_binaryFileObj_data))>
                          <cfcatch>
                            <cfset error = true>
                          </cfcatch>
                        </cftry>
                        <cfif NOT error>
                          <div id="imageMember-post-binaryFileObj-container-hide" class="imageMember-post-binaryFileObj-container-hide">
                            <cfset imgsrc = request.uploadfolder & variables.imageMember_post_imagepath & "/" & filename>
                            <img id="img_imageMember_post_binaryFileObj" src="#imgsrc#"<cfif width AND height> style="width:#width#px;height:#height#px;"</cfif> />
                          </div>
                        </cfif>
                      </cfif>
                    </cfif>
                    <cfif StructKeyExists(session,"imageMember_post_binaryfileobj_data")>
                      <cfset variables['imageMember_post_binaryfileobj_data'] = session['imageMember_post_binaryfileobj_data']>
                      <cfset StructDelete(session,'imageMember_post_binaryfileobj_data')>
                    </cfif>
                  </cfif>
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.imageMember_post.submit();">POST</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>
              </div>
              
              <!--- ImageMember: PUT --->
              
              <CFQUERY NAME="qGetFileUuid" DATASOURCE="#request.domain_dsn#">
                SELECT * 
                FROM tblFile 
                WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUserID.User_ID#"><cfif StructKeyExists(variables,"imageMember_delete_fileUuid")> AND File_uuid <> <cfqueryparam cfsqltype="cf_sql_varchar" value="#variables['imageMember_delete_fileUuid']#"></cfif>
                ORDER BY Submission_date DESC
              </CFQUERY>
              
              <cfset fileUuid = "">
              <cfset imagePath = "">
              <cfset name = "">
              <cfset title = "">
              <cfset description = "">
              <cfset article = "">
              <cfset tags = "">
              <cfset publishArticleDate = DateFormat(Now(),"YYYY-MM-DD") & "T" & TimeFormat(Now(),"HH:mm:ss")>
              
              <cfif qGetFileUuid.RecordCount>
                <cfset fileUuid = qGetFileUuid.File_uuid>
                <cfset imagePath = qGetFileUuid.ImagePath>
                <cfset name = qGetFileUuid.Author>
                <cfset title = qGetFileUuid.Title>
                <cfset description = qGetFileUuid.Description>
                <cfset article = qGetFileUuid.Article>
                <cfset tags = qGetFileUuid.Tags>
                <cfif Len(Trim(qGetFileUuid.Publish_article_date))>
                  <cfset publishArticleDate = DateFormat(qGetFileUuid.Publish_article_date,"YYYY-MM-DD") & "T" & TimeFormat(qGetFileUuid.Publish_article_date,"HH:mm:ss")>
                </cfif>
              </cfif>
  
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="imageMember-put"></a>  
              <div id="imageMember-put" class="component-container">     
                <h2><strong>ImageMember:</strong> <span>PUT</span><i class="fa fa-lock"></i></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>fileUuid</strong>: <span class="data-type-container">string</span></div>
                </div>
                <cfset componentName = "imageMember">
                <cfset funcName = "put">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/image/<span class="token-container url-token"><cfif StructKeyExists(variables,"imageMember_put_fileUuid")>#variables.imageMember_put_fileUuid#<cfelse><cfif Len(Trim(fileUuid))>#fileUuid#<cfelse>{fileUuid}</cfif></cfif></span></div>
                </div>
                <form name="imageMember_put" method="post" action="?httpRequest=imageMember&verb=put">
                  <label style="margin-top:0px;">Images</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="imageMember_put_fileUuid" id="imageMember_put_fileUuid" autocomplete="off">
                      <cfif qGetFileUuid.RecordCount>
                        <cfloop query="qGetFileUuid">
                          <option value="#qGetFileUuid.File_uuid#"<cfif StructKeyExists(variables,"imageMember_put_fileUuid") AND CompareNoCase(qGetFileUuid.File_uuid,variables.imageMember_put_fileUuid) EQ 0> selected="selected"<cfelse><cfif CompareNoCase(qGetFileUuid.File_uuid,fileUuid) EQ 0> selected="selected"</cfif></cfif>>#qGetFileUuid.Title#</option>
                        </cfloop>
                      </cfif>
                    </select>
                  </div>
                  <label>Image Path</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="imageMember_put_imagepath" id="imageMember_put_imagepath">
                    </select>
                  </div>
                  <label>Name</label>
                  <input type="text" name="imageMember_put_name" id="imageMember_put_name" placeholder="Name" value="<cfif StructKeyExists(variables,"imageMember_put_name")>#variables.imageMember_put_name#<cfelse>#name#</cfif>"  />
                  <label>Title</label>
                  <input type="text" name="imageMember_put_title" id="imageMember_put_title" placeholder="Title" value="<cfif StructKeyExists(variables,"imageMember_put_title")>#variables.imageMember_put_title#<cfelse>#title#</cfif>" />
                  <label>Description</label>
                  <textarea name="imageMember_put_description" id="imageMember_put_description" placeholder="Description"><cfif StructKeyExists(variables,"imageMember_put_description")>#variables.imageMember_put_description#<cfelse>#description#</cfif></textarea>
                  <label>Article</label>
                  <div class="mce-custom-container">
                    <textarea name="imageMember_put_article" id="imageMember_put_article" placeholder="Article" class="tinymce_textarea"><cfif StructKeyExists(variables,"imageMember_put_article")>#variables.imageMember_put_article#<cfelse>#article#</cfif></textarea>
                  </div>
                  <label>Tags</label>
                  <div class="tagify-container">
                    <input type="hidden" name="imageMember_put_tags" id="imageMember_put_tags" class="imageMember_put_tags" />
                  </div>
                  <label>Publish Article Date</label>
                  <input type="text" name="imageMember_put_publisharticledate" id="imageMember_put_publisharticledate" placeholder="Publish Article Date" value="<cfif StructKeyExists(variables,"imageMember_put_publisharticledate")>#variables.imageMember_put_publisharticledate#<cfelse>#publishArticleDate#</cfif>" readonly style="margin-bottom:20px;" />
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"imageMember") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"put") EQ 0 AND StructKeyExists(variables,"imageMember_put_fileUuid") AND StructKeyExists(variables,"imageMember_put_imagepath") AND StructKeyExists(variables,"imageMember_put_name") AND StructKeyExists(variables,"imageMember_put_title") AND StructKeyExists(variables,"imageMember_put_description") AND Len(Trim(variables.imageMember_put_imagepath)) AND Len(Trim(variables.imageMember_put_name)) AND Len(Trim(variables.imageMember_put_title)) AND Len(Trim(variables.imageMember_put_description))>
                  <cfif StructKeyExists(variables,"imageMember_put_article")>
                    <cfset article = variables.imageMember_put_article>
                  </cfif>
                  <cfset tags = "">
                  <cfif Len(Trim(imagememberputtagslist))>
                    <cfset tags = imagememberputtagslist>
                  </cfif>
                  <cfif StructKeyExists(variables,"imageMember_put_publisharticledate")>
                    <cfset publishArticleDate = variables.imageMember_put_publisharticledate & "T" & TimeFormat(Now(),"HH:mm:ss")>
                  </cfif>
                  <cfset httpRequest$ = restApiService.ImageMember(fileUuid=variables.imageMember_put_fileUuid,imagePath=variables.imageMember_put_imagepath,name=variables.imageMember_put_name,title=variables.imageMember_put_title,description=variables.imageMember_put_description,article=article,tags=tags,publishArticleDate=publishArticleDate,authorization=authorization,userToken=userToken,verb=verb)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.imageMember_put.submit();">PUT</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>
              </div>
              
              <!--- ImageMember: DELETE --->
              
              <CFQUERY NAME="qGetFileUuid" DATASOURCE="#request.domain_dsn#">
                SELECT * 
                FROM tblFile 
                WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUserID.User_ID#"> 
                ORDER BY Submission_date DESC
              </CFQUERY>
              
              <cfset fileUuid = "">
              <cfif qGetFileUuid.RecordCount>
                <cfset fileUuid = qGetFileUuid.File_uuid>
              </cfif>
              
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="imageMember-delete"></a>  
              <div id="imageMember-delete" class="component-container">      
                <h2><strong>ImageMember:</strong> <span>DELETE</span><i class="fa fa-lock"></i></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>fileUuid</strong>: <span class="data-type-container">string</span></div>
                </div>
                <cfset componentName = "imageMember">
                <cfset funcName = "delete">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/image/<span class="token-container url-token"><cfif StructKeyExists(variables,"imageMember_delete_fileUuid")>#variables.imageMember_delete_fileUuid#<cfelse><cfif Len(Trim(fileUuid))>#fileUuid#<cfelse>{fileUuid}</cfif></cfif></span></div>
                </div>
                <form name="imageMember_delete" method="post" action="?httpRequest=imageMember&verb=delete">
                  <label style="margin-top:0px;">Images</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="imageMember_delete_fileUuid" id="imageMember_delete_fileUuid" style="margin-bottom:20px;">
                      <cfif qGetFileUuid.RecordCount>
                        <cfloop query="qGetFileUuid">
                          <option value="#qGetFileUuid.File_uuid#"<cfif StructKeyExists(variables,"imageMember_delete_fileUuid") AND CompareNoCase(qGetFileUuid.File_uuid,variables.imageMember_delete_fileUuid) EQ 0> selected="selected"<cfelse><cfif Len(Trim(fileUuid)) AND CompareNoCase(qGetFileUuid.File_uuid,fileUuid) EQ 0> selected="selected"</cfif></cfif>>#qGetFileUuid.Title#</option>
                        </cfloop>
                      </cfif>
                    </select>
                  </div>
                </form>
                <cftry>
                  #form#
                  <cfcatch>
                  </cfcatch>
                </cftry>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"imageMember") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"delete") EQ 0 AND StructKeyExists(variables,"imageMember_delete_fileUuid")>
                  <cfset httpRequest$ = restApiService.ImageMember(fileUuid=variables.imageMember_delete_fileUuid,authorization=authorization,userToken=userToken,verb=verb)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.imageMember_delete.submit();">DELETE</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>
              </div>
              
              <CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
                SELECT * 
                FROM tblFile
                ORDER BY Submission_Date DESC
                LIMIT 1
              </CFQUERY>
              
              <cfset fileId = 0>
              <cfset fileUuid = "">
              
              <cfif qGetFile.RecordCount>
                <cfset fileId = qGetFile.File_ID>
                <cfset fileUuid = qGetFile.File_uuid>
              </cfif>
              
              <!--- ImageCollection: GET --->
              
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="imageCollection-get"></a> 
              <div id="imageCollection-get" class="component-container">       
                <h2><strong>ImageCollection:</strong> <span>GET</span></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>page</strong>: <span class="data-type-container">integer</span></div>
                </div>
                <cfset componentName = "imageCollection">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/images/<span class="token-container url-token"><span class="token-container url-token"><cfif StructKeyExists(variables,"imageCollection_get_page")>#variables.imageCollection_get_page#<cfelse>{page}</cfif></span></div>
                </div>
                <form name="imageCollection_get" method="post" action="?httpRequest=imageCollection&verb=get">
                  <label style="margin-top:0px;">Pages</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="imageCollection_get_page" id="imageCollection_get_page" style="margin-bottom:20px;">
                    </select>
                  </div>
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"imageCollection") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0 AND StructKeyExists(variables,"imageCollection_get_page")>
                  <cfset httpRequest$ = restApiService.ImageCollection(page=variables.imageCollection_get_page,userToken=userToken)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.imageCollection_get.submit();">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>
              </div>
              
              <!--- ImageUnapprovedCollection: GET --->
              
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="imageUnapprovedCollection-get"></a> 
              <div id="imageUnapprovedCollection-get" class="component-container">       
                <h2><strong>ImageUnapprovedCollection:</strong> <span>GET</span></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>page</strong>: <span class="data-type-container">integer</span></div>
                </div>
                <cfset componentName = "imageUnapprovedCollection">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/images/<span class="token-container url-token"><span class="token-container url-token"><cfif StructKeyExists(variables,"imageUnapprovedCollection_get_page")>#variables.imageUnapprovedCollection_get_page#<cfelse>{page}</cfif></span></div>
                </div>
                <form name="imageUnapprovedCollection_get" method="post" action="?httpRequest=imageUnapprovedCollection&verb=get">
                  <label style="margin-top:0px;">Pages</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="imageUnapprovedCollection_get_page" id="imageUnapprovedCollection_get_page" style="margin-bottom:20px;">
                    </select>
                  </div>
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"imageUnapprovedCollection") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0 AND StructKeyExists(variables,"imageUnapprovedCollection_get_page")>
                  <cfset httpRequest$ = restApiService.ImageUnapprovedCollection(page=variables.imageUnapprovedCollection_get_page,userToken=userToken)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.imageUnapprovedCollection_get.submit();">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>
              </div>
              
              
              <!--- ImageApprovedCollection: GET --->
              
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="imageApprovedCollection-get"></a> 
              <div id="imageApprovedCollection-get" class="component-container">       
                <h2><strong>ImageApprovedCollection:</strong> <span>GET</span></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>page</strong>: <span class="data-type-container">integer</span></div>
                </div>
                <cfset componentName = "imageApprovedCollection">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/images/<span class="token-container url-token"><span class="token-container url-token"><cfif StructKeyExists(variables,"imageApprovedCollection_get_page")>#variables.imageApprovedCollection_get_page#<cfelse>{page}</cfif></span></div>
                </div>
                <form name="imageApprovedCollection_get" method="post" action="?httpRequest=imageApprovedCollection&verb=get">
                  <label style="margin-top:0px;">Pages</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="imageApprovedCollection_get_page" id="imageApprovedCollection_get_page" style="margin-bottom:20px;">
                    </select>
                  </div>
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"imageApprovedCollection") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0 AND StructKeyExists(variables,"imageApprovedCollection_get_page")>
                  <cfset httpRequest$ = restApiService.ImageApprovedCollection(page=variables.imageApprovedCollection_get_page,userToken=userToken)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.imageApprovedCollection_get.submit();">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>
              </div>
              
      <!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
              
              
              <!--- JWT --->
              
              <!--- JwtMember: GET --->
              
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="jwtMember-get"></a>
              <div id="jwtMember-get" class="component-container">
                <h2><strong>JwtMember:</strong> <span>GET</span><i class="fa fa-lock"></i></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>userToken</strong>: <span class="data-type-container">string</span></div>
                </div>
                <cfset componentName = "jwtMember">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/jwt/<span class="token-container url-token">#userToken#</span></div>
                </div>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"jwtMember") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0>
                  <cfset httpRequest$ = restApiService.JwtMember(authorization=authorization,userToken=userToken,verb=verb)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="?httpRequest=jwtMember&verb=get">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>
              </div>
              
                    
      <!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
              
              
              <!--- Likes --->
              
              <!--- LikeMember: GET --->
              
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="likeMember-get"></a>
              <div id="likeMember-get" class="component-container">
                <h2><strong>LikeMember:</strong> <span>GET</span></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>fileUuid</strong>: <span class="data-type-container">string</span></div>
                </div>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>add</strong>: <span class="data-type-container">integer</span></div>
                </div>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>allowMultipleLikesPerUser</strong>: <span class="data-type-container">integer</span></div>
                </div>
                <cfset componentName = "likeMember">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/like/<span class="token-container url-token"><cfif StructKeyExists(variables,"likeMember_get_fileUuid")>#variables.likeMember_get_fileUuid#<cfelse>{fileUuid}</cfif></span>/<span class="token-container url-token">0</span>/<span class="token-container url-token">0</span></div>
                </div>
                <form name="likeMember_get" method="post" action="?httpRequest=likeMember&verb=get">
                  <label style="margin-top:0px;">Images</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="likeMember_get_fileUuid" id="likeMember_get_fileUuid" style="margin-bottom:20px;">
                      <CFQUERY NAME="qGetFileUuid" DATASOURCE="#request.domain_dsn#">
                        SELECT * 
                        FROM tblFile 
                        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUserID.User_ID#"> 
                        ORDER BY Submission_date DESC
                      </CFQUERY>
                      <cfif qGetFileUuid.RecordCount>
                        <cfloop query="qGetFileUuid">
                          <option value="#qGetFileUuid.File_uuid#"<cfif StructKeyExists(variables,"likeMember_get_fileUuid") AND CompareNoCase(qGetFileUuid.File_uuid,variables.likeMember_get_fileUuid) EQ 0> selected="selected"</cfif>>#qGetFileUuid.Title#</option>
                        </cfloop>
                      </cfif>
                    </select>
                  </div>
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"likeMember") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0 AND StructKeyExists(variables,"likeMember_get_fileUuid")>
                  <cfset httpRequest$ = restApiService.LikeMember(fileUuid=variables.likeMember_get_fileUuid,add=0,allowMultipleLikesPerUser=0)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.likeMember_get.submit();">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>
              </div>
              
              
              <!--- LikeMember: POST --->
              
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="likeMember-post"></a>
              <div id="likeMember-post" class="component-container">
                <h2><strong>LikeMember:</strong> <span>POST</span><i class="fa fa-lock"></i></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>fileUuid</strong>: <span class="data-type-container">string</span></div>
                </div>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>add</strong>: <span class="data-type-container">integer</span></div>
                </div>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>allowMultipleLikesPerUser</strong>: <span class="data-type-container">integer</span></div>
                </div>
                <cfset componentName = "likeMember">
                <cfset funcName = "post">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/like/<span class="token-container url-token"><cfif StructKeyExists(variables,"likeMember_post_fileUuid")>#variables.likeMember_post_fileUuid#<cfelse>{fileUuid}</cfif></span>/<span class="token-container url-token">1</span>/<span class="token-container url-token">0</span></div>
                </div>
                <form name="likeMember_post" method="post" action="?httpRequest=likeMember&verb=post">
                  <label style="margin-top:0px;">Images</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="likeMember_post_fileUuid" id="likeMember_post_fileUuid" style="margin-bottom:20px;">
                      <CFQUERY NAME="qGetFileUuid" DATASOURCE="#request.domain_dsn#">
                        SELECT * 
                        FROM tblFile 
                        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUserID.User_ID#"> 
                        ORDER BY Submission_date DESC
                      </CFQUERY>
                      <cfif qGetFileUuid.RecordCount>
                        <cfloop query="qGetFileUuid">
                          <option value="#qGetFileUuid.File_uuid#"<cfif StructKeyExists(variables,"likeMember_post_fileUuid") AND CompareNoCase(qGetFileUuid.File_uuid,variables.likeMember_post_fileUuid) EQ 0> selected="selected"</cfif>>#qGetFileUuid.Title#</option>
                        </cfloop>
                      </cfif>
                    </select>
                  </div>
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"likeMember") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"post") EQ 0 AND StructKeyExists(variables,"likeMember_post_fileUuid")>
                  <cfset httpRequest$ = restApiService.LikeMember(fileUuid=variables.likeMember_post_fileUuid,add=1,allowMultipleLikesPerUser=0,authorization=authorization,userToken=userToken)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.likeMember_post.submit();">POST</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>
              </div>
              
      <!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
              
              
              <!--- Search --->
              
              <!--- SearchCollection: GET --->
              
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="searchCollection-get"></a>
              <div id="searchCollection-get" class="component-container">
                <h2><strong>SearchCollection:</strong> <span>GET</span></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>page</strong>: <span class="data-type-container">integer</span></div>
                </div>
                <cfset componentName = "searchCollection">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/search/<span class="token-container url-token"><cfif StructKeyExists(variables,"searchCollection_get_page")>#variables.searchCollection_get_page#<cfelse>{page}</cfif></span></div>
                </div>
                <form name="searchCollection_get" method="post" action="?httpRequest=searchCollection&verb=get">
                  <label style="margin-top:0px;">Pages</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="searchCollection_get_page" id="searchCollection_get_page">
                    </select>
                  </div>
                  <label>Term</label>
                  <input type="text" name="searchCollection_get_term" id="searchCollection_get_term" placeholder="Term" value="<cfif StructKeyExists(variables,"searchCollection_get_term")>#variables.searchCollection_get_term#</cfif>" style="margin-bottom:20px;" />
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"searchCollection") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0 AND StructKeyExists(variables,"searchCollection_get_page") AND StructKeyExists(variables,"searchCollection_get_term")>
                  <cfset httpRequest$ = restApiService.SearchCollection(term=variables.searchCollection_get_term,page=variables.searchCollection_get_page)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.searchCollection_get.submit();">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>  
              </div>
              
      <!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
              
              
              <!--- OAuth --->
              
              
              <!--- OauthMember: POST --->
              
              <cfset keeploggedin = 0>
              <cfset commentToken = "">
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="oauthMember-post"></a>
              <div id="oauthMember-post" class="component-container">
                <h2><strong>OauthMember:</strong> <span>POST</span></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>userToken</strong>: <span class="data-type-container">string</span></div>
                </div>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>keeploggedin</strong>: <span class="data-type-container">integer</span></div>
                </div>
                <cfset componentName = "oauthMember">
                <cfset funcName = "post">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/oauth/<span class="token-container url-token">#userToken#</span>/<span class="token-container url-token">#keeploggedin#</span></div>
                </div>
                <form name="oauthMember_post" method="post" action="?httpRequest=oauthMember&verb=post">
                  <label style="margin-top:0px;">E-mail</label>
                  <input type="text" name="oauthMember_post_email" id="oauthMember_post_email" placeholder="E-mail" value="<cfif StructKeyExists(variables,"oauthMember_post_email")>#variables.oauthMember_post_email#<cfelse>#email#</cfif>" readonly />
                  <label>Password</label>
                  <input type="password" name="oauthMember_post_password" id="oauthMember_post_password" placeholder="Password" style="margin-bottom:20px;" />
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"oauthMember") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"post") EQ 0 AND StructKeyExists(variables,"oauthMember_post_email") AND StructKeyExists(variables,"oauthMember_post_password") AND FindNoCase("@",variables.oauthMember_post_email) AND Len(Trim(variables.oauthMember_post_password))>
                  <cfset httpRequest$ = restApiService.OauthMember(userToken=userToken,keeploggedin=keeploggedin,email=variables.oauthMember_post_email,password=variables.oauthMember_post_password,commentToken=commentToken)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.oauthMember_post.submit();">POST</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>  
              </div>
              
       <!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
              
              
              <!--- Tinymce Article Images --->
              
              <!--- TinymceArticleImageMember: GET --->
                      
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="tinymceArticleImageMember-get"></a>
              <div id="tinymceArticleImageMember-get" class="component-container">
                <h2><strong>TinymceArticleImageMember:</strong> <span>GET</span></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>fileid</strong>: <span class="data-type-container">integer</span></div>
                </div>
                <cfset componentName = "tinymceArticleImageMember">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/tinymcearticleimage/<span class="token-container url-token"><cfif StructKeyExists(variables,"tinymceArticleImageMember_get_fileid")>#variables.tinymceArticleImageMember_get_fileid#<cfelse>{fileid}</cfif></span></div>
                </div>
                <form name="tinymceArticleImageMember_get" method="post" action="?httpRequest=tinymceArticleImageMember&verb=get">
                  <label style="margin-top:0px;">Images</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="tinymceArticleImageMember_get_fileid" id="tinymceArticleImageMember_get_fileid" style="margin-bottom:20px;">
                      <CFQUERY NAME="qGetFileID" DATASOURCE="#request.domain_dsn#">
                        SELECT * 
                        FROM tblFile 
                        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUserID.User_ID#">
                        ORDER BY Submission_date DESC
                      </CFQUERY>
                      <cfif qGetFileID.RecordCount>
                        <cfloop query="qGetFileID">
                          <cfdirectory action="list" directory="#request.filepath#\article-images\#qGetFileID.File_ID#" name="qGetArticleImages" type="file" recurse="no" />
                          <cfif qGetArticleImages.RecordCount>
                            <option value="#qGetFileID.File_ID#"<cfif StructKeyExists(variables,"tinymceArticleImageMember_get_fileid") AND CompareNoCase(qGetFileID.File_ID,variables.tinymceArticleImageMember_get_fileid) EQ 0> selected="selected"</cfif>>#qGetFileID.Title#</option>
                          </cfif>
                        </cfloop>
                      </cfif>
                    </select>
                  </div>
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"tinymceArticleImageMember") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0 AND StructKeyExists(variables,"tinymceArticleImageMember_get_fileid")>
                  <cfset httpRequest$ = restApiService.TinymceArticleImageMember(fileid=variables.tinymceArticleImageMember_get_fileid,userToken=userToken,verb=verb)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.tinymceArticleImageMember_get.submit();">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>
              </div>
              
              
              <!--- TinymceArticleImageMember: POST --->
              
              <cfset ContentType = testImageContentType>
              <cfif StructKeyExists(form,"tinymceArticleImageMember_post_fileid")>
                <cfset tinymceArticleImageMember_post_fileid = form.tinymceArticleImageMember_post_fileid>
              </cfif>
              <cfif StructKeyExists(form,"tinymceArticleImageMember_post_filename")>
                <cfset tinymceArticleImageMember_post_filename = form.tinymceArticleImageMember_post_filename>
              </cfif>
              <cfif StructKeyExists(url,"httpRequest")>
                <cfset httpRequest = url.httpRequest>
              </cfif>
              <cfif StructKeyExists(url,"verb")>
                <cfset verb = url.verb>
              </cfif>
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="tinymceArticleImageMember-post"></a>
              <div id="tinymceArticleImageMember-post" class="component-container">
                <h2><strong>TinymceArticleImageMember:</strong> <span>POST</span><i class="fa fa-lock"></i></h2>
                <div id="tinymceArticleImageMember-post-binaryFileObj-container-width"></div>
                <div id="tinymceArticleImageMember-post-binaryFileObj-container" class="tinymceArticleImageMember-post-binaryFileObj-container" style="display:none;">
                  <div id="tinymceArticleImageMember-post-binaryFileObj-container-show-1" class="tinymceArticleImageMember-post-binaryFileObj-container-show" style="display:none;"></div>
                  <div id="tinymceArticleImageMember-post-binaryFileObj-container-show-2" class="tinymceArticleImageMember-post-binaryFileObj-container-show" style="display:none;"></div>
                  <div id="tinymceArticleImageMember-post-binaryFileObj-container-show-3" class="tinymceArticleImageMember-post-binaryFileObj-container-show" style="display:none;"></div>
                </div>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>fileid</strong>: <span class="data-type-container">integer</span></div>
                </div>
                <cfset componentName = "tinymceArticleImageMember">
                <cfset funcName = "post">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/tinymcearticleimage/<span class="token-container url-token">#fileid#</span></div>
                </div>
                <form name="tinymceArticleImageMember_post" method="post" action="?httpRequest=tinymceArticleImageMember&verb=post" enctype="multipart/form-data">
                  <label style="margin-top:0px;">Images</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="tinymceArticleImageMember_post_fileid" id="tinymceArticleImageMember_post_fileid" style="margin-bottom:20px;">
                      <CFQUERY NAME="qGetFileID" DATASOURCE="#request.domain_dsn#">
                        SELECT * 
                        FROM tblFile 
                        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUserID.User_ID#">
                        ORDER BY Submission_date DESC
                      </CFQUERY>
                      <cfif qGetFileID.RecordCount>
                        <cfloop query="qGetFileID">
                          <cfdirectory action="list" directory="#request.filepath#\article-images\#qGetFileID.File_ID#" name="qGetArticleImages" type="file" recurse="no" />
                          <cfif qGetArticleImages.RecordCount>
                            <option value="#qGetFileID.File_ID#"<cfif StructKeyExists(variables,"tinymceArticleImageMember_post_fileid") AND CompareNoCase(qGetFileID.File_ID,variables.tinymceArticleImageMember_post_fileid) EQ 0> selected="selected"</cfif>>#qGetFileID.Title#</option>
                          </cfif>
                        </cfloop>
                      </cfif>
                    </select>
                  </div>
                  <label>Filename</label>
                  <input type="text" name="tinymceArticleImageMember_post_filename" id="tinymceArticleImageMember_post_filename" placeholder="Filename" value="<cfif StructKeyExists(variables,"tinymceArticleImageMember_post_filename")>#variables.tinymceArticleImageMember_post_filename#</cfif>" readonly />
                  <label>Choose File</label>
                  <div class="file-container">
                    <input type="file" name="tinymceArticleImageMember_post_binaryfileobj" id="tinymceArticleImageMember_post_binaryfileobj" class="js inputfile inputfile-1" data-multiple-caption="{count} files selected" placeholder="Choose File" />
                    <label for="tinymceArticleImageMember_post_binaryfileobj"><svg xmlns="http://www.w3.org/2000/svg" width="20" height="17" viewBox="0 0 20 17"><path d="M10 0l-5.2 4.9h3.3v5.1h3.8v-5.1h3.3l-5.2-4.9zm9.3 11.5l-3.2-2.1h-2l3.4 2.6h-3.5c-.1 0-.2.1-.2.1l-.8 2.3h-6l-.8-2.2c-.1-.1-.1-.2-.2-.2h-3.6l3.4-2.6h-2l-3.2 2.1c-.4.3-.7 1-.6 1.5l.6 3.1c.1.5.7.9 1.2.9h16.3c.6 0 1.1-.4 1.3-.9l.6-3.1c.1-.5-.2-1.2-.7-1.5z"/></svg> <span>Choose a file&hellip;</span></label>
                  </div>
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"tinymceArticleImageMember") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"post") EQ 0 AND StructKeyExists(variables,"tinymceArticleImageMember_post_fileid") AND StructKeyExists(variables,"tinymceArticleImageMember_post_filename") AND  Len(Trim(variables.tinymceArticleImageMember_post_filename))>
                  <cfif StructKeyExists(url,"httpRequest") AND CompareNoCase(url['httpRequest'],"tinymceArticleImageMember") EQ 0 AND StructKeyExists(url,"verb") AND CompareNoCase(url['verb'],"post") EQ 0>
                    <cffile action="upload" fileField="tinymceArticleImageMember_post_binaryfileobj" destination="#GetTempDirectory()#"> 
                    <cffile action="readBinary" file="#GetTempDirectory()#\#tinymceArticleImageMember_post_filename#" variable="tinymceArticleImageMember_post_binaryfileobj_data">
                    <cflock name="delete_file" type="exclusive" timeout="30">
                      <cffile action="delete"  file="#GetTempDirectory()#\#tinymceArticleImageMember_post_filename#" />
                    </cflock>
                    <cfset session['tinymceArticleImageMember_post_binaryfileobj_data'] = tinymceArticleImageMember_post_binaryfileobj_data>
                    <cfif StructKeyExists(url,"httpRequest") AND StructKeyExists(url,"verb")>
                      <cfset StructAppend(session,url)>
                      <cfset StructAppend(session,form)>
                      <cflocation url="../components/restApiService.cfm" addtoken="no" />
                    </cfif>
                  </cfif>
                  <cfif StructKeyExists(session,"tinymceArticleImageMember_post_binaryfileobj_data")>
                    <cfset fileExtension = "">
                    <cfif Len(Trim(variables.tinymceArticleImageMember_post_filename))>
                      <cfset fileExtension = ListLast(variables.tinymceArticleImageMember_post_filename,".")>
                      <cfset ContentType = "image/" & fileExtension>
                    </cfif>
                    <cfif ListFindNoCase("gif,png,jpg,jpeg",fileExtension) AND IsBinary(session['tinymceArticleImageMember_post_binaryfileobj_data'])>
                      <cfset httpRequest$ = restApiService.TinymceArticleImageMember(fileid=variables.tinymceArticleImageMember_post_fileid,filename=variables.tinymceArticleImageMember_post_filename,contentType=ContentType,binaryFileObj=session.tinymceArticleImageMember_post_binaryfileobj_data,authorization=authorization,userToken=userToken,verb=verb)>
                      <cfinclude template="../http-request-to-json.cfm">
                      <cfset imgsrc = "">
                      <cfif StructKeyExists(filecontent,"location") AND Len(Trim(filecontent['location']))>
                        <cfset imgsrc = filecontent['location']>
                      </cfif>
                      <cfset width = 0> 
                      <cfset height = 0>
                      <cfset error = false>
                      <cftry>
                        <cfimage source="../article-images/#variables.tinymceArticleImageMember_post_fileid#/#variables.tinymceArticleImageMember_post_filename#" name="img_tinymceArticleImageMember_post_binaryFileObj_data">
                        <cfset width = Val(ImageGetWidth(img_tinymceArticleImageMember_post_binaryFileObj_data))> 
                        <cfset height = Val(ImageGetHeight(img_tinymceArticleImageMember_post_binaryFileObj_data))>
                        <cfcatch>
                          <cfset error = true>
                        </cfcatch>
                      </cftry>
                      <cfif NOT error>
                        <div id="tinymceArticleImageMember-post-binaryFileObj-container-hide" class="tinymceArticleImageMember-post-binaryFileObj-container-hide">
                          <img id="img_tinymceArticleImageMember_post_binaryFileObj" src="#imgsrc#"<cfif width AND height> style="width:#width#px;height:#height#px;"</cfif> />
                        </div>
                      </cfif>
                    </cfif>
                    <cfif StructKeyExists(session,"tinymceArticleImageMember_post_binaryfileobj_data")>
                      <cfset variables['tinymceArticleImageMember_post_binaryfileobj_data'] = session['tinymceArticleImageMember_post_binaryfileobj_data']>
                      <cfset StructDelete(session,'tinymceArticleImageMember_post_binaryfileobj_data')>
                    </cfif>
                  </cfif>
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.tinymceArticleImageMember_post.submit();">POST</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>
              </div>
              
              <!--- TinymceArticleImageMember: DELETE --->
                      
              <cfset fileid = fileId>
              <cfset filename = testImageFilename>
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="tinymceArticleImageMember-delete"></a>
              <div id="tinymceArticleImageMember-delete" class="component-container">
                <h2><strong>TinymceArticleImageMember:</strong> <span>DELETE</span><i class="fa fa-lock"></i></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>fileid</strong>: <span class="data-type-container">integer</span></div>
                </div>
                <cfset componentName = "tinymceArticleImageMember">
                <cfset funcName = "delete">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/tinymcearticleimage/<span class="token-container url-token"><cfif StructKeyExists(variables,"tinymceArticleImageMember_delete_fileid")>#variables.tinymceArticleImageMember_delete_fileid#<cfelse>{fileid}</cfif></span></div>
                </div>
                <form name="tinymceArticleImageMember_delete" method="post" action="?httpRequest=tinymceArticleImageMember&verb=delete">
                  <label style="margin-top:0px;">Images</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="tinymceArticleImageMember_delete_fileid" id="tinymceArticleImageMember_delete_fileid">
                      <CFQUERY NAME="qGetFileID" DATASOURCE="#request.domain_dsn#">
                        SELECT * 
                        FROM tblFile 
                        WHERE User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUserID.User_ID#">
                        ORDER BY Submission_date DESC
                      </CFQUERY>
                      <cfif qGetFileID.RecordCount>
                        <cfloop query="qGetFileID">
                          <cfdirectory action="list" directory="#request.filepath#\article-images\#qGetFileID.File_ID#" name="qGetArticleImages" type="file" recurse="no" />
                          <cfif qGetArticleImages.RecordCount>
                            <option value="#qGetFileID.File_ID#"<cfif StructKeyExists(variables,"tinymceArticleImageMember_delete_fileid") AND CompareNoCase(qGetFileID.File_ID,variables.tinymceArticleImageMember_delete_fileid) EQ 0> selected="selected"</cfif>>#qGetFileID.Title#</option>
                          </cfif>
                        </cfloop>
                      </cfif>
                    </select>
                  </div>
                  <label>Filename</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="tinymceArticleImageMember_delete_filename" id="tinymceArticleImageMember_delete_filename" style="margin-bottom:20px;">
                    </select>
                  </div>
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"tinymceArticleImageMember") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"delete") EQ 0 AND StructKeyExists(variables,"tinymceArticleImageMember_delete_fileid") AND StructKeyExists(variables,"tinymceArticleImageMember_delete_filename")>
                  <cfset httpRequest$ = restApiService.TinymceArticleImageMember(fileid=variables.tinymceArticleImageMember_delete_fileid,filename=variables.tinymceArticleImageMember_delete_filename,authorization=authorization,userToken=userToken,verb=verb)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.tinymceArticleImageMember_delete.submit();">DELETE</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>
              </div>
              
              <!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
              
              
              <!--- Users --->
              
              <!--- UserMember: GET --->
                      
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="userMember-get"></a>
              <div id="userMember-get" class="component-container">
                <h2><strong>UserMember:</strong> <span>GET</span></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>userToken</strong>: <span class="data-type-container">string</span></div>
                </div>
                <cfset componentName = "userMember">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/user/<span class="token-container url-token">#userToken#</span></div>
                </div>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"userMember") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0>
                  <cfset httpRequest$ = restApiService.UserMember(userToken=userToken,verb=verb)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="?httpRequest=userMember&verb=get">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div> 
              </div> 
              
              <!--- UserMember: POST --->
                      
              <cfset cfid = "">
              <cfset cftoken = "">
              <cfset testEmail = false>
              <cfset cookieAcceptance = 0>
              <cfset emailNotification = 0>
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="userMember-post"></a>
              <div id="userMember-post" class="component-container">
                <h2><strong>UserMember:</strong> <span>POST</span></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>userToken</strong>: <span class="data-type-container">string</span></div>
                </div>
                <cfset componentName = "userMember">
                <cfset funcName = "post">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/user/<span class="token-container url-token">#userToken#</span></div>
                </div>
                <form name="userMember_post" method="post" action="?httpRequest=userMember&verb=post">
                  <label style="margin-top:0px;">Forename</label>
                  <input type="text" name="userMember_post_forename" id="userMember_post_forename" placeholder="Forename" value="<cfif StructKeyExists(variables,"userMember_post_forename")>#variables.userMember_post_forename#</cfif>" />
                  <label>Surname</label>
                  <input type="text" name="userMember_post_surname" id="userMember_post_surname" placeholder="Surname" value="<cfif StructKeyExists(variables,"userMember_post_surname")>#variables.userMember_post_surname#</cfif>" />
                  <label>E-mail</label>
                  <input type="text" name="userMember_post_email" id="userMember_post_email" placeholder="E-mail" value="<cfif StructKeyExists(variables,"userMember_post_email")>#variables.userMember_post_email#</cfif>" />
                  <label>Password</label>
                  <input type="password" name="userMember_post_password" id="userMember_post_password" placeholder="Password" style="margin-bottom:20px;" />
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"userMember") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"post") EQ 0 AND StructKeyExists(variables,"userMember_post_forename") AND StructKeyExists(variables,"userMember_post_surname") AND StructKeyExists(variables,"userMember_post_email") AND StructKeyExists(variables,"userMember_post_password") AND Len(Trim(variables.userMember_post_forename)) AND Len(Trim(variables.userMember_post_surname)) AND FindNoCase("@",variables.userMember_post_email) AND Len(Trim(variables.userMember_post_password))>
                  <cfset httpRequest$ = restApiService.UserMember(forename=variables.userMember_post_forename,surname=variables.userMember_post_surname,email=variables.userMember_post_email,password=variables.userMember_post_password,cfid=cfid,cftoken=cftoken,userToken=LCase(CreateUUID()),testEmail=testEmail,cookieAcceptance=cookieAcceptance,emailNotification=emailNotification,theme=theme,verb=verb)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.userMember_post.submit();">POST</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>
              </div>
              
              <!--- UserMember: PUT --->
                     
              <cfset cfid = "">
              <cfset cftoken = "">
              <cfset testEmail = false>
              <cfset cookieAcceptance = 0>
              <cfset emailNotification = 0>
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="userMember-put"></a>
              <div id="userMember-put" class="component-container">
                <h2><strong>UserMember:</strong> <span>PUT</span><i class="fa fa-lock"></i></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>userToken</strong>: <span class="data-type-container">string</span></div>
                </div>
                <cfset componentName = "userMember">
                <cfset funcName = "put">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/user/<span class="token-container url-token">#usertoken#</span></div>
                </div>
                <form name="userMember_put" method="post" action="?httpRequest=userMember&verb=put">
                  <label style="margin-top:0px;">Forename</label>
                  <input type="text" name="userMember_put_forename" id="userMember_put_forename" placeholder="Forename" value="<cfif StructKeyExists(variables,"userMember_put_forename")>#variables.userMember_put_forename#<cfelse>#forename#</cfif>" />
                  <label>Surname</label>
                  <input type="text" name="userMember_put_surname" id="userMember_put_surname" placeholder="Surname" value="<cfif StructKeyExists(variables,"userMember_put_surname")>#variables.userMember_put_surname#<cfelse>#surname#</cfif>" />
                  <label>Password</label>
                  <input type="password" name="userMember_put_password" id="userMember_put_password" placeholder="Password" style="margin-bottom:20px;" />
                  <input type="hidden" name="userMember_put_theme" id="userMember_put_theme" value="#theme#" />
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"userMember") EQ 0 AND StructKeyExists(variables,"userMember_put_forename") AND StructKeyExists(variables,"userMember_put_surname") AND StructKeyExists(variables,"userMember_put_password") AND StructKeyExists(variables,"userMember_put_theme") AND Len(Trim(variables.userMember_put_forename)) AND Len(Trim(variables.userMember_put_surname))>
                  <cfset httpRequest$ = restApiService.UserMember(forename=variables.userMember_put_forename,surname=variables.userMember_put_surname,password=variables.userMember_put_password,emailNotification=emailNotification,theme=variables.userMember_put_theme,authorization=authorization,userToken=usertoken,verb=verb)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.userMember_put.submit();">PUT</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>
              </div>
              
              <!--- UserMember: DELETE --->
                     
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="userMember-delete"></a>
              <div id="userMember-delete" class="component-container">
                <h2><strong>UserMember:</strong> <span>DELETE</span><i class="fa fa-lock"></i></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>userToken</strong>: <span class="data-type-container">string</span></div>
                </div>
                <cfset componentName = "userMember">
                <cfset funcName = "delete">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/user/<span class="token-container url-token"><cfif StructKeyExists(variables,"userMember_delete_usertoken")>#variables.userMember_delete_usertoken#<cfelse>#usertoken#</cfif></span></div>
                </div>
                <form name="userMember_delete" method="post" action="?httpRequest=userMember&verb=delete">
                  <label style="margin-top:0px;">User Token</label>
                  <input type="text" name="userMember_delete_usertoken" id="userMember_delete_usertoken" placeholder="User Token" value="<cfif StructKeyExists(variables,"userMember_delete_usertoken")>#variables.userMember_delete_usertoken#<cfelse>#usertoken#</cfif>" readonly="readonly" style="margin-bottom:20px;" />
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"userMember") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"delete") EQ 0 AND StructKeyExists(variables,"userMember_delete_usertoken")>
                  <cfset httpRequest$ = restApiService.UserMember(authorization=authorization,userToken=variables.userMember_delete_usertoken,verb=verb)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                  <cfif StructKeyExists(httpRequest$,"Responseheader") AND StructKeyExists(httpRequest$['Responseheader'],"Status_code") AND StructKeyExists(httpRequest$,"FileContent")>
                    <cfif IsJson(httpRequest$['FileContent'])>
                      <cfset filecontent = DeserializeJson(httpRequest$['FileContent'])>
                      <cfif IsStruct(filecontent) AND NOT StructIsEmpty(filecontent) AND StructKeyExists(filecontent,"error")>
                        <cfset statuscode = Val(Trim(httpRequest$['Responseheader']['Status_code']))>
                        <cfif CompareNoCase(statuscode,"200") EQ 0 AND NOT Len(Trim(filecontent['error']))>
                           <cflocation url="../components/restApiService.cfm?userMemberDelete=true" addtoken="no" />
                        </cfif>
                      </cfif>
                    </cfif>
                  </cfif>
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.userMember_delete.submit();">DELETE</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>
              </div>
              
      <!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
              
              
              <!--- Authors --->
              
              <!--- AuthorCollection: GET --->
                      
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="authorCollection-get"></a>
              <div id="authorCollection-get" class="component-container"<cfif NOT StructKeyExists(url,"httpRequest")> style="display:block;"</cfif>>
                <h2><strong>AuthorCollection:</strong> <span>GET</span></h2>
                <cfset componentName = "authorCollection">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/authors</div>
                </div>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"authorCollection") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0>
                  <cfset httpRequest$ = restApiService.AuthorCollection(userToken=userToken)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="?httpRequest=authorCollection&verb=get">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>  
              </div>
              
      <!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
              
              
              <!--- Authors --->
              
              <!--- AutocompleteTagsCollection: GET --->
              
              <cfset term = "foo">
              <cfset useTerm = false>       
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="autocompleteTagsCollection-get"></a>
              <div id="autocompleteTagsCollection-get" class="component-container">
                <h2><strong>AutocompleteTagsCollection:</strong> <span>GET</span></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>term</strong>: <span class="data-type-container">string</span></div>
                </div>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>useTerm</strong>: <span class="data-type-container">boolean</span></div>
                </div>
                <cfset componentName = "autocompleteTagsCollection">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/autocompleteTags/<span class="token-container url-token"><cfif StructKeyExists(variables,"autocompleteTagsCollection_get_term")>#variables.autocompleteTagsCollection_get_term#<cfelse>#term#</cfif></span>/<span class="token-container url-token"><cfif StructKeyExists(variables,"autocompleteTagsCollection_get_useTerm")>#variables.autocompleteTagsCollection_get_useTerm#<cfelse>#useTerm#</cfif></span></div>
                </div>
                <form name="autocompleteTagsCollection_get" method="post" action="?httpRequest=autocompleteTagsCollection&verb=get">
                  <label style="margin-top:0px;">Term</label>
                  <input type="text" name="autocompleteTagsCollection_get_term" id="autocompleteTagsCollection_get_term" placeholder="Search Term" value="<cfif StructKeyExists(variables,"autocompleteTagsCollection_get_term")>#variables.autocompleteTagsCollection_get_term#</cfif>" />
                  <label>Use Term</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="autocompleteTagsCollection_get_useterm" id="autocompleteTagsCollection_get_useterm" style="margin-bottom:20px;">
                      <option value="false"<cfif StructKeyExists(variables,"autocompleteTagsCollection_get_useTerm") AND NOT variables.autocompleteTagsCollection_get_useTerm> selected="selected"</cfif>>false</option>
                      <option value="true"<cfif StructKeyExists(variables,"autocompleteTagsCollection_get_useTerm") AND variables.autocompleteTagsCollection_get_useTerm> selected="selected"</cfif>>true</option>
                    </select>
                  </div>
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"autocompleteTagsCollection") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0 AND StructKeyExists(variables,"autocompleteTagsCollection_get_term") AND StructKeyExists(variables,"autocompleteTagsCollection_get_useterm")>
                  <cfset httpRequest$ = restApiService.AutocompleteTagsCollection(term=variables.autocompleteTagsCollection_get_term,useTerm=variables.autocompleteTagsCollection_get_useTerm,userToken=userToken)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.autocompleteTagsCollection_get.submit();">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div> 
              </div>
              
      <!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
              
              
              <!--- Categories --->
              
              <!--- CategoryCollection: GET --->
                      
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="categoryCollection-get"></a>
              <div id="categoryCollection-get" class="component-container">
                <h2><strong>CategoryCollection:</strong> <span>GET</span></h2>
                <cfset componentName = "categoryCollection">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/categories</div>
                </div>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"categoryCollection") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0>
                  <cfset httpRequest$ = restApiService.CategoryCollection(userToken=userToken)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="?httpRequest=categoryCollection&verb=get">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>
              </div>
              
      <!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
              
              
              <!--- Category --->
              
              <!--- CategoryMember: GET --->
                      
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="categoryMember-get"></a>
              <div id="categoryMember-get" class="component-container">
                <h2><strong>CategoryMember:</strong> <span>GET</span></h2>
                <cfset componentName = "categoryMember">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/category</div>
                </div>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"categoryMember") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0>
                  <cfset httpRequest$ = restApiService.CategoryMember()>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="?httpRequest=categoryMember&verb=get">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>
              </div>
              
      <!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
              
              
              <!--- Dates --->
              
              <!--- DateCollection: GET --->
                      
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="dateCollection-get"></a>
              <div id="dateCollection-get" class="component-container">
                <h2><strong>DateCollection:</strong> <span>GET</span></h2>
                <cfset componentName = "dateCollection">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/dates</div>
                </div>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"dateCollection") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0>
                  <cfset httpRequest$ = restApiService.DateCollection(userToken=userToken)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="?httpRequest=dateCollection&verb=get">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>
              </div>
              
      <!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
              
              
              <!--- Images Adjacent --->
              
              <!--- ImageAdjacentMember: GET --->
              
              <cfset userid = Val(qGetUserID.User_ID)>
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="imageAdjacentMember-get"></a>
              <div id="imageAdjacentMember-get" class="component-container">
                <h2><strong>ImageAdjacentMember:</strong> <span>GET</span></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>fileUuid</strong>: <span class="data-type-container">string</span></div>
                </div>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>userid</strong>: <span class="data-type-container">integer</span></div>
                </div>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>direction</strong>: <span class="data-type-container">string</span></div>
                </div>
                <cfset componentName = "imageAdjacentMember">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/image/adjacent/<span class="token-container url-token"><cfif StructKeyExists(variables,"imageAdjacentMember_get_fileUuid")>#variables.imageAdjacentMember_get_fileUuid#<cfelse>[fileUuid]</cfif></span>/<span class="token-container url-token">#userid#</span>/<span class="token-container url-token"><cfif StructKeyExists(variables,"imageAdjacentMember_get_direction")>#variables.imageAdjacentMember_get_direction#<cfelse>[direction]</cfif></span></div>
                </div>
                <form name="imageAdjacentMember_get" method="post" action="?httpRequest=imageAdjacentMember&verb=get">
                  <label style="margin-top:0px;">Images</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="imageAdjacentMember_get_fileUuid" id="imageAdjacentMember_get_fileUuid">
                      <CFQUERY NAME="qGetFileUuid" DATASOURCE="#request.domain_dsn#">
                        SELECT * 
                        FROM tblFile INNER JOIN tblComment ON tblFile.File_ID = tblComment.File_ID
                        WHERE tblFile.User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUserID.User_ID#"> 
                        GROUP BY tblFile.File_ID 
                        ORDER BY tblFile.Submission_date DESC
                      </CFQUERY>
                      <cfif qGetFileUuid.RecordCount>
                        <cfloop query="qGetFileUuid">
                          <option value="#qGetFileUuid.File_uuid#"<cfif StructKeyExists(variables,"imageAdjacentMember_get_fileUuid") AND CompareNoCase(qGetFileUuid.File_uuid,variables.imageAdjacentMember_get_fileUuid) EQ 0> selected="selected"</cfif>>#qGetFileUuid.Title#</option>
                        </cfloop>
                      </cfif>
                    </select>
                  </div>
                  <label>Direction</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="imageAdjacentMember_get_direction" id="imageAdjacentMember_get_direction" style="margin-bottom:20px;">
                      <option value="next"<cfif StructKeyExists(variables,"imageAdjacentMember_get_direction") AND CompareNoCase(variables.imageAdjacentMember_get_direction,"next") EQ 0> selected="selected"</cfif>>next</option>
                      <option value="previous"<cfif StructKeyExists(variables,"imageAdjacentMember_get_direction") AND CompareNoCase(variables.imageAdjacentMember_get_direction,"previous") EQ 0> selected="selected"</cfif>>previous</option>
                    </select>
                  </div>
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"imageAdjacentMember") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0 AND StructKeyExists(variables,"imageAdjacentMember_get_fileUuid") AND StructKeyExists(variables,"imageAdjacentMember_get_direction")>
                  <cfset httpRequest$ = restApiService.ImageAdjacentMember(fileUuid=variables.imageAdjacentMember_get_fileUuid,userid=userid,direction=variables.imageAdjacentMember_get_direction,userToken=userToken)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.imageAdjacentMember_get.submit();">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div> 
              </div>
              
      <!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
              
              
              <!--- Images By Type --->
              
              <!--- ImageApprovedByUseridCollection: GET --->
                    
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="imageApprovedByUseridCollection-get"></a>
              <div id="imageApprovedByUseridCollection-get" class="component-container">
                <h2><strong>ImageApprovedByUseridCollection:</strong> <span>GET</span></h2>
                <cfset componentName = "imageApprovedByUseridCollection">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/images/approved/userid</div>
                </div>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"imageApprovedByUseridCollection") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0>
                  <cfset httpRequest$ = restApiService.ImageApprovedByUseridCollection(userToken=userToken)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="?httpRequest=imageApprovedByUseridCollection&verb=get">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>  
              </div>
              
              <!--- imageByCategoryCollection: GET --->
              
              <cfset page = 1>        
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="imageByCategoryCollection-get"></a>
              <div id="imageByCategoryCollection-get" class="component-container">
                <h2><strong>ImageByCategoryCollection:</strong> <span>GET</span></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>category</strong>: <span class="data-type-container">string</span></div>
                </div>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>page</strong>: <span class="data-type-container">integer</span></div>
                </div>
                <cfset componentName = "imageByCategoryCollection">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/images/category/<span class="token-container url-token"><cfif StructKeyExists(variables,"imageByCategoryCollection_get_category")>#variables.imageByCategoryCollection_get_category#<cfelse>empty</cfif></span>/<span class="token-container url-token"><cfif StructKeyExists(variables,"imageByCategoryCollection_get_page")>#variables.imageByCategoryCollection_get_page#<cfelse>#page#</cfif></span></div>
                </div>
                <form name="imageByCategoryCollection_get" method="post" action="?httpRequest=imageByCategoryCollection&verb=get">
                  <label style="margin-top:0px;">Pages</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="imageByCategoryCollection_get_page" id="imageByCategoryCollection_get_page">
                    </select>
                  </div>
                  <label>Category</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="imageByCategoryCollection_get_category" id="imageByCategoryCollection_get_category" style="margin-bottom:20px;">
                      <CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
                        SELECT * 
                        FROM tblFile 
                        GROUP BY Category
                        ORDER BY Submission_date DESC
                      </CFQUERY>
                      <cfif qGetFile.RecordCount>
                        <cfloop query="qGetFile">
                          <option value="#qGetFile.Category#"<cfif StructKeyExists(variables,"imageByCategoryCollection_get_category") AND CompareNoCase(qGetFile.Category,variables.imageByCategoryCollection_get_category) EQ 0> selected="selected"</cfif>>#qGetFile.Category#</option>
                        </cfloop>
                      </cfif>
                    </select>
                  </div>
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"imageByCategoryCollection") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0 AND StructKeyExists(variables,"imageByCategoryCollection_get_category") AND StructKeyExists(variables,"imageByCategoryCollection_get_page")>
                  <cfset httpRequest$ = restApiService.imageByCategoryCollection(category=variables.imageByCategoryCollection_get_category,page=variables.imageByCategoryCollection_get_page,userToken=userToken)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.imageByCategoryCollection_get.submit();">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>
              </div>
                      
              <!--- imageByDateCollection: GET --->
              
              <cfset page = 1>        
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="imageByDateCollection-get"></a>
              <div id="imageByDateCollection-get" class="component-container">
                <h2><strong>ImageByDateCollection:</strong> <span>GET</span></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>year</strong>: <span class="data-type-container">integer</span></div>
                </div>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>month</strong>: <span class="data-type-container">integer</span></div>
                </div>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>page</strong>: <span class="data-type-container">integer</span></div>
                </div>
                <cfset componentName = "imageByDateCollection">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/images/date/<span class="token-container url-token"><cfif StructKeyExists(variables,"imageByDateCollection_get_year")>#variables.imageByDateCollection_get_year#<cfelse>#Year(Now())#</cfif></span>/<span class="token-container url-token"><cfif StructKeyExists(variables,"imageByDateCollection_get_month")>#variables.imageByDateCollection_get_month#<cfelse>#Month(Now())#</cfif></span>/<span class="token-container url-token"><cfif StructKeyExists(variables,"imageByDateCollection_get_page")>#variables.imageByDateCollection_get_page#<cfelse>#page#</cfif></span></div>
                </div>
                <form name="imageByDateCollection_get" method="post" action="?httpRequest=imageByDateCollection&verb=get">
                  <label style="margin-top:0px;">Pages</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="imageByDateCollection_get_page" id="imageByDateCollection_get_page">
                    </select>
                  </div>
                  <label>Year</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="imageByDateCollection_get_year" id="imageByDateCollection_get_year">
                      <cfloop list="#Year(Now())#,#Year(DateAdd('yyyy',-1,Now()))#" index="year">
                        <option value="#year#"<cfif StructKeyExists(variables,"imageByDateCollection_get_year") AND CompareNoCase(year,variables.imageByDateCollection_get_year) EQ 0> selected="selected"</cfif>>#year#</option>
                      </cfloop>
                    </select>
                  </div>
                  <label>Month</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="imageByDateCollection_get_month" id="imageByDateCollection_get_month" style="margin-bottom:20px;">
                      <cfloop from="1" to="12" index="month">
                        <option value="#month#"<cfif StructKeyExists(variables,"imageByDateCollection_get_month") AND CompareNoCase(month,variables.imageByDateCollection_get_month) EQ 0> selected="selected"</cfif>>#MonthAsString(month)#</option>
                      </cfloop>
                    </select>
                  </div>
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"imageByDateCollection") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0 AND StructKeyExists(variables,"imageByDateCollection_get_year") AND StructKeyExists(variables,"imageByDateCollection_get_month") AND StructKeyExists(variables,"imageByDateCollection_get_page")>
                  <cfset httpRequest$ = restApiService.imageByDateCollection(year=variables.imageByDateCollection_get_year,month=variables.imageByDateCollection_get_month,page=variables.imageByDateCollection_get_page,userToken=userToken)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.imageByDateCollection_get.submit();">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>
              </div>
                      
              <!--- imageByTagCollection: GET --->
              
              <cfset page = 1>        
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="imageByTagCollection-get"></a>
              <div id="imageByTagCollection-get" class="component-container">
                <h2><strong>ImageByTagCollection:</strong> <span>GET</span></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>tag</strong>: <span class="data-type-container">string</span></div>
                </div>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>page</strong>: <span class="data-type-container">integer</span></div>
                </div>
                <cfset componentName = "imageByTagCollection">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/images/tag/<span class="token-container url-token"><cfif StructKeyExists(variables,"imageByTagCollection_get_tag")>#variables.imageByTagCollection_get_tag#<cfelse>{tag}</cfif></span>/<span class="token-container url-token"><cfif StructKeyExists(variables,"imageByTagCollection_get_page")>#variables.imageByTagCollection_get_page#<cfelse>#page#</cfif></span></div>
                </div>
                <form name="imageByTagCollection_get" method="post" action="?httpRequest=imageByTagCollection&verb=get">
                  <label style="margin-top:0px;">Pages</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="imageByTagCollection_get_page" id="imageByTagCollection_get_page">
                    </select>
                  </div>
                  <label>Tag</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="imageByTagCollection_get_tag" id="imageByTagCollection_get_tag" style="margin-bottom:20px;">
                      <CFQUERY NAME="qGetTags" DATASOURCE="#request.domain_dsn#">
                        SELECT * 
                        FROM tblFile 
                        WHERE Tags IS NOT NULL OR Tags <> <cfqueryparam cfsqltype="cf_sql_longvarchar" value="">
                        ORDER BY Submission_date DESC
                      </CFQUERY>
                      <cfif qGetTags.RecordCount>
                        <cfset tagList = "">
                        <cfloop query="qGetTags">
                          <cfset tagList = ListAppend(tagList,TagsToList(qGetTags.Tags))>
                        </cfloop>
                        <cfset tagList = ListRemoveDuplicates(tagList,",",true)>
                        <cfset tagList = ListSort(tagList,"textnocase","asc")>
                        <cfloop list="#tagList#" index="tag">
                          <option value="#tag#"<cfif StructKeyExists(variables,"imageByTagCollection_get_tag") AND CompareNoCase(tag,variables.imageByTagCollection_get_tag) EQ 0> selected="selected"</cfif>>#tag#</option>
                        </cfloop>
                      </cfif>
                    </select>
                  </div>
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"imageByTagCollection") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0 AND StructKeyExists(variables,"imageByTagCollection_get_tag") AND StructKeyExists(variables,"imageByTagCollection_get_page")>
                  <cfset httpRequest$ = restApiService.imageByTagCollection(tag=variables.imageByTagCollection_get_tag,page=variables.imageByTagCollection_get_page,userToken=userToken)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.imageByTagCollection_get.submit();">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>
              </div>
                      
              <!--- ImageByUseridCollection: GET --->
              
              <cfset userid = Val(qGetUserID.User_ID)>
              <cfset page = 1>       
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="imageByUseridCollection-get"></a>
              <div id="imageByUseridCollection-get" class="component-container">
                <h2><strong>ImageByUseridCollection:</strong> <span>GET</span></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>userid</strong>: <span class="data-type-container">integer</span></div>
                </div>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>page</strong>: <span class="data-type-container">integer</span></div>
                </div>
                <cfset componentName = "imageByUseridCollection">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/images/userid/<span class="token-container url-token">#userid#</span>/<span class="token-container url-token"><cfif StructKeyExists(variables,"imageByUseridCollection_get_page")>#variables.imageByUseridCollection_get_page#<cfelse>#page#</cfif></span></div>
                </div>
                <form name="imageByUseridCollection_get" method="post" action="?httpRequest=imageByUseridCollection&verb=get">
                  <label style="margin-top:0px;">Pages</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="imageByUseridCollection_get_page" id="imageByUseridCollection_get_page" style="margin-bottom:20px;">
                    </select>
                  </div>
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"imageByUseridCollection") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0 AND StructKeyExists(variables,"imageByUseridCollection_get_page")>
                  <cfset httpRequest$ = restApiService.ImageByUseridCollection(userid=userid,page=variables.imageByUseridCollection_get_page,userToken=userToken)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.imageByUseridCollection_get.submit();">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>
              </div>
              
      <!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
              
              
              <!--- Pages By Type --->
              
              <!--- PageByTagCollection: GET --->
              
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="pageByTagCollection-get"></a>
              <div id="pageByTagCollection-get" class="component-container">
                <h2><strong>PageByTagCollection:</strong> <span>GET</span></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>tag</strong>: <span class="data-type-container">string</span></div>
                </div>
                <cfset componentName = "pageByTagCollection">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/pages/tag/<span class="token-container url-token"><cfif StructKeyExists(variables,"pageByTagCollection_get_tag")>#variables.pageByTagCollection_get_tag#<cfelse>{tag}</cfif></span></div>
                </div>
                <form name="pageByTagCollection_get" method="post" action="?httpRequest=pageByTagCollection&verb=get">
                  <label style="margin-top:0px;">Tag</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="pageByTagCollection_get_tag" id="pageByTagCollection_get_tag" style="margin-bottom:20px;">
                      <CFQUERY NAME="qGetTags" DATASOURCE="#request.domain_dsn#">
                        SELECT * 
                        FROM tblFile 
                        WHERE Tags IS NOT NULL OR Tags <> <cfqueryparam cfsqltype="cf_sql_longvarchar" value="">
                        ORDER BY Submission_date DESC
                      </CFQUERY>
                      <cfif qGetTags.RecordCount>
                        <cfset tagList = "">
                        <cfloop query="qGetTags">
                          <cfset tagList = ListAppend(tagList,TagsToList(qGetTags.Tags))>
                        </cfloop>
                        <cfset tagList = ListRemoveDuplicates(tagList,",",true)>
                        <cfset tagList = ListSort(tagList,"textnocase","asc")>
                        <cfloop list="#tagList#" index="tag">
                          <option value="#tag#"<cfif StructKeyExists(variables,"pageByTagCollection_get_tag") AND CompareNoCase(tag,variables.pageByTagCollection_get_tag) EQ 0> selected="selected"</cfif>>#tag#</option>
                        </cfloop>
                      </cfif>
                    </select>
                  </div>
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"pageByTagCollection") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0 AND StructKeyExists(variables,"pageByTagCollection_get_tag")>
                  <cfset httpRequest$ = restApiService.PageByTagCollection(tag=variables.pageByTagCollection_get_tag,userToken=userToken)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.pageByTagCollection_get.submit();">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>
              </div>
              
              <!--- PageByTitleCollection: GET --->
                    
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="pageByTitleCollection-get"></a>
              <div id="pageByTitleCollection-get" class="component-container">
                <h2><strong>PageByTitleCollection:</strong> <span>GET</span></h2>
                <cfset componentName = "pageByTitleCollection">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/pages/title</div>
                </div>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"pageByTitleCollection") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0>
                  <cfset httpRequest$ = restApiService.PageByTitleCollection(userToken=userToken)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="?httpRequest=pageByTitleCollection&verb=get">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>  
              </div>
              
              <!--- PageByCategoriesCollection: GET --->
                    
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="pageByCategoriesCollection-get"></a>
              <div id="pageByCategoriesCollection-get" class="component-container">
                <h2><strong>PageByCategoriesCollection:</strong> <span>GET</span></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>category</strong>: <span class="data-type-container">string</span></div>
                </div>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>usertoken</strong>: <span class="data-type-container">string</span></div>
                </div>
                <cfset componentName = "pageByCategoriesCollection">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/pages/categories/<span class="token-container url-token"><cfif StructKeyExists(variables,"pageByCategoriesCollection_get_category")>#variables.pageByCategoriesCollection_get_category#<cfelse>empty</cfif></span>/<span class="token-container url-token">empty</span></div>
                </div>
                <form name="pageByCategoriesCollection_get" method="post" action="?httpRequest=pageByCategoriesCollection&verb=get">
                  <label style="margin-top:0px;">Category</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="pageByCategoriesCollection_get_category" id="pageByCategoriesCollection_get_category" style="margin-bottom:20px;">
                      <CFQUERY NAME="qGetFile" DATASOURCE="#request.domain_dsn#">
                        SELECT * 
                        FROM tblFile 
                        GROUP BY Category
                        ORDER BY Submission_date DESC
                      </CFQUERY>
                      <cfif qGetFile.RecordCount>
                        <cfloop query="qGetFile">
                          <option value="#qGetFile.Category#"<cfif StructKeyExists(variables,"pageByCategoriesCollection_get_category") AND CompareNoCase(qGetFile.Category,variables.pageByCategoriesCollection_get_category) EQ 0> selected="selected"</cfif>>#qGetFile.Category#</option>
                        </cfloop>
                      </cfif>
                    </select>
                  </div>
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"pageByCategoriesCollection") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0 AND StructKeyExists(variables,"pageByCategoriesCollection_get_category")>
                  <cfset httpRequest$ = restApiService.PageByCategoriesCollection(category=variables.pageByCategoriesCollection_get_category,userToken=userToken)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.pageByCategoriesCollection_get.submit();">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>  
              </div>
              
              
              <!--- PageByDateCollection: GET --->
                    
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="pageByDateCollection-get"></a>
              <div id="pageByDateCollection-get" class="component-container">
                <h2><strong>PageByDateCollection:</strong> <span>GET</span></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>year</strong>: <span class="data-type-container">integer</span></div>
                </div>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>month</strong>: <span class="data-type-container">integer</span></div>
                </div>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>usertoken</strong>: <span class="data-type-container">string</span></div>
                </div>
                <cfset componentName = "pageByDateCollection">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/pages/dates/<span class="token-container url-token"><cfif StructKeyExists(variables,"pageByDateCollection_get_year")>#variables.pageByDateCollection_get_year#<cfelse>#Year(Now())#</cfif></span>/<span class="token-container url-token"><cfif StructKeyExists(variables,"pageByDateCollection_get_month")>#variables.pageByDateCollection_get_month#<cfelse>#Month(Now())#</cfif></span>/<span class="token-container url-token">empty</span></div>
                </div>
                <form name="pageByDateCollection_get" method="post" action="?httpRequest=pageByDateCollection&verb=get">
                  <label style="margin-top:0px;">Year</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="pageByDateCollection_get_year" id="pageByDateCollection_get_year">
                      <cfloop list="#Year(Now())#,#Year(DateAdd('yyyy',-1,Now()))#" index="year">
                        <option value="#year#"<cfif StructKeyExists(variables,"pageByDateCollection_get_year") AND CompareNoCase(year,variables.pageByDateCollection_get_year) EQ 0> selected="selected"</cfif>>#year#</option>
                      </cfloop>
                    </select>
                  </div>
                  <label>Month</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="pageByDateCollection_get_month" id="pageByDateCollection_get_month" style="margin-bottom:20px;">
                      <cfloop from="1" to="12" index="month">
                        <option value="#month#"<cfif StructKeyExists(variables,"pageByDateCollection_get_month") AND CompareNoCase(month,variables.pageByDateCollection_get_month) EQ 0> selected="selected"</cfif>>#MonthAsString(month)#</option>
                      </cfloop>
                    </select>
                  </div>
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"pageByDateCollection") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0 AND StructKeyExists(variables,"pageByDateCollection_get_year") AND StructKeyExists(variables,"pageByDateCollection_get_month")>
                  <cfset httpRequest$ = restApiService.PageByDateCollection(year=variables.pageByDateCollection_get_year,month=variables.pageByDateCollection_get_month,userToken=userToken)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.pageByDateCollection_get.submit();">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>  
              </div>
              
              <!--- PageByImageCollection: GET --->
                    
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="pageByImageCollection-get"></a>
              <div id="pageByImageCollection-get" class="component-container">
                <h2><strong>PageByImageCollection:</strong> <span>GET</span></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>fileUuid</strong>: <span class="data-type-container">string</span></div>
                </div>
                <cfset componentName = "pageByImageCollection">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/pages/<span class="token-container url-token"><cfif StructKeyExists(variables,"pageByImageCollection_get_fileUuid")>#variables.pageByImageCollection_get_fileUuid#<cfelse>empty</cfif></span></div>
                </div>
                <form name="pageByImageCollection_get" method="post" action="?httpRequest=pageByImageCollection&verb=get">
                  <label style="margin-top:0px;">Images</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="pageByImageCollection_get_fileUuid" id="pageByImageCollection_get_fileUuid" style="margin-bottom:20px;">
                      <CFQUERY NAME="qGetFileUuid" DATASOURCE="#request.domain_dsn#">
                        SELECT * 
                        FROM tblFile INNER JOIN tblComment ON tblFile.File_ID = tblComment.File_ID
                        WHERE tblFile.User_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#qGetUserID.User_ID#"> 
                        GROUP BY tblFile.File_ID 
                        ORDER BY tblFile.Submission_date DESC
                      </CFQUERY>
                      <cfif qGetFileUuid.RecordCount>
                        <cfloop query="qGetFileUuid">
                          <option value="#qGetFileUuid.File_uuid#"<cfif StructKeyExists(variables,"pageByImageCollection_get_fileUuid") AND CompareNoCase(qGetFileUuid.File_uuid,variables.pageByImageCollection_get_fileUuid) EQ 0> selected="selected"</cfif>>#qGetFileUuid.Title#</option>
                        </cfloop>
                      </cfif>
                    </select>
                  </div>
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"pageByImageCollection") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0 AND StructKeyExists(variables,"pageByImageCollection_get_fileUuid")>
                  <cfset httpRequest$ = restApiService.PageByImageCollection(fileUuid=variables.pageByImageCollection_get_fileUuid,userToken=userToken)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.pageByImageCollection_get.submit();">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>  
              </div>
              
              
              <!--- PageByImagesCollection: GET --->
                    
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="pageByImagesCollection-get"></a>
              <div id="pageByImagesCollection-get" class="component-container">
                <h2><strong>PageByImagesCollection:</strong> <span>GET</span></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>usertoken</strong>: <span class="data-type-container">string</span></div>
                </div>
                <cfset componentName = "pageByImagesCollection">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/pages/images/<span class="token-container url-token">empty</span></div>
                </div>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"pageByImagesCollection") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0>
                  <cfset httpRequest$ = restApiService.PageByImagesCollection(userToken=userToken)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="?httpRequest=pageByImagesCollection&verb=get">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>  
              </div>
              
              
              <!--- PageBySearchCollection: GET --->
                    
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="pageBySearchCollection-get"></a>
              <div id="pageBySearchCollection-get" class="component-container">
                <h2><strong>PageBySearchCollection:</strong> <span>GET</span></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>usertoken</strong>: <span class="data-type-container">string</span></div>
                </div>
                <cfset componentName = "pageBySearchCollection">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/pages/search/<span class="token-container url-token">empty</span></div>
                </div>
                <form name="pageBySearchCollection_get" method="post" action="?httpRequest=pageBySearchCollection&verb=get">
                  <label style="margin-top:0px;">Term</label>
                  <input type="text" name="pageBySearchCollection_get_term" id="pageBySearchCollection_get_term" placeholder="Search Term" value="<cfif StructKeyExists(variables,"pageBySearchCollection_get_term")>#variables.pageBySearchCollection_get_term#</cfif>" style="margin-bottom:20px;" />
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"pageBySearchCollection") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0 AND StructKeyExists(variables,"pageBySearchCollection_get_term")>
                  <cfset httpRequest$ = restApiService.PageBySearchCollection(userToken=userToken,term=variables.pageBySearchCollection_get_term)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.pageBySearchCollection_get.submit();">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>  
              </div>
              
              <!--- PageByUseridCollection: GET --->
                    
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="pageByUseridCollection-get"></a>
              <div id="pageByUseridCollection-get" class="component-container">
                <h2><strong>PageByUseridCollection:</strong> <span>GET</span></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>usertoken</strong>: <span class="data-type-container">string</span></div>
                </div>
                <cfset componentName = "pageByUseridCollection">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/pages/userid/<span class="token-container url-token">empty</span></div>
                </div>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"pageByUseridCollection") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0>
                  <cfset httpRequest$ = restApiService.PageByUseridCollection(userToken=userToken)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="?httpRequest=pageByUseridCollection&verb=get">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>  
              </div>
              
              <!--- PageUnapprovedByUseridCollection: GET --->
                    
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="pageUnapprovedByUseridCollection-get"></a>
              <div id="pageUnapprovedByUseridCollection-get" class="component-container">
                <h2><strong>PageUnapprovedByUseridCollection:</strong> <span>GET</span></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>usertoken</strong>: <span class="data-type-container">string</span></div>
                </div>
                <cfset componentName = "pageUnapprovedByUseridCollection">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/pages/unapproved/userid/<span class="token-container url-token">empty</span></div>
                </div>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"pageUnapprovedByUseridCollection") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0>
                  <cfset httpRequest$ = restApiService.PageUnapprovedByUseridCollection(userToken=userToken)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="?httpRequest=pageUnapprovedByUseridCollection&verb=get">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>  
              </div>
              
              
              <!--- PageApprovedByUseridCollection: GET --->
                    
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="pageApprovedByUseridCollection-get"></a>
              <div id="pageApprovedByUseridCollection-get" class="component-container">
                <h2><strong>PageApprovedByUseridCollection:</strong> <span>GET</span></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>usertoken</strong>: <span class="data-type-container">string</span></div>
                </div>
                <cfset componentName = "pageApprovedByUseridCollection">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/pages/approved/userid/<span class="token-container url-token">empty</span></div>
                </div>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"pageApprovedByUseridCollection") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0>
                  <cfset httpRequest$ = restApiService.PageApprovedByUseridCollection(userToken=userToken)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="?httpRequest=pageApprovedByUseridCollection&verb=get">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>  
              </div>
              
      <!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->    
      
              <!--- Pages --->      
              
              <!--- PageCollection: GET --->
                    
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="pageCollection-get"></a>
              <div id="pageCollection-get" class="component-container">
                <h2><strong>PageCollection:</strong> <span>GET</span></h2>
                <cfset componentName = "pageCollection">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/pages</div>
                </div>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"pageCollection") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0>
                  <cfset httpRequest$ = restApiService.PageCollection(userToken=userToken)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="?httpRequest=pageCollection&verb=get">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div> 
              </div>  
              
              
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->    
      
              <!--- Themes --->                
              
              
              <!--- ThemeMember: PUT --->
                    
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="themeMember-put"></a>
              <div id="themeMember-put" class="component-container">
                <h2><strong>ThemeMember:</strong> <span>PUT</span></h2>
                <div class="param-container">
                  <div class="param param-title">required</div> <div class="param param-value"><span class="param-type">required </span><span class="token-container">token:</span> <strong>usertoken</strong>: <span class="data-type-container">string</span></div>
                </div>
                <cfset componentName = "themeMember">
                <cfset funcName = "put">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/theme/<span class="token-container url-token">empty</span></div>
                </div>
                <form name="themeMember_put" method="post" action="?httpRequest=themeMember&verb=put">
                  <label style="margin-top:0px;">Theme</label>
                  <div class="select-container">
                    <i class="fa fa-arrow-circle-down icon"></i>
                    <select name="themeMember_put_theme" id="themeMember_put_theme" style="margin-bottom:20px;">
                      <option value="#themeObj['dark']#"<cfif StructKeyExists(variables,"themeMember_put_theme") AND CompareNoCase(themeObj['dark'],variables.themeMember_put_theme) EQ 0> selected="selected"</cfif>>#themeObj['dark']#</option>
                      <option value="#themeObj['light']#"<cfif StructKeyExists(variables,"themeMember_put_theme") AND CompareNoCase(themeObj['light'],variables.themeMember_put_theme) EQ 0> selected="selected"</cfif>>#themeObj['light']#</option>
                    </select>
                  </div>
                </form>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"themeMember") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"put") EQ 0 AND StructKeyExists(variables,"themeMember_put_theme")>
                  <cfset httpRequest$ = restApiService.ThemeMember(theme=variables.themeMember_put_theme,authorization=authorization,userToken=userToken)>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="javascript:document.themeMember_put.submit();">PUT</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div>  
              </div>
              
              
              <!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->    
      
              <!--- Tokens --->      
              
              <!--- TokenMember: GET --->
                    
              <div class="component-container-divider"></div>
              <a class="component-anchor" name="tokenMember-get"></a>
              <div id="tokenMember-get" class="component-container">
                <h2><strong>TokenMember:</strong> <span>GET</span></h2>
                <cfset componentName = "tokenMember">
                <cfset funcName = "get">
                <cfinclude template="../requestData.cfm">
                <div class="curl-container">
                  <div class="curl curl-title">curl</div><div class="curl curl-url">#restApiEndpoint#/token</div>
                </div>
                <cfif StructKeyExists(variables,"httpRequest") AND CompareNoCase(variables['httpRequest'],"tokenMember") EQ 0 AND StructKeyExists(variables,"verb") AND CompareNoCase(variables['verb'],"get") EQ 0>
                  <cfset httpRequest$ = restApiService.TokenMember()>
                  <cfinclude template="../http-request-to-json.cfm">
                  <cfinclude template="../delete-request-vars.cfm">
                </cfif>
                <div class="button-container"><a class="button verb" href="?httpRequest=tokenMember&verb=get">GET</a><a class="button clear" href="../components/restApiService.cfm">Clear</a><a class="button top" href="##top"><i class="fa fa-arrow-up"></i></a></div> 
              </div>
            
            </div>
                                                                                                    
                                
          </cfif>
        
        </div>
        
        <div style="clear:both;"></div>
      
      </div>
      
      <script src="../../js/highlight.js/highlight.pack.js"></script>
      <script>hljs.initHighlightingOnLoad();</script>
    
    </body>
    
  </html>

</cfoutput>