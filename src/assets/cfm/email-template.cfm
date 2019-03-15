<cfoutput>

  <cfparam name="emailtemplateheaderbackground" default="" />
  <cfparam name="emailtemplatemessage" default="" />
  
  <html>

    <head>
    
      <meta name="viewport" content="width=device-width,initial-scale=1.0">
  
      <title></title>

      <style>
      
        a{
            text-decoration:underline;
            color:##337ab7;
            cursor:pointer;
        }
        
        a:hover{
            color:##000;
        }
        
        a.no-decoration{
            text-decoration:none;
            color:##000;
        }
        
        h1{
            color:##818181;
            margin:0px 0px 20px;
            line-height:22px;
        }
        
        H1.profile{
          color:##818181;
          margin:0.67em 0px;
          line-height:36px;
        }
        
        body {
            font-family:Arial, Helvetica, sans-serif;
            font-size:16px;
            background:##fff;
        }
        
        table td{
            font-family:Arial, Helvetica, sans-serif;
            font-size:16px;
        }
        
        table td.email-template-shadow{
            width:49%;
        }
        
        table td.email-template-shadow img{
            width:100%;
        }

        table td.image img{
            width:100%;
        }
        
        table td.news blockquote{
            background:##f6f6f6;
            border-left:10px solid ##DDDDDD;
            padding-left:20px;
            margin:0px; 
        }
        
        table td.news p{
            margin:16px 0px; 
        }
        
        table td.date{
            color:rgba(0,0,0,0.25);
            font-size:12px;
        }
        
        table td.title{
            color:rgba(0,0,0,0.5);
            font-size:16px;
            font-weight:bold;
        }
        
        table td.unsubscribe{
            font-weight:bold;
            font-size:12px;
        }
        
        a.activate-account-btn{
            display:block;
            width:250px;
            padding:20px;
            background:##8AB9C9;
            font-family:Arial, Helvetica, sans-serif;
            color:##fff;
            font-weight:bold;
            text-align:center;
            -webkit-border-radius:4px;
            -moz-border-radius:4px;
            border-radius:4px;
        }
        
        strong.blockquote{
            display:block;
            border-left:15px solid rgba(0,0,0,0.75);
            padding-left:20px;
            color:rgba(0,0,0,0.5);
        }
        
        table.profile img.avatar{
            width:150px;
            height:150px;
            border:15px solid rgba(0,0,0,0.1);
            background:rgba(0,0,0,0.05);
            -webkit-border-radius:50%;
            -moz-border-radius:50%;
            border-radius:50%;
            margin-top:20px;
        }
        
        table.profile object{
            width:150px;
            height:150px;
            -webkit-border-radius:50%;
            -moz-border-radius:50%;
            border-radius:50%;
            margin-top:20px;
        }

      </style>
    
    </head>
    
    <body>
    
      <table cellpadding="0" cellspacing="0" border="0" width="100%" style="font-size:16px;background:##fff;">
        <tr>
          <td align="center">
          
            <table cellpadding="0" cellspacing="0" border="0" width="100%">
              <tr>
                <td colspan="3">
          
                   <table cellpadding="0" cellspacing="0" border="0" width="100%" style="padding:30px;border:1px solid ##D6D6D6;">
                    <tr>
                      <td>
                        
                        <table cellpadding="0" cellspacing="0" border="0" width="100%" style="font-size:16px;">
                          <tr>
                            <td colspan="3">
                              
                              <!-- content start -->
                              
                              <table cellpadding="0" cellspacing="0" border="0" width="100%">
                                <tr valign="bottom">
                                  <td align="center" height="142"<cfif Len(Trim(emailtemplateheaderbackground))> bgcolor="#emailtemplateheaderbackground#"</cfif> style="font-size:0px;vertical-align:bottom;"><img src="#request.emailimagesrc#/logo-1.png" alt="#request.emailimagealt#: image" width="144" height="71" /></td>
                                </tr>
                                <tr valign="top">
                                  <td align="center" height="71" bgcolor="##f9f9f9" style="font-size:0px;"><img src="#request.emailimagesrc#/logo-2.png" alt="#request.emailimagealt#: image" width="144" height="71" /></td>
                                </tr>
                                <tr>
                                  <td height="20" bgcolor="##f9f9f9"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="1" height="20" /></td>
                                </tr>
                                <tr valign="middle">
                                  <td align="center" bgcolor="##f6f6f6">
                                  
                                    <table class="profile" cellpadding="20" cellspacing="0" border="0" width="100%">
                                      <tr valign="middle">
                                        <td class="news" style="font-size:16px;">
                                          
                                          #emailtemplatemessage#
                                          
                                        </td>
                                      </tr>
                                    </table>
                              
                                  </td>
                                </tr>
                                <tr>
                                  <td height="20" bgcolor="##f6f6f6"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="1" height="20" /></td>
                                </tr>
                              </table>                              
                              
                              <!-- content end -->
                              
                            </td>
                          </tr>
                          
                          <tr>
                            <td colspan="3" height="10"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="1" height="10" /></td>
                          </tr>
                          <tr valign="middle">
                            <td align="left">
                            
                              <table cellpadding="20" cellspacing="0" border="0" width="120" height="58">
                                <tr valign="middle">
                                  <td align="center" class="date" bgcolor="##f9f9f9">
                                    #DateFormat(Now(),"mmm dd, yyyy")#
                                  </td>
                                </tr>
                              </table>
                            
                            </td>
                            <td align="right">
                            
                              <table cellpadding="20" cellspacing="0" border="0" width="190">
                                <tr valign="middle">
                                  <td align="center" class="title" bgcolor="##f9f9f9">
                                    Photo Gallery S.P.A
                                  </td>
                                </tr>
                              </table>
                              
                            </td>
                            <td align="right"></td>
                          </tr>
                        </table>
          
                      </td>
                    </tr>
                  </table>
              
                </td>
              </tr>
              <tr valign="top">
                <td class="email-template-shadow" height="12"><img src="#request.emailimagesrc#/shadow-left.png" border="0"  /></td>
                <td height="12"><img src="#request.emailimagesrc#/pixel_100.gif" border="0" width="1" height="12" /></td>
                <td class="email-template-shadow" height="12" align="right"><img src="#request.emailimagesrc#/shadow-right.png" border="0" /></td>
              </tr>
            </table>
      
          </td>
        </tr>
      </table>

    </body>

  </html>
  
</cfoutput>