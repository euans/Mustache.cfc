/**
 *	This is a version of the Mustache templating engine inherits the formatting
 *	options and always encodes all mustache tags into plain text.
 */

component extends="MustacheFormatter" {

	// force all encoding to text encoder
	private function htmlEncode ( input, options, callerArgs ) output=false {
		return textEncode( argumentCollection = arguments );
	}

}
