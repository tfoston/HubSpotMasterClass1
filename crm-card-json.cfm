<!--- This script will get requested from Hubspot. Lets validate that it came from HuBspot --->
<cfset hubspotAPI = new HubSpotAPI('')>

<!--- 
<cfif hubspotAPI.validateCRMCardRequest( Request.app.client_secret ) EQ FALSE >
  Request Not Authenticated
  <cfabort>
</cfif>
--->

<cfparam  name="URL.hs_object_id" default="0">

<cfquery name="loginHistoryRS">
    SELECT 
        count(*) as total_logins, 
        (SUM( success ) / count(*) ) as success_percentage,
        count( DISTINCT ip) as total_ips 
    FROM 
        `login_history`
    WHERE 
        contact_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.hs_object_id#" />
    group by 
        contact_id
    ;
</cfquery>

<cfset response =     {
        "results": [
          {
            "objectId": #URL.hs_object_id#,
            "title": "MasterClass - Contact Login Summary",                
            "created": "#DATEFORMAT(now(), "YYYY-MM-DD")#" ,                
            "description": "Login Success",
            "properties": [
              {
                "label": "Successful Login Percentage",
                "dataType": "STRING",
                "value": "#(loginHistoryRS.success_percentage * 100)#%" , 
              },
              {
                "label": "Total IPs",
                "dataType": "STRING",
                "value":  "#loginHistoryRS.total_ips#", 
              }
            ],
            "actions": [
                {
                    "type": "IFRAME",
                    "width": 890,
                    "height": 748,
                    "uri": "https://#CGI.HTTP_HOST#/crm-card.cfm?contact_id=#URL.hs_object_id#",
                    "label": "Login History"
                }
            ]        
          }		   
      ]
    }
>

<cfoutput>#SerializeJSON(response)#</cfoutput>