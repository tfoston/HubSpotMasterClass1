<cfquery name="configRS">

    SELECT *
    FROM `config`
    WHERE config_key IN ('access_token', 'refresh_token')

</cfquery>

<cfdump var="#configRS#" label="configRS">

<cfset hubspotAPI = new HubSpotAPI('')>
<cfset configMap = {}>

<!--- Place the data into a struct --->
<cfloop query="configRS">
    <cfset configMap[  configRS.config_key ] = configRS.config_value >
</cfloop>


<cfset tokenResponse =  hubspotAPI.refreshToken( configMap['refresh_token'], Request.app.client_id, Request.app.client_secret, Request.app.redirect_url )>
<cfdump var="#tokenResponse#" label="tokenResponse">


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
	
	The OAuth token has been refreshed!!!

<cfelse>

    <!--- Show the results since we didn't get an access token --->
    <cfdump var="#tokenResponse#">

</cfif>