component  {

    //property name="auth-method" value="token";
    this.authmethod = "token";
    this.authconfig = {};


    public function init( required string token ){
        variables.token = arguments.token;
        variables.APIURLBase = "https://api.hubapi.com";
        variables.tokenURL = 'https://api.hubapi.com/oauth/v1/token';

        this.authconfig = {
            token:variables.token,
            APIURLBase:variables.APIURLBase,
            tokenURL:variables.tokenURL,
            authmethod:"token"
        };
    }

   

    public struct function getContactByEmail( required string email, array additionalProps = []  ){
        var APIURL = "/contacts/v1/contact/email/#URLEncodedFormat(arguments.email)#/profile?property=firstname&property=lastname&property=company";
        APIURL &= "&property=email&property=phone"

        var prop = '';

        for( prop in arguments.additionalProps){
            APIURL &= '&property=' & prop;
        }

        return variables.apiCallGet( APIURL );
    }

    public struct function getContactByID( required numeric contactID, array additionalProps = []  ){

        var APIURL = "/contacts/v1/contact/vid/#arguments.contactID#/profile?property=firstname&property=lastname&property=company";
        APIURL &= "&property=email";

        var prop = '';

        for( prop in arguments.additionalProps){
            APIURL &= '&property=' & prop;
        }

        return variables.apiCallGet( APIURL );
    }

    public any function batchObjectSearch( required string object_type, required arrayOfSearchParams, array arryOfProperties = [], numeric offset = 0, numeric limit = 100, array sorts = [] ){

        var _ = {};

        _.APIURL = "#variables.APIURLBase#/crm/v3/objects/#arguments.object_type#/search";

        _.payload = {
            filterGroups:[]
        }

        _.tmpFilterObj = {
            filters: []
        }

        for( _.tmpObj in arguments.arrayOfSearchParams ){

            param name="_.tmpObj.operator" default="EQ";
            

            if( structKeyExists(_.tmpObj, "value") ){
                _.tmpFilterObj.filters.add(
                    {
                        "value": _.tmpObj.value ,
                        "propertyName": _.tmpObj.key,
                        "operator": _.tmpObj.operator
                    }          
                );
            }


            if( structKeyExists(_.tmpObj, "values") ){
                _.tmpFilterObj.filters.add(
                    {
                        "values": _.tmpObj.values ,
                        "propertyName": _.tmpObj.key,
                        "operator": _.tmpObj.operator
                    }              
                );
            }            
        }

        if( _.tmpFilterObj.filters.size() > 0  ) _.payload.filterGroups.add( _.tmpFilterObj );        

        _.payload.limit = arguments.limit;
        _.payload.after = arguments.offset;


        if( arguments.sorts.size() > 0 ){
            _.payload.sorts = [
                {
                  "propertyName": "lastmodifieddate",
                  "direction": "DESCENDING"
                }
              ]       
        }        
 

        if( arguments.arryOfProperties.size() > 0 ) _.payload.properties = arguments.arryOfProperties;

        _.httpCall = new HTTP();        
        _.httpCall.setURL( _.APIURL );
        _.httpCall.setMethod("POST");
        _.httpCall.addParam( type="header", name="Content-Type", value="application/json");
        _.httpCall.addParam( type="header", name="Authorization", value="Bearer #variables.token#" );
        _.httpCall.addParam( type="body", value=serializeJSON(_.payload) );
		_.httpResponse = _.httpCall.send().getPrefix();

        return deserializeJSON( _.httpResponse.FileContent );

    }


    public any function createObjectProperty( required string objectType, required struct propPayload ){

        var _ = {};

        _.APIURL = "https://api.hubapi.com/crm/v3/properties/#arguments.objectType#";

        _.httpCall = new HTTP();        
        _.httpCall.setURL( _.APIURL );
        _.httpCall.setMethod("POST");
        _.httpCall.addParam( type="header", name="Content-Type", value="application/json");
        _.httpCall.addParam( type="body", value=serializeJSON( arguments.propPayload ) );
        _.httpCall.addParam( type="header", name="Authorization", value="Bearer #variables.token#");

        return _.httpCall.send();        


    }


    public struct function createCRMAssociation( required numeric hubspot_defined_id, required string fromObjectID, required string toObjectId ){

        var _ = {};

        _.APIURL = "#variables.APIURLBase#/crm-associations/v1/associations/";

        _.payload = {
            "fromObjectId": arguments.fromObjectID,
            "toObjectId": arguments.toObjectId,
            "category": "HUBSPOT_DEFINED",
            "definitionId": arguments.hubspot_defined_id
        }

        _.httpCall = new HTTP();        
        _.httpCall.setURL( _.APIURL );
        _.httpCall.setMethod("PUT");
        _.httpCall.addParam( type="header", name="Content-Type", value="application/json");
        _.httpCall.addParam( type="body", value=serializeJSON(_.payload) );
        _.httpCall.addParam( type="header", name="Authorization", value="Bearer #variables.token#");

        return _.httpCall.send();
    }


    public array function getOwners(){
        return variables.apiCallGet( "/owners/v2/owners" ); 
    }

    public any function getContactsBySearch( required string searchterms ){      
        return variables.apiCallGet( "/contacts/v1/search/query?q=#searchterms#" );         
    }

    public any function getContactsByIDs( required array arrayOfContactIDs, array  arrayOfProperties = [] ){

        var _ = {};

        _.APIURL = "/contacts/v1/contact/vids/batch/?";

        for( _.contactID in  arguments.arrayOfContactIDs){
            _.APIURL &= ("vid=" & _.contactID & "&");
        }
		
		for( _.tmpProp in arrayOfProperties){
			_.APIURL &= ("property=" & _.tmpProp & "&");
		}
        
        return variables.apiCallGet( _.APIURL );         
    }

    public struct function requestTokenUsingCode( required string code, required string client_id, required string client_secret, required string redirect_url ){

        var _ = {};

        _.httpCall = new HTTP();
        _.httpCall.setURL( 'https://api.hubapi.com/oauth/v1/token' );
        _.httpCall.setMethod("POST");
        _.httpCall.addParam( type="header", name="Content-Type", value="application/x-www-form-urlencoded");
        _.httpCall.addParam( type="header", name="User-Agent", value="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.117 Safari/537.36");
        _.httpCall.addParam( type="formfield", name="grant_type", value="authorization_code");
        _.httpCall.addParam( type="formfield", name="client_id", value="#arguments.client_id#");
        _.httpCall.addParam( type="formfield", name="client_secret", value="#arguments.client_secret#");
        _.httpCall.addParam( type="formfield", name="redirect_uri", value="#arguments.redirect_url#");
        _.httpCall.addParam( type="formfield", name="code", value="#arguments.code#");        

        _.apiResponse = _.httpCall.send();
        
        _.responseContent = _.apiResponse.getPrefix().FileContent;

        return variables.deJSON( _.responseContent );
    }

    public struct function refreshToken( required string refresh_token, required string client_id, required string client_secret, required string redirect_url ){

        var _ = {};

        _.httpCall = new HTTP();
        _.httpCall.setURL( 'https://api.hubapi.com/oauth/v1/token' );
        _.httpCall.setMethod("POST");
        _.httpCall.addParam( type="header", name="content-Type", value="application/x-www-form-urlencoded");
        _.httpCall.addParam( type="formfield", name="grant_type", value="refresh_token");
        _.httpCall.addParam( type="formfield", name="client_id", value="#arguments.client_id#");
        _.httpCall.addParam( type="formfield", name="client_secret", value="#arguments.client_secret#");
        _.httpCall.addParam( type="formfield", name="redirect_uri", value="#arguments.redirect_url#");
        _.httpCall.addParam( type="formfield", name="refresh_token", value="#arguments.refresh_token#");
        _.httpResponse = _.httpCall.send();

        _.responseContent = _.httpResponse.getPrefix().FileContent;

        return variables.deJSON( _.responseContent );

    }

    public struct function refreshTokenWithFullResponse( required string refresh_token, required string client_id, required string client_secret, required string redirect_url ){

        var _ = {};

        _.httpCall = new HTTP();
        _.httpCall.setURL( 'https://api.hubapi.com/oauth/v1/token' );
        _.httpCall.setMethod("POST");
        _.httpCall.addParam( type="header", name="content-Type", value="application/x-www-form-urlencoded");
        _.httpCall.addParam( type="formfield", name="grant_type", value="refresh_token");
        _.httpCall.addParam( type="formfield", name="client_id", value="#arguments.client_id#");
        _.httpCall.addParam( type="formfield", name="client_secret", value="#arguments.client_secret#");
        _.httpCall.addParam( type="formfield", name="redirect_uri", value="#arguments.redirect_url#");
        _.httpCall.addParam( type="formfield", name="refresh_token", value="#arguments.refresh_token#");
        return _.httpCall.send().getPrefix();
    }    

    private struct function apiCallPost( required string APIURI, required string body){

        var _ = {};

        _.httpCall = new HTTP();
        _.httpCall.setURL( variables.APIURLBase & arguments.APIURI );
        _.httpCall.setMethod("POST");
        _.httpCall.addParam( type="header", name="Content-Type", value="application/json");
        _.httpCall.addParam( type="header", name="Authorization", value="Bearer #variables.token#" );
        _.httpCall.addParam( type="body", value="#arguments.body#" );
        
        _.apiResponse = _.httpCall.send();
        _.httpCode = _.apiResponse.getPrefix().responseheader.status_code;
        _.responseContent = _.apiResponse.getPrefix().FileContent;

        return _.apiResponse.getPrefix();
    }


    private any function apiCallGet( required string APIURI, boolean abortOnError = true ){

        var _ = {};

        _.httpCall = new HTTP();
        _.httpCall.setURL( variables.APIURLBase & arguments.APIURI );
        _.httpCall.addParam( type="header", name="Content-Type", value="application/json" );
        _.httpCall.addParam( type="header", name="Authorization", value="Bearer #variables.token#" );
        _.httpCall.setTimeout(30);
        _.apiResponse = _.httpCall.send();

        _.responseContent = _.apiResponse.getPrefix().FileContent;

        try{
			return variables.deJSON( _.responseContent );
		} catch(Any E){
			if( arguments.abortOnError ){
				writeoutput(_.responseContent);
				abort;
			}
		}
    } 

    private any function deJSON( required string inputData ){

        if( IsJSON( arguments.inputData) ){
            return  deserializeJSON( arguments.inputData );
        } else {
            throw(message="Non-JSON Format Response", detail="#SerializeJSON(arguments.inputData)#");
        }
    }


    public struct function getObjectsToObjectsCRMAssociations( required array arrayOfObjects, required string fromObjectType, required string toObjectType ){


        var _ = {};

        _.APIURL = "#variables.APIURLBase#/crm/v3/associations/#arguments.fromObjectType#/#arguments.toObjectType#/batch/read";

        _.payload = {
            "inputs": arguments.arrayOfObjects
        }

        _.httpCall = new HTTP();        
        _.httpCall.setURL( _.APIURL );
        _.httpCall.setMethod("POST");
        _.httpCall.addParam( type="header", name="Content-Type", value="application/json");
        _.httpCall.addParam( type="header", name="Authorization", value="Bearer #variables.token#" );
        _.httpCall.addParam( type="body", value=serializeJSON(_.payload) );

        return deserializeJSON( _.httpCall.send().getPrefix().FileContent );

    }


    public struct function createBatchAssociations( required string fromObjectType, required string toObjectType, required array arrayOfAssociations ){

        var _ = {};

        _.payLoad = {
            inputs:[]
        }

        for( _.assocData in arguments.arrayOfAssociations){

            _.payLoad.inputs.add(
                {
                    from: {id: _.assocData.from },
                    to: {id: _.assocData.to },
                    type:"#arguments.fromObjectType#_to_#arguments.toObjectType#"
                }
            );
        }

        _.httpCall = new HTTP();
        _.httpCall.setURL( 'https://api.hubapi.com/crm/v3/associations/#arguments.fromObjectType#/#arguments.toObjectType#/batch/create' );
        _.httpCall.setMethod("POST");
        _.httpCall.addParam( type="header", name="Content-Type", value="application/json");
        _.httpCall.addParam( type="header", name="Authorization", value="Bearer #variables.token#" );
        _.httpCall.addParam( type="body", value="#SerializeJSON(_.payLoad)#" );
        
        _.httpResponse = _.httpCall.send();
        
        return deserializeJSON( _.httpResponse.getPrefix().FileContent ); 

    }

    public struct function getCustomObjectTypes(){

        _.httpCall = new HTTP();
        _.httpCall.setURL( 'https://api.hubapi.com/crm/v3/schemas' );
        _.httpCall.setMethod("GET");
        _.httpCall.addParam( type="header", name="Content-Type", value="application/json");
        _.httpCall.addParam( type="header", name="Authorization", value="Bearer #variables.token#" );
        
        _.httpResponse = _.httpCall.send();
        
        return deserializeJSON( _.httpResponse.getPrefix().FileContent );         

    }


    public struct function getCustomObjectType(  required string object_type ){

        _.httpCall = new HTTP();
        _.httpCall.setURL( 'https://api.hubapi.com/crm/v3/schemas/#arguments.object_type#' );
        _.httpCall.setMethod("GET");
        _.httpCall.addParam( type="header", name="Content-Type", value="application/json");
        _.httpCall.addParam( type="header", name="Authorization", value="Bearer #variables.token#" );
        
        _.httpResponse = _.httpCall.send();
        
        return deserializeJSON( _.httpResponse.getPrefix().FileContent );         

    }    

    public struct function getObjectToObjectLabels( required string fromObjectType, required string toObjectType){

        var _ = {};
        _.httpCall = new HTTP();
        _.httpCall.setURL( 'https://api.hubapi.com//crm/v4/associations/#arguments.fromObjectType#/#arguments.toObjectType#/labels' );
        _.httpCall.setMethod("GET");
        _.httpCall.addParam( type="header", name="Content-Type", value="application/json");
        _.httpCall.addParam( type="header", name="Authorization", value="Bearer #variables.token#" );
        
        _.httpResponse = _.httpCall.send();
        
        return deserializeJSON( _.httpResponse.getPrefix().FileContent );  

    }

    
    
    public struct function createBatchProperties( required string groupname, required string object_type, required array arrayOfProperties ){

        var _ = {};

        _.payload = {"inputs": arguments.arrayOfProperties};
    
        _.httpRequest = new HTTP();
        _.httpRequest.setMethod("POST");
        _.httpRequest.setURL("#variables.APIURLBase#/crm/v3/properties/#arguments.object_type#/batch/create");
        _.httpRequest.addParam( type="header", name="Content-Type", value="application/json");
        _.httpRequest.addParam( type="header", name="Authorization", value="Bearer #variables.token#" );   
        _.httpRequest.addParam( type="body", value="#serializeJSON( _.payload )#");

        return _.httpRequest.send();
    }
    


    public struct function createBatchObjects( required string ObjectType,  required array arrayOfobjects ){

        var _ = {};

        _.payLoad = {
            inputs:arguments.arrayOfobjects
        }

       

        _.httpCall = new HTTP();
        _.httpCall.setURL( 'https://api.hubapi.com/crm/v3/associations/#arguments.ObjectType#/batch/create?' );
        _.httpCall.setMethod("POST");
        _.httpCall.addParam( type="header", name="Content-Type", value="application/json");
        _.httpCall.addParam( type="header", name="Authorization", value="Bearer #variables.token#" );
        _.httpCall.addParam( type="body", value="#SerializeJSON(_.payLoad)#" );
        
        _.httpResponse = _.httpCall.send();
        
        return deserializeJSON( _.httpResponse.getPrefix().FileContent ); 

    }
    
    
    public struct function updateBatchObjects( required string object_type,  required array arrayOfobjects ){

        var _ = {};

        _.payLoad = {
            inputs:arguments.arrayOfobjects
        }

       

        _.httpCall = new HTTP();
        _.httpCall.setURL( 'https://api.hubapi.com/crm/v3/objects/#arguments.object_type#s/batch/update' );
        _.httpCall.setMethod("POST");
        _.httpCall.addParam( type="header", name="Content-Type", value="application/json");
        _.httpCall.addParam( type="header", name="Authorization", value="Bearer #variables.token#" );
        _.httpCall.addParam( type="body", value="#SerializeJSON(_.payLoad)#" );
        
        _.httpResponse = _.httpCall.send();
        
        return deserializeJSON( _.httpResponse.getPrefix().FileContent ); 

    }    

    public struct function updateObjectProperty( required string object_type, required string object_property, required struct property_data ){

        var _ = {};
        _.httpCall = new HTTP();
        _.httpCall.setURL( 'https://api.hubapi.com/properties/v2/#LCASE(arguments.object_type)#s/properties/named/#arguments.object_property#' );
        _.httpCall.setMethod("PATCH");
        _.httpCall.addParam( type="header", name="Content-Type", value="application/json");
        _.httpCall.addParam( type="header", name="Authorization", value="Bearer #variables.token#" );
        _.httpCall.addParam( type="header", name="User-Agent", value="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.117 Safari/537.36");
        _.httpCall.addParam( type="body", value="#SerializeJSON(arguments.property_data)#");

        _.httpResponse = _.httpCall.send();
        
        return deserializeJSON( _.httpResponse.getPrefix().FileContent ); 

    }

    public struct function archiveObjectsById( required string object_type, required array arrayOfIds  ){
        
        //return {status_Code:204};

        var _ = {};

        _.payload = {inputs:[]}

        for( _.id in arguments.arrayOfIds) _.payload.inputs.add( {id:_.id} );

        _.httpCall = new HTTP();
        _.httpCall.setURL( 'https://api.hubapi.com/crm/v3/objects/#arguments.object_type#s/batch/archive' );
        _.httpCall.setMethod("POST");
        _.httpCall.addParam( type="header", name="Content-Type", value="application/json");
        _.httpCall.addParam( type="header", name="Authorization", value="Bearer #variables.token#" );
        _.httpCall.addParam( type="header", name="User-Agent", value="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.117 Safari/537.36");
        _.httpCall.addParam( type="body", value="#SerializeJSON(_.payload)#");

        return _.httpCall.send().getPrefix();
        
    }

    public boolean function validateCRMCardRequest( required string client_secret ){

        var _ = {};

        //Can only run under the app.appchemist.io domain
        if( structKeyExists(getHttpRequestData().headers, 'X-HubSpot-Signature')){
            _.hbsig = getHttpRequestData().headers['X-HubSpot-Signature'];
        } else {
            return true;
        }

        _.URIRequested = 'https://' & CGI.HTTP_HOST &  getHttpRequestData().headers['X-Original-URL'];

        _.hashThis = arguments.client_secret & getHttpRequestData().method & _.URIRequested & getHttpRequestData().content;

        _.mySig = LCASE(Hash(_.hashThis, "SHA-256"));

        return(_.hbsig == _.mySig)

    }
}