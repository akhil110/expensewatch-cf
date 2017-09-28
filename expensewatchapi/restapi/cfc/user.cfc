<cfcomponent hint="User specific functions" displayname="user">
    
    <!--- User Registration --->
    <cffunction name="registerUser" access="public" output="false" hint="Register User" returntype="boolean">
	
        <cfargument name="structform" required="true" type="any"  />

        <cfquery name="validuser" datasource="expense">
          select * from 
          users
          where username = <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="20" value="#structform.username#">
        </cfquery>

        <cfif validuser.recordcount eq 1>
            <cfreturn false>
        <cfelse>
            <!--- Create Salt for the password hash --->
            <cfset Salt="">
            <cfloop index="i" from="1" to="12">
                <cfset Salt = Salt & chr(RandRange(65,90))>
            </cfloop>

            <cfset hashpwd = Hash(Salt & structform.password)>
            
            <cfquery name="saveuser" datasource="expense">
                insert into users (
                    firstname,
                    lastname,
                    email,
                    username,
                    password,
                    salt
                ) values (
                    <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="100" value="#structform.firstname#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="100" value="#structform.lastname#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="255" value="#structform.email#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="20" value="#structform.username#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="255" value="#hashpwd#">,
                    <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="15" value="#Salt#">
                )
            </cfquery>
            
            <cfreturn true>
        </cfif>

    </cffunction>


    <!--- User Login --->
    <cffunction name="loginUser" access="public" output="false" hint="Login User" returntype="struct">
	
        <cfargument name="structform" required="true" type="any" />
        
        <cfset var resObj = {}>

        <cfquery name="loginuser" datasource="expense">
          select * from 
          users
          where username = <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="20" value="#structform.username#">
        </cfquery>

        <cfif loginuser.recordcount eq 1 and (Hash(loginuser.salt & structform.password) eq loginuser.password)>
            <!--- Update last login date with current date --->
            <cfquery name="logindt" datasource="expense">
                update users
                set lastlogin = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#now()#">
                where username = <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="20" value="#structform.username#">
            </cfquery>
            
            <cfset expdt =  dateAdd("n",30,now())>
            <cfset utcDate = dateDiff('s', dateConvert('utc2Local', createDateTime(1970, 1, 1, 0, 0, 0)), expdt) />

            <cfset jwt = new jwt(Application.jwtkey)>
            <cfset payload = {"ts" = now(), "userid" = loginuser.userid, "exp" = utcDate}>
            <cfset token = jwt.encode(payload)>
            
            <cfset resObj["success"] = true>
            <cfset resObj["message"] = {'userid': loginuser.userid, 'username': loginuser.username, 'firstname': loginuser.firstname, 'lastlogin': dateTimeFormat(loginuser.lastlogin, "dd-MMM-yyyy hh:nn:ss tt")}>
            <cfset resObj["token"] = token>
        <cfelse>
            <cfset resObj["success"] = false>
            <cfset resObj["message"] = "Incorrect login credentials.">
        </cfif>
        
        <cfreturn resObj>

    </cffunction>


    <!--- User Details --->
    <cffunction name="userDetails" access="public" output="false" hint="Get user details" returntype="struct">
	
        <cfargument name="userid" required="true" type="numeric" />
        <cfset var resObj = {}>
        <cfset returnArray = ArrayNew(1) />
    
        <cfquery name="getuser" datasource="expense">
          select * from 
          users
          where userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
        </cfquery>

        <cfif getuser.recordcount eq 0>
            <cfset resObj["success"] = false>
            <cfset resObj["message"] = "Incorrect user id provided.">
        <cfelse>
            <cfloop query="getuser">
                <cfset userStruct = StructNew() />
                <cfset userStruct["id"] = userid />
                <cfset userStruct["firstname"] = firstname />
                <cfset userStruct["lastname"] = lastname />
                <cfset userStruct["email"] = email />
                <cfset userStruct["lastlogin"] = lastlogin />
                
                <cfset ArrayAppend(returnArray,userStruct) />
            </cfloop>

            <cfset resObj["success"] = true>
            <cfset resObj["data"] = SerializeJSON(returnArray)>

        </cfif>

		<cfreturn resObj>
    </cffunction>

    <!--- Update User Details --->
    <cffunction name="updateUser" access="public" output="false" hint="Update user details" returntype="struct">
        
        <cfargument name="userid" required="true" type="numeric" />
        <cfargument name="structform" required="true" type="any" />

        <cfset var resObj = {}>

        <cfquery name="validuser" datasource="expense">
          select * from 
          users
          where userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
        </cfquery>

        <cfif validuser.recordcount eq 1>
            <cftry>
                <cfquery name="updateuser" datasource="expense">
                    update users
                    set firstname = <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="100" value="#structform.firstname#">,
                        lastname = <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="100" value="#structform.lastname#">,
                        email = <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="255" value="#structform.email#">
                    where userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
                </cfquery>

                <cfset resObj["success"] = true>
                <cfset resObj["message"] = "User details updated successfully.">

                <cfcatch type="any">
                    <cfset resObj["success"] = false>
                    <cfset resObj["message"] = "Problem executing database query " & #cfcatch["message"]#>
                </cfcatch>
            </cftry>
        <cfelse>
            <cfset resObj["success"] = false>
            <cfset resObj["message"] = "Incorrect user id provided.">
        </cfif>

        <cfreturn resObj>

    </cffunction>

    <!--- Update User Password --->
    <cffunction name="updatePassword" access="public" output="false" hint="Update user password" returntype="struct">
        
        <cfargument name="userid" required="true" type="numeric" />
        <cfargument name="structform" required="true" type="any" />

        <cfset var resObj = {}>

        <cfquery name="pwduser" datasource="expense">
          select * from 
          users
          where userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
        </cfquery>

        <cfif pwduser.recordcount eq 1>
            <cfif Hash(pwduser.salt & structform.oldpassword) eq pwduser.password>
                <cftry>
                    
                    <cfset hashpwd = Hash(pwduser.salt & structform.password)>
                    
                    <cfquery name="updatepwd" datasource="expense">
                        update users
                        set password = <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="255" value="#hashpwd#">
                        where userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
                    </cfquery>

                    <cfset resObj["success"] = true>
                    <cfset resObj["message"] = "Password updated successfully.">

                    <cfcatch type="any">
                        <cfset resObj["success"] = false>
                        <cfset resObj["message"] = "Problem executing database query " & #cfcatch["message"]#>
                    </cfcatch>
                </cftry>
            <cfelse>
                <cfset resObj["success"] = false>
                <cfset resObj["message"] = "Incorrect old password.">
            </cfif>
        <cfelse>
            <cfset resObj["success"] = false>
            <cfset resObj["message"] = "Incorrect user id provided.">
        </cfif>

        <cfreturn resObj>

    </cffunction>

</cfcomponent>
