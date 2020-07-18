/**
 *	This is a version of the Mustache templating engine inherits the formatting
 *	options and always encodes all mustache tags for use in an HTML document.
 */

component extends="MustacheFormatter" {

	// force all encoding to use HTML encoder
	private function textEncode ( input, options, callerArgs ) {
		return htmlEncode( argumentCollection = arguments );
	}

}
