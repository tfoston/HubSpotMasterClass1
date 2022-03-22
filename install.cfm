<cfparam  name="URL.code" default="">

<!--- Create an instance of the API wrapper --->
<cfset hubspotAPI = new HubSpotAPI('')>


<!--- <cfdump var="#Request.app#" abort="true"> --->


<!--- Get the auth token based on the code that was given --->
<cfset tokenResponse = hubspotAPI.requestTokenUsingCode(
    URL.code, 
    Request.app.client_id,
    Request.app.client_secret, 
    Request.app.redirect_url
)>

<cfdump var="#tokenResponse#" label="HubSpot Token Response">


<!--- If we've get an access token, lets save it to the db --->
<cfif structKeyExists(tokenResponse, 'access_token')>

    <!--- Save this to the database --->
    <cfquery>

        UPDATE config 
        SET config_value = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tokenResponse.access_token#" />
        WHERE config_key = 'access_token' 
        LIMIT 1
        ;
        
        UPDATE config 
        SET config_value = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tokenResponse.refresh_token#" /> 
        WHERE config_key = 'refresh_token' 
        LIMIT 1
        ;

    </cfquery>
	
	Install Complete!!!!
<cfelse>

    <!--- Show the results since we didn't get an access token --->
    <cfdump var="#tokenResponse#">

</cfif>