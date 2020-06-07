<!---//
	This is a version of the Mustache templating engine inherits the formatting
	options and always encodes all mustache tags for use in an HTML document.
//--->
<cfcomponent extends="MustacheFormatter" output="false">

	<!---// force all encoding to use HTML encoder //--->
	<cffunction name="textEncode" access="private" output="false">
		<cfargument name="input"/>
		<cfargument name="options"/>
		<cfargument name="callerArgs" hint="Arguments supplied to the renderTag() function"/>

		<cfreturn htmlEncode(argumentCollection=arguments)/>
	</cffunction>

</cfcomponent>