<cfcomponent extends="MustacheFormatter" output="false">

	<cffunction name="__dollarFormat" access="private" output="false">
		<cfargument name="value" type="string" />

		<cfreturn dollarFormat(arguments.value) />
	</cffunction>
	
	<cffunction name="__decimalFormat" access="private" output="false">
		<cfargument name="value" type="string" />

		<cfreturn numberFormat(arguments.value, '0.00') />
	</cffunction>
	
	<cffunction name="__percentFormat" access="private" output="false">
		<cfargument name="value" type="string" />

		<cfreturn numberFormat(arguments.value, '0.00') & '%' />
	</cffunction>
	
	<cffunction name="__dateFormat" access="private" output="false">
		<cfargument name="value" type="string" />
		<cfargument name="format" type="string" default="mm/dd/yyyy" />

		<cfreturn dateFormat(arguments.value, arguments.format) />
	</cffunction>
	
	<cffunction name="__dateTimeFormat" access="private" output="false">
		<cfargument name="value" type="string" />
		<cfargument name="dateFormat" type="string" default="mm/dd/yyyy " />
		<cfargument name="timeFormat" type="string" default="hh:mm tt" />

		<cfreturn dateFormat(arguments.value, arguments.dateFormat) & timeFormat(arguments.value, arguments.timeFormat) />
	</cffunction>

	<cffunction name="__properCase" access="private" output="false">
		<cfargument name="value" type="string" />
		<cfset var local = {}>
		<cfset local.exceptions = "diMartini,ColdFusion">	
		<cfset local.exceptions = reReplace(local.exceptions,',\s+', ',', 'all')>
		
		<cfset arguments.value = reReplace(lCase(arguments.value), "([a-z])\1{2}\s", "\u\0", 'all')>	
		<cfset arguments.value = reReplace(arguments.value, '[\w]+', '\u\0', 'all')>
		<cfset arguments.value = reReplace(arguments.value, "'([A-Z]\s)", "'\l\1", 'all')>
		
		<cfset arguments.value = reReplace(arguments.value, '(Ma?c)([a-z])', '\1\u\2', 'all')>	
		
		<cfset arguments.value = reReplace(arguments.value, "(D[eia]?')([a-zA-Z])", '\l\1\u\2', 'all')>
		<cfset arguments.value = reReplace(arguments.value, "((D[eia]|L[ea]|V[ao]n)\s)", '\l\1', 'all')>
		
		<cfset arguments.value = reReplace(arguments.value, "([FMS]t)(\s)", '\1.\2', 'all')>
		<cfset arguments.value = reReplaceNoCase(arguments.value, "(\s?)(an|the|at|by|for|of|in|up|on|to|and|as|but|or|nor|a)(\s)", '\1\l\2\3', 'all')>
	
		<cfloop array="#reMatchNoCase("([a-z])\1{2}\s", arguments.value)#" index="local.word">
			<cfset arguments.value = replace(arguments.value, local.word, uCase(local.word))>
		</cfloop>
	
		<cfloop list="#arguments.value#" index="local.word" delimiters=" ">
			<cfset local.index = listFindNoCase(local.exceptions, local.word)>
			<cfif local.index GT 0>
				<cfset arguments.value = replace(arguments.value, local.word, listGetAt(local.exceptions, local.index))>
			</cfif>
		</cfloop>
		
		<cfreturn arguments.value>
	</cffunction>
	
	<cffunction name="__antiSpam" access="private" output="false">
		<cfargument name="value" type="string" required="true" hint="Email address you want to make safe.">
		<cfargument name="mailTo" type="boolean" required="false" default="false" hint="Boolean (Yes/No). Indicates whether to return formatted email address as a mailto link.">
	    <cfset var local = {}>
	    <cfset var local.rtnString  = "">
	    
		<cfloop from="1" to="#len(arguments.value)#" index="local.i">
	        <cfset local.rtnString = local.rtnString  & "&##" & asc(mid(arguments.value, local.i, 1)) & ";">
	    </cfloop>
	    <cfif arguments.mailTo><cfreturn "<a href=" & "mailto:" & local.rtnString & ">" & local.rtnString & "</a>"></cfif>
	    
		<cfreturn local.rtnString>
	</cffunction>
	
	<cffunction name="__ordinal" access="public" returntype="string" output="false" hint="Takes a number as an argument, and returns the 2 letter english text ordinal appropriate for the number">
		<cfargument name="value" type="string" />
		
		<cfif !isNumeric(arguments.value)><cfreturn arguments.value></cfif>
		<cfif listFind('11,12,13', right(arguments.value, 2))><cfreturn arguments.value & 'th'></cfif>
		<cfswitch expression="#right(arguments.number, 1)#">
			<cfcase value="1"><cfreturn arguments.value & 'st'></cfcase>
			<cfcase value="2"><cfreturn arguments.value & 'nd'></cfcase>
			<cfcase value="3"><cfreturn arguments.value & 'rd'></cfcase>
			<cfdefaultcase><cfreturn arguments.value & 'th'></cfdefaultcase>
		</cfswitch>	
	</cffunction>

    <cffunction name="__country" access="private" output="false">
		<cfargument name="value" type="string" />
		<cfargument name="property" default="commonName" hint="Property to Return">
        <cfargument name="source" default="abv3" hint="Source of value">

        <cfreturn createObject('component', 'regionHelper').getProperty(argumentCollection=arguments)>
    </cffunction>
    
    <cffunction name="__state" access="private" output="false">
		<cfargument name="value" type="string" />
 		<cfargument name="property" default="commonName" hint="Property to Return">
        <cfargument name="source" default="abv2" hint="Source of value">
        
        <cfreturn createObject('component', 'regionHelper').getProperty(argumentCollection=arguments)>
    </cffunction>

    <cffunction name="__list" access="private" output="false">
		<cfargument name="value" type="string" />
        <cfreturn reReplace(listChangeDelims(arguments.value, ', '), '(,)([^,]*)$', ' & \2')>
    </cffunction>

    <cffunction name="__listRandom" access="private" output="false">
		<cfargument name="value" type="string" />
		<cfargument name="count" type="numeric" default="1" />
		<cfset var local = {}>
		<cfset local.array = []>
		<cfloop from="1" to="#min(arguments.count, listLen(arguments.value))#" index="local.i">
			<cfset arrayAppend(local.array, listGetAt(arguments.value, randRange(1, listLen(arguments.value))))>
		</cfloop>
        <cfreturn arrayToList(local.array)>
    </cffunction>

    <cffunction name="__plural" access="private" output="false">
		<cfargument name="value" type="string" />
        <cfreturn new plugins.inflector().pluralize(arguments.value)>
    </cffunction>

    <cffunction name="__singular" access="private" output="false">
		<cfargument name="value" type="string" />
        <cfreturn new plugins.inflector().singularize(arguments.value)>
    </cffunction>

    <cffunction name="__inflect" access="private" output="false">
		<cfargument name="value" type="string" />
		<cfargument name="string" type="string" />
		<cfargument name="delimiters" type="string" default=",&" />
		<cfset arguments.string = reReplace(arguments.string, "^[""']|[""']$", "", "all")>
        <cfreturn listLen(arguments.value, arguments.delimiters) GT 1? new plugins.inflector().pluralize(arguments.string) : new plugins.inflector().singularize(arguments.string)>
    </cffunction>

    <cffunction name="__ifMultiple" access="private" output="false">
		<cfargument name="value" type="string" />
		<cfargument name="multiple" type="string" />
		<cfargument name="singular" type="string" />
		<cfargument name="delimiters" type="string" default=",&" />
		<cfset arguments.multiple = reReplace(arguments.multiple, "^[""']|[""']$", "", "all")>
		<cfset arguments.singular = reReplace(arguments.singular, "^[""']|[""']$", "", "all")>
        <cfreturn listLen(arguments.value, arguments.delimiters) GT 1? arguments.multiple : arguments.singular>
    </cffunction>
</cfcomponent>	