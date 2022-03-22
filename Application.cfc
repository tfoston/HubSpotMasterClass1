component output="true" returnformat="json"   {
 
	//APP
	this.name = "MASTERCLASS-APP-DEMO-2022-03-20";
	this.applicationTimeout = createTimeSpan(365,0,0,0);

	//Session management
	this.sessionmanagement = true;
	this.sessionTimeout = createTimeSpan(0,2,0,0);
	this.clientmanagement = true;
	this.scriptProtect=true;
	this.setClientCookies = true;
	this.setdomaincookies = true;
	this.sessioncookie = {
		httpOnly:true,
		secure:true
	};
	
    this.datasources["masterclass_demo"] = {
        class: 'com.mysql.cj.jdbc.Driver'
        , bundleName: 'com.mysql.cj'
        , bundleVersion: '8.0.19'
        , connectionString: 'jdbc:mysql://localhost:3306/masterclass?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=CONVERT_TO_NULL&verifyServerCertificate=false&tinyInt1isBit=false&serverTimezone=UTC&autoReconnect=false&useSSL=false&maxReconnects=3&jdbcCompliantTruncation=false&allowMultiQueries=true&useLegacyDatetimeCode=true'
        , username: 'root'
        , password: "encrypted:c38943f726f491659deaef6fa08115ade6006bca5fa487e3"
        , blob:true
        , clob:true 
        , connectionLimit:100 
        , connectionTimeout:1 
        , alwaysSetTimeout:true 
        , validate:false 
    }

	this.datasource = "masterclass_demo";


	public void function onApplicationStart(){
		
	}


	/*
	 * @output true
	 */
	public void function onSessionStart(){ 
		
	}

	/*
	 * @output false
	 */
	public void function onSessionEnd( struct sessionScope, struct applicationScope ){

	}


	/*
	 * @output true
	 */
	public boolean function onRequestStart(string template){

		Request.app = {};

        //Grab all of the config data from the database 
		```<cfquery name="configRS">
			SELECT * 
			FROM `config` 
		</cfquery>```
        
		for( _.row in configRS ){
			Request.app[ _.row.config_key ] = _.row.config_value;
		}

		return true;
    }
	
	public boolean function onRequest(required string template){

		var content = '';

        savecontent variable="content"{
            include arguments.template;
		}

        writeoutput( content );

		return true;
	}
	
	/*
	 * @output true
	 */
	public boolean function onRequestEnd( required string targetPage ){
		return true;
	}
	
	public void function onError( Any exceptionData){

		writedump( var=exceptionData, label="exceptionData")
	}	

	/*
	 * @output false
	 */
	public boolean function onApplicationEnd(){
		return true;
    }

}