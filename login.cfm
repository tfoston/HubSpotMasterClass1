<!--- Demo login page to test the search for contacts --->

<cfparam name="Form.email" default="">
<cfparam name="Form.password" default="">
<cfparam name="Form.message" default="">

<cfif Form.email NEQ "">

    <!--- Get the API key from the database --->
    <cfquery name="configRS">
        SELECT config_value as access_token
        FROM config
        WHERE config_key = 'access_token'
        LIMIT 1
    </cfquery>
	<!---  <cfdump var="#configRS#"> --->
	

    <!--- Check to see if this user exists within hubspot --->
    <cfset hubspotAPI = new HubSpotAPI( configRS.access_token )>

    <!--- Look for the user based on the email address --->
    <cfset contactResults = hubspotAPI.getcontactByEmail( Form.email )>
    <cfdump var="#contactResults#" label="contactResults">


    <cfif structKeyExists(contactResults, 'status')>
        
        <!--- something has gone wrong --->
        <cfset Form.message = contactResults.errors[1].message >

    <cfelse>

        <!--- Add to the database --->
        <cfquery name="credsRS">

            SET @foundUsers = 0;

            <!--- Find the user based on the email address --->
            SELECT count(*) INTO @foundUsers
            FROM `login_credential`
            WHERE email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Form.email#">
            AND password = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Form.password#">
            LIMIT 1
            ;

            <!--- Lets add this attempt to this history table --->
            INSERT INTO `login_history`
            (
                contact_id,
                ip,
                insert_date,
                success
            )
            VALUES 
            (
                <cfqueryparam cfsqltype="cf_sql_integer" value="#contactResults.vid#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#CGI.REMOTE_ADDR#">,
                now(),
                @foundUsers
            )
            ;

            SELECT @foundUsers as foundUsers;

        </cfquery>

        <cfif credsRS.foundUsers NEQ 1 >

            <cfset Form.message = 'No user could be found with those credentials'>

        <cfelse>

            <cfset Form.message = 'Congrats, your credentials where found successfully!!!!! <Br> Check the log for details'>

        </cfif>


    </cfif>


</cfif>

<form method="POST">

    <cfoutput>

        <table style=" margin-top:10%; position:relative; margin-left:40%">

            <cfif Len(Form.message) GT 0 >
                <tr>
                    <td>#Form.message#</td>
                </tr>                
            </cfif>

            <tr>
                <td>MasterClass Demo: Login Form</td>
            </tr>
            <tr>
                <td>

                    <input style="width:100%" name="email" type="email" placeholder="john.smith@domain.com" value="#Form.email#"/>


                </td>
            </tr>

            <tr>
                <td>

                    <input style="width:100%" name="password" type="password" placeholder="Password" value="#Form.password#"/>

                </td>
            </tr>    
            
            <tr>
                <td>

                    <button style="width:100%" type="submit">Login</button>

                </td>
            </tr>            


        </table>

    </cfoutput>

</form>