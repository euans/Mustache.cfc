<cfcomponent extends="mxunit.framework.TestCase">

	<cffunction name="setup">
		<cfset partials = {} />
		<cfset options = {} />
		<cfset stache = createObject("component", "mustache.MustacheTextOnlyEncoder").init() />
	</cffunction>

	<cffunction name="tearDown">
		<!---// make sure tests are case sensitive //--->
		<cfset assertEqualsCase(expected, stache.render(template, context, partials, options))/>
		<!---// reset variables //--->
		<cfset partials = {} />
		<cfset context = {} />
	</cffunction>

  <cffunction name="textEncode_should_encode_as_plain_text">
    <cfset context = { thing = '<b>World</b>'} />
    <cfset template = "Hello, {{{thing}}}!" />
    <cfset expected = "Hello, <b>World</b>!" />
  </cffunction>

  <cffunction name="htmlEncode_should_encode_as_plain_text">
    <cfset context = { thing = '<b>World</b>'} />
    <cfset template = "Hello, {{thing}}!" />
    <cfset expected = "Hello, <b>World</b>!" />
  </cffunction>

</cfcomponent>