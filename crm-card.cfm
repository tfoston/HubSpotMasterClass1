<!--- This script will get requested from Hubspot. Lets validate that it came from HuBspot --->
<cfset hubspotAPI = new HubSpotAPI('')>

<!--- 
<cfif hubspotAPI.validateCRMCardRequest( Request.app.client_secret ) EQ FALSE >
  Request Not Authenticated
  <cfabort>
</cfif>
--->

<cfparam  name="URL.contact_id" default="0">

<!--- Get the login info based on the contact ID passed in --->
<cfquery name="loginHistoryRS">
    SELECT lh.*  
    FROM `login_history` lh
    WHERE contact_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.contact_id#" />
    ORDER BY insert_date DESC
    ;
</cfquery>

<table style="width:100%">
    
    <thead style="text-align:left">
        <th>IP</th>
        <th>Date</th>
        <th>Success</th>
    </thead>

    <tbody>
        <cfoutput query="loginHistoryRS">
            <tr style="text-align:left">
                <td>#loginHistoryRS.ip#</td>
                <td>#DATEFORMAT(loginHistoryRS.insert_date, 'long') #</td>
                <td>#loginHistoryRS.success#</td>
            </tr>
        </cfoutput>
    </tbody>

</table>