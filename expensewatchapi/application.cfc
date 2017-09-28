
<cfcomponent output="false">
	<!--- Application name, unique to production and development environments --->
	<cfset this.name = "expensewatch">
	<cfset this.restsettings.cfclocation = "./">
        <cfset this.restsettings.skipcfcwitherror = true>
    

	<!--- Run when application starts up --->
	<cffunction name="onApplicationStart" returnType="boolean">
		<cfset Application.jwtkey = "$3cR3!k@GH34">
		<cfset restInitApplication(getDirectoryFromPath(getCurrentTemplatePath()) & 'restapi', 'api')>
		<cfreturn true>
	</cffunction>

	<!--- Run when application stops --->
	<cffunction name="onApplicationEnd" returnType="void" output="false">
	</cffunction>

	<!--- Fired when user requests a CFM that doesn't exist. --->
	<cffunction name="onMissingTemplate">
	</cffunction>

	<!--- Run before the request is processed --->
	<cffunction name="onRequestStart" returnType="void" output="true">
		
		<cfif IsDefined("URL.reload") AND URL.reload EQ "zx54ex">
			<cflock timeout="10" throwontimeout="No" type="Exclusive" scope="Application">
				<cfset OnApplicationStart()>
			</cflock>
			<cfhtmlhead text="<script language=""JavaScript"">alert('Application was refreshed.');</script>">
		</cfif>
	
	</cffunction>

	
	<!--- Runs at end of request, processes footer --->
	<cffunction name="onRequestEnd">
	</cffunction>

	
	<!--- Runs when your session starts --->
	<cffunction name="onSessionStart" returnType="void" output="false">
	</cffunction>

	<!--- Runs when session ends --->
	<cffunction name="onSessionEnd" returnType="void" output="false">
	</cffunction>
	
</cfcomponent>
