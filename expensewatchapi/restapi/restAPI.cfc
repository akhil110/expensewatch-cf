<cfcomponent rest="true" restpath="expenseAPI">
    
    <cfobject name="objUser" component="cfc.user">
    <cfobject name="objExp" component="cfc.expense">

    <!--- Function to validate token--->
    <cffunction name="authenticate" returntype="any">
        <cfset var response = {}>
        <cfset requestData = GetHttpRequestData()>
        <cfif StructKeyExists( requestData.Headers, "authorization" )>
            <cfset token = GetHttpRequestData().Headers.authorization>
            <cftry>
                <cfset jwt = new cfc.jwt(Application.jwtkey)>
                <cfset result = jwt.decode(token)>
                <cfset response["success"] = true>
                <cfcatch type="Any">
                    <cfset response["success"] = false>
                    <cfset response["message"] = cfcatch.message>
                    <cfreturn response>
                </cfcatch>
            </cftry>
        <cfelse>
            <cfset response["success"] = false>
            <cfset response["message"] = "Authorization token invalid or not present.">
        </cfif>
        <cfreturn response>
    </cffunction>
    
    <!--- User Registration--->
    <cffunction name="signup" restpath="signup" access="remote" returntype="struct" httpmethod="POST" produces="application/json">
        
        <cfargument name="structform" type="any" required="yes">
        
        <cfset var response = {}>

        <cfset blnsignup = objUser.registerUser(structform)>
        <cfif blnsignup>
            <cfset response["success"]=true>
            <cfset response["message"]="User created successfully, please login to access your account.">
        <cfelse>
            <cfset response["success"]=false>
            <cfset response["message"]="Username already exists.">
        </cfif>

        <cfreturn response>
        
    </cffunction>

    <!--- User Login--->
    <cffunction name="login" restpath="login" access="remote" returntype="struct" httpmethod="POST" produces="application/json">

        <cfargument name="structform" type="any" required="yes">
        
        <cfset var response = {}>
        <cfset response = objUser.loginUser(structform)>
        <cfreturn response>

    </cffunction>

    <!--- User specific functions --->
    <cffunction name="getuser" restpath="user/{id}" access="remote" returntype="struct" httpmethod="GET" produces="application/json">
        <cfargument name="id" type="any" required="yes" restargsource="path"/>
        <cfset var response = {}>

        <cfset verify = authenticate()>
        <cfif not verify.success>
            <cfset response["success"] = false>
            <cfset response["message"] = verify.message>
			      <cfset response["errcode"] = 'no-token'>
        <cfelse>
            <cfset response = objUser.userDetails(arguments.id)>
        </cfif>

        <cfreturn response>

    </cffunction>

    <cffunction name="putuser" restpath="user/{id}" access="remote" returntype="struct" httpmethod="PUT" produces="application/json">
        <cfargument name="id" type="any" required="yes" restargsource="path"/>
        <cfargument name="structform" type="any" required="yes">
        
        <cfset var response = {}>

        <cfset verify = authenticate()>
        <cfif not verify.success>
            <cfset response["success"] = false>
            <cfset response["message"] = verify.message>
			      <cfset response["errcode"] = 'no-token'>
        <cfelse>
            <cfset response = objUser.updateUser(arguments.id, arguments.structform)>
        </cfif>

        <cfreturn response>

    </cffunction>

    <cffunction name="password" restpath="password/{id}" access="remote" returntype="struct" httpmethod="PUT" produces="application/json">
        <cfargument name="id" type="numeric" required="yes" restargsource="path"/>
        <cfargument name="structform" type="any" required="yes">
        
        <cfset var response = {}>

        <cfset verify = authenticate()>
        <cfif not verify.success>
            <cfset response["success"] = false>
            <cfset response["message"] = verify.message>
			      <cfset response["errcode"] = 'no-token'>
        <cfelse>
            <cfset response = objUser.updatePassword(arguments.id, arguments.structform)>
        </cfif>

        <cfreturn response>

    </cffunction>

    <!--- Expense specific functions --->
    <cffunction name="saveexpense" restpath="expense/{id}" access="remote" returntype="struct" httpmethod="POST" produces="application/json">
        <cfargument name="id" type="numeric" required="yes" restargsource="path"/>
        <cfargument name="structform" type="any" required="yes">
        
        <cfset var response = {}>

        <cfset verify = authenticate()>
        <cfif not verify.success>
            <cfset response["success"] = false>
            <cfset response["message"] = verify.message>
			      <cfset response["errcode"] = 'no-token'>
        <cfelse>
            <cfset response = objExp.saveExpense(arguments.id, arguments.structform)>
        </cfif>

        <cfreturn response>

    </cffunction>

    <cffunction name="delexpense" restpath="expense/{id}" access="remote" returntype="struct" httpmethod="DELETE" produces="application/json">
        <cfargument name="id" type="numeric" required="yes" restargsource="path"/>
        
        <cfset var response = {}>

        <cfset verify = authenticate()>
        <cfif not verify.success>
            <cfset response["success"] = false>
            <cfset response["message"] = verify.message>
			      <cfset response["errcode"] = 'no-token'>
        <cfelse>
            <cfset response = objExp.delExpense(arguments.id)>
        </cfif>

        <cfreturn response>

    </cffunction>

    <cffunction name="getexpense" restpath="expense/{id}" access="remote" returntype="struct" httpmethod="GET" produces="application/json">
        <cfargument name="id" type="numeric" required="yes" restargsource="path"/>
        
        <cfset var response = {}>

        <cfset verify = authenticate()>
        <cfif not verify.success>
            <cfset response["success"] = false>
            <cfset response["message"] = verify.message>
			      <cfset response["errcode"] = 'no-token'>
        <cfelse>
            <cfset response = objExp.getExpense(arguments.id)>
        </cfif>

        <cfreturn response>

    </cffunction>

    <cffunction name="expreport" restpath="expense/report/{id}" access="remote" returntype="struct" httpmethod="POST" produces="application/json">
        <cfargument name="id" type="numeric" required="no" restargsource="path"/>
        <cfargument name="structform" type="any" required="no">
        <cfargument name="uname" type="any" required="no" restargsource="query"/>
        <cfargument name="report" type="any" required="no" restargsource="query"/>
        <cfargument name="startdt" type="any" required="no" restargsource="query"/>
        <cfargument name="enddt" type="any" required="no" restargsource="query"/>
        <cfargument name="limit" type="any" required="no" restargsource="query" default="10"/>
        <cfargument name="page" type="any" required="no" restargsource="query" default="1"/>
        <cfargument name="sortby" type="any" required="no" restargsource="query" default="expensedate"/>
       
        <cfset var response = {}>

        <cfset structval = {}>
        <cfset structval.uid = ( IsDefined("arguments.id") ? #arguments.id# : #arguments.uname# ) />
        <cfset structval.rptype = ( IsDefined("arguments.structform.report") ? #arguments.structform.report# : #arguments.report# ) />
        <cfif structval.rptype eq 'opt2'>
            <cfset structval.from_dt = ( IsDefined("arguments.structform.startdt") ? #arguments.structform.startdt# : #arguments.startdt# ) />
            <cfset structval.to_dt = ( IsDefined("arguments.structform.enddt") ? #arguments.structform.enddt#  : #arguments.enddt#  ) />
        </cfif>
        <cfset structval.limit = ( IsDefined("arguments.structform.limit") ? #arguments.structform.limit# : #arguments.limit# ) />
        <cfset structval.page = ( IsDefined("arguments.structform.page") ? #arguments.structform.page# : #arguments.page# ) />
        <cfset structval.sortby = ( IsDefined("arguments.structform.sortby") ? #arguments.structform.sortby# : #arguments.sortby# ) />
        
        <cfset verify = authenticate()>
        <cfif not verify.success>
            <cfset response["success"] = false>
            <cfset response["message"] = verify.message>
			      <cfset response["errcode"] = 'no-token'>
        <cfelse>
            <cfset response = objExp.expReport(structval)>
        </cfif>

        <cfreturn response>

    </cffunction>

</cfcomponent>
