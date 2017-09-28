<cfcomponent hint="Expense specific functions" displayname="expense">

    <!--- Update User Details --->
	  <cffunction name="saveExpense" access="public" output="false" hint="Save expense record" returntype="struct">
        
        <cfargument name="userid" required="true" type="numeric" />
        <cfargument name="structform" required="true" type="any" />

        <cfset var resObj = {}>

        <cfif isdefined('structform.expid')>
            <!--- Update expense --->
            <cftry>
                <cfquery name="updexp" datasource="expense">
                    update expense
                    set expensedate  = <cfqueryparam cfsqltype="cf_sql_date" value="#structform.expdate#">,
                    expensetype = <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="50" value="#structform.expaccount#">,
                    expenseamt = <cfqueryparam cfsqltype="cf_sql_money" value="#structform.expamt#">,
                    expensedesc = <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="255" value="#structform.expdesc#">
                    where expenseid = <cfqueryparam cfsqltype="cf_sql_integer" value="#structform.expid#">
                </cfquery>

                <cfset resObj["success"] = true>
                <cfset resObj["message"] = "Expense updated successfully.">

                <cfcatch type="any">
                    <cfset resObj["success"] = false>
                    <cfset resObj["message"] = #cfcatch["message"]# & " " & #cfcatch["detail"]#>
                </cfcatch>
            </cftry>
        <cfelse>
            <!--- Add expense --->
            <cftry>
                <cfquery name="addexp" datasource="expense">
                    insert into expense(
                        userid,
                        expensedate,
                        expensetype,
                        expenseamt,
                        expensedesc
                    ) values (
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">,
                        <cfqueryparam cfsqltype="cf_sql_date" value="#structform.expdate#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="50" value="#structform.expaccount#">,
                        <cfqueryparam cfsqltype="cf_sql_money" value="#structform.expamt#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" maxlength="255" value="#structform.expdesc#">
                    )
                </cfquery>

                <cfset resObj["success"] = true>
                <cfset resObj["message"] = "Expense saved successfully.">

                <cfcatch type="any">
                    <cfset resObj["success"] = false>
                    <cfset resObj["message"] = #cfcatch["message"]# & " " & #cfcatch["detail"]#>
                </cfcatch>
            </cftry>

        </cfif> 

        <cfreturn resObj>

    </cffunction>

    <!--- Delete User Details --->
	  <cffunction name="delExpense" access="public" output="false" hint="Delete expense record" returntype="struct">
        
        <cfargument name="expid" required="true" type="numeric" />

        <cfset var resObj = {}>

        <cftry>
            <cfquery name="delexp" datasource="expense">
                delete from expense
                where expenseid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.expid#">
            </cfquery>

            <cfset resObj["success"] = true>
            <cfset resObj["message"] = "Expense record removed successfully.">

            <cfcatch type="any">
                <cfset resObj["success"] = false>
                <cfset resObj["message"] = "Problem executing database query " & #cfcatch["message"]#>
            </cfcatch>
        </cftry>

        <cfreturn resObj>

    </cffunction>

    <!--- "Get expense details --->
    <cffunction name="getExpense" access="public" output="false" hint="Get expense record" returntype="struct">
	
        <cfargument name="expid" required="true" type="numeric" />
        <cfset var resObj = {}>
        <cfset returnArray = ArrayNew(1) />

        <cftry>
            <cfquery name="getexp" datasource="expense">
                select * from 
                expense
                where expenseid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.expid#">
            </cfquery>

            <cfif getexp.recordcount eq 0>
                <cfset resObj["success"] = false>
                <cfset resObj["message"] = "Incorrect expense id provided.">
            <cfelse>
                <cfloop query="getexp">
                    <cfset expStruct = StructNew() />
                    <cfset expStruct["expenseid"] = expenseid />
                    <cfset expStruct["userid"] = userid />
                    <cfset expStruct["expensedate"] = expensedate />
                    <cfset expStruct["expensetype"] = expensetype />
                    <cfset expStruct["expenseamt"] = expenseamt />
                    <cfset expStruct["expensedesc"] = expensedesc />
                    
                    <cfset ArrayAppend(returnArray,expStruct) />
                </cfloop>

                <cfset resObj["success"] = true>
                <cfset resObj["data"] = SerializeJSON(returnArray)>
            </cfif>
            <cfcatch type="any">
                <cfset resObj["success"] = false>
                <cfset resObj["message"] = "Problem executing database query " & #cfcatch["message"]#>
            </cfcatch>
        </cftry>

		  <cfreturn resObj>
    </cffunction>

    <!--- "Get expense report --->
    <cffunction name="expReport" access="public" output="false" hint="Returns expense report" returntype="struct">
    
        <cfargument name="structform" required="yes" type="any" />

        <cfset var resObj = {}>
        <cfset var offset = (arguments.structform.page-1) * arguments.structform.limit>

        <cfset returnArray = ArrayNew(1) />
        
        <cftry>
            <cfif structform.rptype eq "opt1">
                <cfquery name="qReport" datasource="expense">
                    select *,
                    (select count(*) from expense where YEAR(expensedate) = YEAR(CURRENT_DATE()) and MONTH(expensedate) = MONTH(CURRENT_DATE()) and userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.structform.uid#">) as totalCount,
					          (select sum(expenseamt) from expense where YEAR(expensedate) = YEAR(CURRENT_DATE()) and MONTH(expensedate) = MONTH(CURRENT_DATE()) and userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.structform.uid#">) as exptotal
                    from expense 
                    where YEAR(expensedate) = YEAR(CURRENT_DATE()) and 
                    MONTH(expensedate) = MONTH(CURRENT_DATE())
                    and userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.structform.uid#">
                    order by #arguments.structform.sortby#
                    LIMIT #offset#, #arguments.structform.limit#
                </cfquery>
            <cfelseif structform.rptype eq "opt2">
                <cfquery name="qReport" datasource="expense">
                    select *,
                    (select count(*) from expense where expensedate between <cfqueryparam cfsqltype="cf_sql_date" value="#structform.from_dt#"> and <cfqueryparam cfsqltype="cf_sql_date" value="#structform.to_dt#"> and userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#structform.uid#">) as totalCount,
					          (select sum(expenseamt) from expense where expensedate between <cfqueryparam cfsqltype="cf_sql_date" value="#structform.from_dt#"> and <cfqueryparam cfsqltype="cf_sql_date" value="#structform.to_dt#"> and userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.structform.uid#">) as exptotal
                    from expense
                    where expensedate between <cfqueryparam cfsqltype="cf_sql_date" value="#structform.from_dt#"> and <cfqueryparam cfsqltype="cf_sql_date" value="#structform.to_dt#">
                    and userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#structform.uid#">
                    order by #arguments.structform.sortby#
                    LIMIT #offset#, #arguments.structform.limit#
                </cfquery>
            <cfelse>
                <cfquery name="qReport" datasource="expense">
                    select *,
                    (select count(*) from expense where userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.structform.uid#">) as totalCount,
					          (select sum(expenseamt) from expense where userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.structform.uid#">) as exptotal
                    from expense
                    where userid = <cfqueryparam cfsqltype="cf_sql_integer" value="#structform.uid#">
                    order by #arguments.structform.sortby#
                   LIMIT #offset#, #arguments.structform.limit#
                </cfquery>
            </cfif>

            <cfloop query="qReport">
                <cfset expStruct = StructNew() />
                <cfset expStruct["expenseid"] = expenseid />
                <cfset expStruct["expensedate"] = expensedate />
                <cfset expStruct["expensetype"] = expensetype />
                <cfset expStruct["expenseamt"] = expenseamt />
                <cfset expStruct["expensedesc"] = expensedesc />
               
                <cfset ArrayAppend(returnArray,expStruct) />
            </cfloop>

            <cfset resObj["success"] = true>
            <cfset resObj["data"] = SerializeJSON(returnArray)>
            <cfset resObj["totalrows"] = qReport.totalCount>
			<cfset resObj["exptotal"] = qReport.exptotal>

            <cfcatch type="any">
                <cfset resObj["success"] = false>
                <cfset resObj["message"] = #cfcatch["message"]# & " " & #cfcatch["detail"]#>
            </cfcatch>

        </cftry>

        <cfreturn resObj>
    </cffunction>

</cfcomponent>
