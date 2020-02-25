<!---//
	This is a version of the Mustache templating engine inherits the formatting
	options and always encodes all mustache tags into plain text.
//--->
<cfcomponent extends="MustacheFormatter" output="false">

	<!---// force all encoding to text encoder //--->
	<cffunction name="htmlEncode" access="private" output="false">
		<cfargument name="input"/>
		<cfargument name="options"/>
		<cfargument name="callerArgs" hint="Arguments supplied to the renderTag() function"/>

		<cfreturn textEncode(argumentCollection=arguments)/>
	</cffunction>

</cfcomponent>