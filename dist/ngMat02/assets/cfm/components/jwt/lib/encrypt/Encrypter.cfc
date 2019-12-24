<cfscript>

  component
	  output = false
	  hint = "I encrypt and decrypt values using the Java based asymmetric and symmetric algorithms. There are 5 segments in a JWE (JSON Web Encryption), rather than 3, as in a JWT (JSON Web Token) or a JWS (JSON Web Signature). The segments, in order, are: JOSE header, JWE Encrypted Key, JWE initialization vector, JWE Additional Authentication Data (AAD), JWE Ciphertext and JWE Authentication Tag. The 2nd segment, JWE Encrypted Key, is encrypted, using the RSA-OAEP encryption scheme, which uses an RSA algorithm with the Optimal Asymmetric Encryption Padding (OAEP) method. The 4th segment, JWE Ciphertext, is encrypted, using the Advanced Encryption Standard (AES) in Galois/Counter Mode (GCM) algorithm with a 256-bit long key. Once decrypted, the JWE Encrypted Key, uses a symmetric key algorithm, specifically designed to be used with Authenticated Encryption with Associated Data (AEAD), to decrypt the JWE Ciphertext or payload. The associated data, which is part of the AEAD scheme, is stored in the 5th segment (JWE Authentication Tag). The 3rd and 5th segments, JWE initialization vector and JWE Authentication Tag, are extracted, during the encryption cipher creation, which is used to encrypt segment 4. All segments are Base64 encoded to ensure a successful transit."
	  { 
	  
	  /*
	  *
	  * PRIVATE VARIABLES
	  * 
	  */
	  
	  variables.loader = "";
	  variables.jwtSignEncrypt = "";
	  
	  variables.issuer = "";
	  variables.subject = "";
	  variables.audience = "";
	  variables.expirationTime = "";
	  variables.notBeforeTime = "";
	  variables.issueTime = "";
	  variables.jwtID = "";
	  variables.claim = {
		  name = JavaCast( "null", "" )
	  };
	  variables.claimSet = {};
  
	  variables.secretKeyEncoded = "";
	  
	  variables.messages = "";
  
	  /*
	  *
	  * CONSTRUCTOR
	  *
	  * I initialize the encrypter.
	  * 
	  * @iss I am the registered claimset issuer.
	  * @sub I am the registered claimset subject.
	  * @aud I am the registered claimset audience.
	  * @exp I am the registered claimset expiration time.
	  * @nbf I am the registered claimset not before time.
	  * @iat I am the registered claimset issue time.
	  * @jti I am the registered claimset jwt ID.
	  * @claim I am the custom claim.
	  * @claimSet I am the claimset.
	  * @javaLoaderClassPath I am the java loader class path.
	  * @jarSystemPath I am the JWT sign encrypt jar system path.
	  * @useJavaLoader I determine whether to use 'JavaLoader' or 'this.javaSettings'.
	  * @javaLoaderInstance I am a singleton 'JavaLoader' instance created in the application.cfc.
	  * @output false 
	  *
	  */
	  
	  public any function init(
		string iss,
		string sub,
		string aud,
		date exp,
		date nbf,
		date iat,
		string jti,
		struct claim,
		struct claimSet,
		string secretKey,
		required string javaLoaderClassPath,
		required string jarSystemPath,
		boolean useJavaLoader = true,
		any javaLoaderInstance = ""
		) {
			
		var local = {};
		
		SetLoader( arguments.javaLoaderClassPath, arguments.jarSystemPath, arguments.javaLoaderInstance );
		
		if ( StructKeyExists( arguments, "claimSet" ) ) {
			
		  SetClaimSet( arguments.claimSet );
		  
		  local.claimSet = {};
		  
		  if ( StructKeyExists( arguments.claimSet, "iss" ) ) {
			SetIssuer( arguments.claimSet[ 'iss' ] );
			local.claimSet[ 'iss' ] = variables.issuer;
		  }
		  
		  if ( StructKeyExists( arguments.claimSet, "sub" ) ) {
			SetSubject( arguments.claimSet[ 'sub' ] );
			local.claimSet[ 'sub' ] = variables.subject;
		  }
		  
		  if ( StructKeyExists( arguments.claimSet, "aud" ) ) {
			SetAudience( arguments.claimSet[ 'aud' ] );
			local.claimSet[ 'aud' ] = variables.audience;
		  }
		  
		  if ( StructKeyExists( arguments.claimSet, "exp" ) ) {
			SetExpirationTime( arguments.claimSet[ 'exp' ] );
			local.claimSet[ 'exp' ] = variables.expirationTime;
		  }
		  
		  if ( StructKeyExists( arguments.claimSet, "nbf" ) ) {
			SetNotBeforeTime( arguments.claimSet[ 'nbf' ] );
			local.claimSet[ 'nbf' ] = variables.notBeforeTime;
		  }
		  
		  if ( StructKeyExists( arguments.claimSet, "iat" ) ) {
			SetIssueTime( arguments.claimSet[ 'iat' ] );
			local.claimSet[ 'iat' ] = variables.issueTime;
		  }
		  
		  if ( StructKeyExists( arguments.claimSet, "jti" ) ) {
			SetJwtID( arguments.claimSet[ 'jti' ] );
			local.claimSet[ 'jti' ] = variables.jwtID;
		  }
		  
		  if ( StructKeyExists( arguments.claimSet, "claim" ) ) {
			SetClaim( arguments.claimSet[ 'claim' ] );
			local.claimSet[ 'claim' ] = variables.claim;
		  }
		  
		  if ( arguments.useJavaLoader ) {
			SetJwtSignEncrypt( variables.loader.create( "com.chamika.jwt.JwtSignEncrypt" ).init( local.claimSet ) );
		  }
		  else{
			SetJwtSignEncrypt( createObject( 'java', 'com.chamika.jwt.JwtSignEncrypt' ).init( local.claimSet ) );  
		  }
		  
		  if ( StructKeyExists( arguments, "secretKey" ) AND Len( Trim( arguments.secretKey ) ) ) {
			SetSecretKeyEncoded( arguments.secretKey );
		  }
		  else{
			SetSecretKeyEncoded();
		  }
		  		  
		}
		else{
		
		  if ( StructKeyExists( arguments, "iss" ) || StructKeyExists( arguments, "sub" ) || StructKeyExists( arguments, "aud" ) || StructKeyExists( arguments, "exp" ) || StructKeyExists( arguments, "nbf" ) || StructKeyExists( arguments, "iat" ) || StructKeyExists( arguments, "jti" ) || StructKeyExists( arguments, "claim" ) ) {
			  
			  if ( StructKeyExists( arguments, "iss" ) ) {
				SetIssuer( arguments.iss );
			  }
			  
			  if ( StructKeyExists( arguments, "sub" ) ) {
				SetSubject( arguments.sub );
			  }
			  
			  if ( StructKeyExists( arguments, "aud" ) ) {
				SetAudience( arguments.aud );
			  }
			  
			  if ( StructKeyExists( arguments, "exp" ) ) {
				SetExpirationTime( arguments.exp );
			  }
			  
			  if ( StructKeyExists( arguments, "nbf" ) ) {
				SetNotBeforeTime( arguments.nbf );
			  }
			  
			  if ( StructKeyExists( arguments, "iat" ) ) {
				SetIssueTime( arguments.iat );
			  }
			  
			  if ( StructKeyExists( arguments, "jti" ) ) {
				SetJwtID( arguments.jti );
			  }
			  
			  if ( StructKeyExists( arguments, "claim" ) ) {
				SetClaim( arguments.claim );
			  }
			  
			  if ( arguments.useJavaLoader ) {
			  
				SetJwtSignEncrypt( 
				  variables.loader.create( "com.chamika.jwt.JwtSignEncrypt" ).init( 
					variables.issuer EQ "" ? JavaCast( "null", "" ) : variables.issuer, 
					variables.subject EQ "" ? JavaCast( "null", "" ) : variables.subject, 
					variables.audience EQ "" ? JavaCast( "null", "" ) : variables.audience, 
					NOT IsDate( variables.expirationTime ) ? JavaCast( "null", "" ) : variables.expirationTime, 
					NOT IsDate( variables.notBeforeTime ) ? JavaCast( "null", "" ) : variables.notBeforeTime, 
					NOT IsDate( variables.issueTime ) ? JavaCast( "null", "" ) : variables.issueTime, 
					variables.jwtID EQ "" ? JavaCast( "null", "" ) : variables.jwtID, 
					StructIsEmpty( variables.claim ) ? JavaCast( "null", "" ) : variables.claim 
				  )
				);
			  
			  }
			  else{ 

				SetJwtSignEncrypt( 
				  createObject( 'java', 'com.chamika.jwt.JwtSignEncrypt' ).init( 
					variables.issuer EQ "" ? JavaCast( "null", "" ) : variables.issuer, 
					variables.subject EQ "" ? JavaCast( "null", "" ) : variables.subject, 
					variables.audience EQ "" ? JavaCast( "null", "" ) : variables.audience, 
					NOT IsDate( variables.expirationTime ) ? JavaCast( "null", "" ) : variables.expirationTime, 
					NOT IsDate( variables.notBeforeTime ) ? JavaCast( "null", "" ) : variables.notBeforeTime, 
					NOT IsDate( variables.issueTime ) ? JavaCast( "null", "" ) : variables.issueTime, 
					variables.jwtID EQ "" ? JavaCast( "null", "" ) : variables.jwtID, 
					StructIsEmpty( variables.claim ) ? JavaCast( "null", "" ) : variables.claim 
				  )
				);
			  
			  }
			  
			  if ( StructKeyExists( arguments, "secretKey" ) AND Len( Trim( arguments.secretKey ) ) ) {
				SetSecretKeyEncoded( arguments.secretKey );
			  }
			  else{
				SetSecretKeyEncoded();
			  }
			  			  
		  }
		  else{
			  
			  if ( arguments.useJavaLoader ) {
				SetJwtSignEncrypt( variables.loader.create( "com.chamika.jwt.JwtSignEncrypt" ).init() );
			  }
			  else{
				SetJwtSignEncrypt( createObject( 'java', 'com.chamika.jwt.JwtSignEncrypt' ).init() );
			  }
			  
		  }
		
		}
		
		return( this );
  
	  }
  
	  /*
	  *
	  * GETTER & SETTER METHODS
	  *
	  */
	  
	  /*
	  *
	  * I set the loader.
	  * 
	  * @javaLoaderClassPath I am the java loader class path.
	  * @jarSystemPath I am the jwt sign encrypt jar system path.
	  * @javaLoaderInstance I am a singleton 'JavaLoader' instance created in the application.cfc. 
	  * @output false
	  *
	  */
	  
	  private void function SetLoader( required string javaLoaderClassPath, required string jarSystemPath, required any javaLoaderInstance ) { 
		
		if ( IsObject( arguments.javaLoaderInstance ) ) {
			variables.loader = arguments.javaLoaderInstance;
		}
		else {
		  if ( FileExists( arguments.jarSystemPath ) ) {
			variables.loader = createObject( 'component', arguments.javaLoaderClassPath );
			variables.loader = variables.loader.init( [ arguments.jarSystemPath ] );
		  }
		  else{
			throw( message = "File cannot be found", detail = "Jar System Path file cannot be found..." );
		  }
		}

	  }
	  
	  /*
	  *
	  * I get the loader.
	  * 
	  * @output false
	  *
	  */
	  
	  public any function GetLoader() { 
	  
		return variables.loader;

	  }
	  
	  /*
	  *
	  * I set the jwtSignEncrypt object.
	  * 
	  * @jwtSignEncrypt I am the jwtSignEncrypt object.
	  * @output false
	  *
	  */
	  
	  private void function SetJwtSignEncrypt( required any jwtSignEncrypt ) { 
		
		variables.jwtSignEncrypt = arguments.jwtSignEncrypt;

	  }
	  
	  /*
	  *
	  * I get the jwtSignEncrypt object.
	  * 
	  * @output false
	  *
	  */
	  
	  public any function GetJwtSignEncrypt() { 
	  
		return variables.jwtSignEncrypt;

	  }
	  
	  /*
	  *
	  * I set the claim set.
	  * 
	  * @claimSet I am the claim set.
	  * @output false
	  *
	  */
	  
	  private void function SetClaimSet( required struct claimSet ) { 
	  
		variables.claimSet = arguments.claimSet;

	  }
	  
	  /*
	  *
	  * I get the claim set.
	  * 
	  * @output false
	  *
	  */
	  
	  public struct function GetClaimSet() { 
	  
		return variables.claimSet;

	  }
	  
	  /*
	  *
	  * I set the issuer.
	  * 
	  * @issuer I am the issuer.
	  * @output false
	  *
	  */
	  
	  private void function SetIssuer( required string issuer ) { 
	  
		variables.issuer = JavaCast( "string", arguments.issuer );

	  }
	  
	  /*
	  *
	  * I get the issuer.
	  * 
	  * @output false
	  *
	  */
	  
	  public string function GetIssuer() { 
	  
		return variables.issuer;

	  }
	  
	  /*
	  *
	  * I set the subject.
	  * 
	  * @subject I am the subject.
	  * @output false
	  *
	  */
	  
	  private void function SetSubject( required string subject ) { 
	  
		variables.subject = JavaCast( "string", arguments.subject );

	  }
	  
	  /*
	  *
	  * I get the subject.
	  * 
	  * @output false
	  *
	  */
	  
	  public string function GetSubject() { 
	  
		return variables.subject;

	  }
	  
	  /*
	  *
	  * I set the audience.
	  * 
	  * @audience I am the audience.
	  * @output false
	  *
	  */
	  
	  private void function SetAudience( required string audience ) { 
	  
		variables.audience = JavaCast( "string", arguments.audience );

	  }
	  
	  
	  /**
	  * I get the audience.
	  * 
	  * @output false
	  */
	  
	  public string function GetAudience() { 
	  
		return variables.audience;

	  }
	  
	  /*
	  *
	  * I set the expiration time.
	  * 
	  * @expirationTime I am the expiration time.
	  * @output false
	  *
	  */
	  
	  private void function SetExpirationTime( required string expirationTime ) { 
	  
		if ( IsDate( arguments.expirationTime ) ) {
		  variables.expirationTime = createObject( "java", "java.util.Date" ).init( arguments.expirationTime.getTime() );
		}

	  }
	  
	  /*
	  *
	  * I get the expiration time.
	  * 
	  * @output false
	  *
	  */
	  
	  public date function GetExpirationTime() { 
	  
		return variables.expirationTime;

	  }
	  
	  /*
	  *
	  * I set the not before time.
	  * 
	  * @notBeforeTime I am the not before time.
	  * @output false
	  *
	  */
	  
	  private void function SetNotBeforeTime( required string notBeforeTime ) { 
	  
		if ( IsDate( arguments.notBeforeTime ) ) {
		  variables.notBeforeTime = createObject( "java", "java.util.Date" ).init( arguments.notBeforeTime.getTime() );
		}

	  }
	  
	  /*
	  *
	  * I get the issue time.
	  * 
	  * @output false
	  *
	  */
	  
	  public date function GetIssueTime() { 
	  
		return variables.issueTime;

	  }
	  
	  /*
	  *
	  * I set the issue time.
	  * 
	  * @issueTime I am the issue time.
	  * @output false
	  *
	  */
	  
	  private void function SetIssueTime( required string issueTime ) { 
	  
		if ( IsDate( arguments.issueTime ) ) {
		  variables.issueTime = createObject( "java", "java.util.Date" ).init( arguments.issueTime.getTime() );
		}

	  }
	  
	  /*
	  *
	  * I get the not before time.
	  * 
	  * @output false
	  *
	  */
	  
	  public date function GetNotBeforeTime() { 
	  
		return variables.notBeforeTime;

	  }
	  
	  /*
	  *
	  * I set the jwt ID.
	  * 
	  * @jwtID I am the jwt ID.
	  * @output false
	  *
	  */
	  
	  private void function SetJwtID( required string jwtID ) { 
	  
		variables.jwtID = JavaCast( "string", arguments.jwtID );

	  }
	  
	  /*
	  *
	  * I get the jwt ID.
	  * 
	  * @output false
	  *
	  */
	  
	  public string function GetJwtID() { 
	  
		return variables.jwtID;

	  }
	  
	  /*
	  *
	  * I set the custom claim.
	  * 
	  * @claim I am the custom claim.
	  * @output false
	  *
	  */
	  
	  private void function SetClaim( required struct claim ) { 
	  
		variables.claim = arguments.claim;

	  }
	  
	  /*
	  *
	  * I get the custom claim.
	  * 
	  * @output false
	  *
	  */
	  
	  public struct function GetClaim() { 
	  
		return variables.claim;

	  }

	  /*
	  *
	  * I set the secret key encoded.
	  * 
	  * @secretKeyEncoded I am the secret key.
	  * @output false
	  *
	  */
	  
	  private void function SetSecretKeyEncoded( any secretKey ) { 
	  
		var local = {};
	  
		if ( StructKeyExists( arguments, "secretKey" ) AND Len ( Trim ( arguments.secretKey ) ) AND NOt IsBinary( arguments.secretKey ) ) {

		  local.secretKeySpec = getLoader().create( "javax.crypto.spec.SecretKeySpec" ).init( 
			CharsetDecode( arguments.secretKey, "utf-8" ), 
			JavaCast( "string", "AES" ) 
		  );
		  
		  variables.secretKeyEncoded = local.secretKeySpec.getEncoded();

		}
		else{
			
		  local.keyGen = getLoader().create( "javax.crypto.KeyGenerator" ).getInstance( "AES" );
		  local.keyGen.init( 256 );
		  variables.secretKeyEncoded = local.keyGen.generateKey().getEncoded();
		  
		}

	  }
	  
	  /*
	  *
	  * I get the secret key encoded.
	  * 
	  * @output false
	  *
	  */
	  
	  public binary function GetSecretKeyEncoded() { 
	  
		  return variables.secretKeyEncoded;

	  }

	  /*
	  *
	  *JWT METHODS
	  *
	  */
	  
	  /*
	  *
	  * I compose a signed encrypted JWT from a claimset.
	  * 
	  * @secretKeyEncoded I am the secret key encoded.
	  * @output false
	  *
	  */
	  
	  public string function Encrypt( binary secretKeyEncoded ) { 
	  
		var local = {};
		
		try{
		  local.jwtString = GetJwtSignEncrypt().Encrypt( arguments.secretKeyEncoded );
		}
		catch( any e ) {
		  local.jwtString = "";
		}
		
		return local.jwtString;

	  }
	  
	  /*
	  *
	  * I compose a decrypted decoded JSON claimset from a signed encrypted JWT.
	  * 
	  * @jweString I am the JWT string.
	  * @secretKeyEncoded I am the secret key encoded.
	  * @output false
	  *
	  */
	  
	  public struct function Decrypt( string jwtString, binary secretKeyEncoded  ) { 
	  
		var local = {};
				
		local.decryptedJwtClaimset = {};
		
		try{
		  local.decryptedJwtString = GetJwtSignEncrypt().Decrypt( arguments.jwtString, arguments.secretKeyEncoded );
		}
		catch( any e ) {
		  local.decryptedJwtString = "";
		}
		
		if ( Len( Trim( local.decryptedJwtString ) ) AND IsJson( local.decryptedJwtString ) ) {
		  local.decryptedJwtClaimset = DeserializeJson( local.decryptedJwtString );
		}
		
		return local.decryptedJwtClaimset;

	  }
	  
	  /*
	  *
	  * I check to see whether the JWT has expired.
	  * 
	  * @output false
	  *
	  */
	  
	  public boolean function HasExpired() { 
	  
		var local = {};
		
		local.hasExpired = false;
		
		if ( IsDate( variables.expirationTime ) ) {
			
			if ( DateCompare( variables.expirationTime, Now() ) EQ -1 ) {
				local.hasExpired = true;
			}
			
		}
		
		return local.hasExpired;

	  }
	  
	  /*
	  *
	  * UTILITY METHODS
	  *
	  */
	  
	  /*
	  *
	  * I set date from epoch date.
	  * 
	  * @epoch I am the epoch.
	  * @output false
	  *
	  */
	  
	  public date function EpochTimeToLocalDate( any epoch ) {
		  
		var local = {};
		
		local.date = "";
		
		if ( IsValid( "integer", arguments.epoch ) ) {
			local.date = DateAdd( "s", arguments.epoch, DateConvert( "utc2Local", "January 1 1970 00:00" ) );
		} 
		else if ( IsNumeric( arguments.epoch ) AND Val( arguments.epoch ) GT 1000 ) {
			local.date = DateAdd( "s", arguments.epoch/1000, DateConvert( "utc2Local", "January 1 1970 00:00" ) );
		}
		
		return local.date;
		
	  }
  
  }

</cfscript>