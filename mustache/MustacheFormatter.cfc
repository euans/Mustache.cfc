/**
 *	This extention to Mustache provides the following functionality:
 *
 *	1) It adds Ctemplate-style "modifiers" (or formatters). You can now use the following
 *	   syntax with your variables:
 *
 *	   Hello "{{NAME:leftPad(20):upperCase}}"
 *
 *	   This would output the "NAME" variable, left justify it's output to 20 characters and
 *	   make the string upper case.
 *
 *	   The idea is to provide a collection of common formatter functions, but a user could
 *	   extend this compontent to add in their own user formatters.
 *
 *	   This method provides is more readable and easy to implement over the lambda functionality
 *	   in the default Mustache syntax.
 */

component extends="Mustache" {

	// captures arguments to be passed to formatter functions
	variables.Mustache.ArgumentsRegEx = createObject( 'java', 'java.util.regex.Pattern' ).compile(
		"[^\s,]*(?<!\\)\(.*?(?<!\\)\)|(?<!\\)\[.*?(?<!\\)\]|(?<!\\)\{.*?(?<!\\)\}|(?<!\\)('|"").*?(?<!\\)\1|(?:(?!,)\S)+",
		40
	);
	// overwrite the default methods
	private function onRenderTag ( rendered, options ) {
		var local   = {};
		var results = arguments.rendered;
		if ( !structKeyExists( arguments.options, 'extra' ) || !len( arguments.options.extra ) ) {
			return results;
		}
		local.extras = listToArray( arguments.options.extra, ':' );
		// look for functional calls (see #2)
		for ( local.fn in local.extras ) {
			// all formatting functions start with two underscores
			local.fn     = trim( '__' & local.fn );
			local.fnName = listFirst( local.fn, '(' );
			// check to see if we have a function matching this fn name
			if ( structKeyExists( variables, local.fnName ) && isCustomFunction( variables[local.fnName] ) ) {
				// get the arguments (but ignore empty arguments)
				if ( reFind( '\([^\)]+\)', local.fn ) ) {
					// get the arguments from the function name
					local.args = replace( local.fn, local.fnName & '(', '' );
					// gets the arguments from the string
					local.args = regexMatch(
						left( local.args, len( local.args ) - 1 ),
						variables.Mustache.ArgumentsRegEx
					);
				} else {
					local.args = [];
				}
				// call the function and pass in the arguments
				cfinvoke( returnvariable = "results", method = local.fnName ) {
					// bug in lucee, see: https://luceeserver.atlassian.net/browse/LDEV-1110
					cfinvokeargument( name = 1, value = results );
					local.i = 1;
					for ( local.value in local.args ) {
						local.i++;
						cfinvokeargument( name = local.i, value = trim( local.value ) );
					}
				}
			}
		}
		return results;
	}

	private function regexMatch ( text, re ) {
		var local       = {};
		local.results   = [];
		local.matcher   = arguments.re.matcher( arguments.text );
		local.i         = 0;
		local.nextMatch = '';
		while ( condition = '#local.matcher.find()#' ) {
			// NOTE: For CF2018, we need to cast to integer to be safe
			local.nextMatch = local.matcher.group( javacast( 'int', 0 ) );
			if ( isDefined( 'local.nextMatch' ) ) {
				arrayAppend( local.results, local.nextMatch );
			} else {
				arrayAppend( local.results, '' );
			}
		}
		return local.results;
	}
	/*
		MUSTACHE FUNCTIONS
	 //*/

	private function __leftPad ( string value, numeric length ) {
		return lJustify( arguments.value, arguments.length );
	}

	private function __rightPad ( string value, numeric length ) {
		return rJustify( arguments.value, arguments.length );
	}

	private function __upperCase ( string value ) {
		return uCase( arguments.value );
	}

	private function __lowerCase ( string value ) {
		return lCase( arguments.value );
	}

	private function __multiply ( numeric num1, numeric num2 ) {
		return arguments.num1 * arguments.num2;
	}

}
