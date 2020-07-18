/**
 *  Mustache.cfc
 *
 *  This component is a ColdFusion implementation of the Mustache logic-less templating language (see http://mustache.github.com/.)
 *
 *  Key features of this implemenation:
 *
 *     * Enhanced whitespace management - extra whitespace around conditional output is automatically removed
 *     * Partials
 *     * Multi-line comments
 *     * And can be extended via the onRenderTag event to add additional rendering logic
 *
 *  Homepage:     https://github.com/rip747/Mustache.cfc
 *  Source Code:  https://github.com/rip747/Mustache.cfc.git
 *
 *  NOTES:
 *  reference for string building
 *  http://www.aliaspooryorik.com/blog/index.cfm/e/posts.details/post/string-concatenation-performance-test-128
 */

component {

	//  namespace for Mustache private variables (to avoid name collisions when extending Mustache.cfc)
	variables.Mustache          = structNew();
	variables.Mustache.Pattern  = createObject( 'java', 'java.util.regex.Pattern' );
	//  captures the ".*" match for looking for formatters (see #2) and also allows nested structure references (see #3), removes looking for comments
	variables.Mustache.TagRegEx = variables.Mustache.Pattern.compile(
		'\{\{(\{|&|\>)?\s*((?:[\w@]+(?:(?:\.\w+){1,})?)|\.)(.*?)\}?\}\}',
		32
	);
	//  Partial regex
	variables.Mustache.PartialRegEx = variables.Mustache.Pattern.compile(
		'\{\{\>\s*((?:\w+(?:(?:\.\w+){1,})?)|\.)(.*?)\}?\}\}',
		32
	);
	//  captures nested structure references
	variables.Mustache.SectionRegEx = variables.Mustache.Pattern.compile(
		'\{\{\s*(##|\^)\s*(\w+(?:(?:\.\w+){1,})?)\s*([\w\s"@.]+)?}}(.*?)\{\{\s*\/\s*\2\s*\}\}',
		32
	);
	//  captures nested structure references
	variables.Mustache.CommentRegEx = variables.Mustache.Pattern.compile(
		'((^\r?\n?)|\s+)?\{\{!.*?\}\}(\r?\n?(\r?\n?)?)?',
		40
	);
	//  captures nested structure references
	variables.Mustache.HeadTailBlankLinesRegEx = variables.Mustache.Pattern.compile(
		javacast( 'string', '(^(\r?\n))|((?<!(\r?\n))(\r?\n)$)' ),
		32
	);
	//  for tracking partials
	variables.Mustache.partials    = {};
	//  helpers
	variables.Mustache.helpers     = {};
	//  Raising Errors
	variables.Mustache.RaiseErrors = 'true';

	/**
	 * initalizes and returns the object
	 */
	public function init ( partials = {}, raiseErrors = 'true' ) {
		registerHelpers();
		setPartials( arguments.partials );
		setRaiseErrors( arguments.RaiseErrors );
		return this;
	}

	/**
	 * main function to call to a new template
	 */
	public function render (
		template          = readMustacheFile( listLast( getMetadata( this ).name, '.' ) ),
		context           = this,
		required partials = {},
		options           = {}
	) {
		//  Replace partials in template
		arguments.template = replacePartialsInTemplate( arguments.template, arguments.partials );
		var results        = renderFragment( argumentCollection = arguments );
		//  remove single blank lines at the head/tail of the stream
		results            = variables.Mustache.HeadTailBlankLinesRegEx.matcher( javacast( 'string', results ) ).replaceAll( '' );
		return results;
	}

	public void function registerHelper ( string helperName, function userFunction ) {
		variables.Mustache.helpers[helperName] = userFunction;
	}

	private function replacePartialsInTemplate ( template, partials ) {
		local.matches = ReFindNoCaseValues( arguments.template, variables.Mustache.PartialRegEx ).matches;
		if ( arrayLen( local.matches ) ) {
			local.partial = getPartial( trim( local.matches[2] ), arguments.partials );
			local.result  = replaceNoCase( arguments.template, local.matches[1], local.partial );
		} else {
			local.result = arguments.template;
		}
		return local.result;
	}

	/**
	 * handles all the various fragments of the template
	 */
	private function renderFragment (
		template,
		context,
		partials,
		options,
		index = ''
	) {
		//  clean the comments from the template
		arguments.template = variables.Mustache.CommentRegEx
			.matcher( javacast( 'string', arguments.template ) )
			.replaceAll( '$3' );
		structAppend( arguments.partials, variables.Mustache.partials, false );
		arguments.template = renderSections(
			arguments.template,
			arguments.context,
			arguments.partials,
			arguments.options,
			arguments.index
		);
		return renderTags(
			arguments.template,
			arguments.context,
			arguments.partials,
			arguments.options,
			arguments.index
		);
	}

	private function renderSections (
		template,
		context,
		partials,
		options,
		index
	) {
		var local               = {};
		var lastSectionPosition = -1;
		while ( condition = 'true' ) {
			local.matches = reFindNoCaseValues( arguments.template, variables.Mustache.SectionRegEx ).matches;
			if ( arrayLen( local.matches ) == 0 ) {
				break;
			}
			local.tag       = local.matches[1];
			local.type      = local.matches[2];
			local.tagName   = local.matches[3];
			local.tagParams = local.matches[4];
			local.inner     = local.matches[5];
			local.rendered  = renderSection(
				local.tagName,
				local.tagParams,
				local.type,
				local.inner,
				arguments.context,
				arguments.partials,
				arguments.options,
				arguments.index
			);
			//  look to see where the current tag exists in the output; which we use to see if starting whitespace should be trimmed -
			local.sectionPosition = find( local.tag, arguments.template );
			//  trims out empty lines from appearing in the output
			if ( len( trim( local.rendered ) ) == 0 ) {
				local.rendered = '$2';
			} else {
				//  escape the backreference
				local.rendered = replace( local.rendered, '$', '\$', 'all' );
			}
			//  if the current section is in the same place as the last template, we do not need to clean up whitespace--because it's already been managed
			if ( local.sectionPosition < lastSectionPosition ) {
				//  do not remove whitespace before the output, because we have already cleaned it
				local.whiteSpaceRegex = '';
				//  rendered content was empty, so we just want to replace all the text
				if ( local.rendered == '$2' ) {
					//  no whitespace to clean up
					local.rendered = '';
				}
			} else {
				//  clean out the extra lines of whitespace from the output
				local.whiteSpaceRegex = '(^\r?\n?)?(\r?\n?)?';
			}
			//  we use a regex to remove unwanted whitespacing from appearing
			arguments.template = variables.Mustache.Pattern
				.compile( javacast( 'string', local.whiteSpaceRegex & '\Q' & local.tag & '\E(\r?\n?)?' ), 40 )
				.matcher( javacast( 'string', arguments.template ) )
				.replaceAll( local.rendered );
			//  track the position of the last section -
			lastSectionPosition = local.sectionPosition;
		}
		return arguments.template;
	}

	private function renderSection (
		tagName,
		tagParams,
		type,
		inner,
		context,
		partials,
		options,
		index = ''
	) {
		var local = {};
		local.ctx = get(
			arguments.tagName,
			arguments.context,
			arguments.partials,
			arguments.options
		);
		if ( len( trim( arguments.tagParams ) ) ) {
			return renderHelper(
				arguments.tagName,
				arguments.tagParams,
				arguments.inner,
				arguments.context,
				arguments.partials,
				arguments.options,
				arguments.index
			);
		} else if ( arguments.type != '^' && isStruct( local.ctx ) && !structIsEmpty( local.ctx ) ) {
			return renderFragment(
				arguments.inner,
				local.ctx,
				arguments.partials,
				arguments.options,
				arguments.index
			);
		} else if ( arguments.type != '^' && isQuery( local.ctx ) && local.ctx.recordCount ) {
			return renderQuerySection(
				arguments.inner,
				local.ctx,
				arguments.partials,
				arguments.options
			);
		} else if ( arguments.type != '^' && isArray( local.ctx ) && !arrayIsEmpty( local.ctx ) ) {
			return renderArraySection(
				arguments.inner,
				local.ctx,
				arguments.partials,
				arguments.options
			);
		} else if (
			arguments.type != '^' && structKeyExists( arguments.context, arguments.tagName ) && isCustomFunction(
				arguments.context[arguments.tagName]
			)
		) {
			return renderLambda(
				arguments.tagName,
				arguments.inner,
				arguments.context,
				arguments.partials,
				arguments.options
			);
		}
		if ( arguments.type == '^' xor convertToBoolean( local.ctx ) ) {
			return arguments.inner;
		}
		return '';
	}

	private function renderHelper (
		tagName,
		tagParams,
		template,
		context,
		partials,
		options,
		index
	) {
		var local = {};
		if (
			structKeyExists( variables.Mustache.helpers, arguments.tagName ) && isCustomFunction(
				variables.Mustache.helpers[arguments.tagName]
			)
		) {
			local.theFunction = variables.Mustache.helpers[arguments.tagName];
			local.args        = [];
			for ( local.paramName in listToArray( arguments.tagParams, ' ' ) ) {
				if ( reFindNoCase( '^\s*".*"\s*$', local.paramName ) ) {
					local.paramValue = reReplaceNoCase( local.paramName, '^\s*"(.*)"\s*$', '\1' );
				} else {
					local.paramValue = get(
						local.paramName,
						arguments.context,
						arguments.partials,
						arguments.options,
						arguments.index
					);
				}
				arrayAppend( local.args, local.paramValue );
			}
			local.result = local.theFunction( arguments.template, local.args );
			return renderFragment(
				local.result,
				arguments.context,
				arguments.partials,
				arguments.options,
				arguments.index
			);
		} else {
			return '';
		}
	}

	/**
	 * render a lambda function (also provides a hook if you want to extend how lambdas works)
	 */
	private function renderLambda (
		tagName,
		template,
		context,
		partials,
		options
	) {
		var local = {};
		//  if running on a component
		if ( isObject( arguments.context ) ) {
			//  call the function and pass in the arguments
			cfinvoke( returnvariable = "local.results", method = arguments.tagName, component = arguments.context ) {
				// bug in lucee, see: https://luceeserver.atlassian.net/browse/LDEV-1110
				cfinvokeargument( name = 1, value = arguments.template );
			}
			//  otherwise we have a struct w/a reference to a function or closure
		} else {
			local.fn      = arguments.context[arguments.tagName];
			local.results = local.fn( arguments.template );
		}
		return local.results;
	}

	private function convertToBoolean ( value ) {
		if ( isBoolean( arguments.value ) ) {
			return arguments.value;
		}
		if ( isSimpleValue( arguments.value ) ) {
			return arguments.value != '';
		}
		if ( isStruct( arguments.value ) ) {
			return !structIsEmpty( arguments.value );
		}
		if ( isQuery( arguments.value ) ) {
			return arguments.value.recordcount != 0;
		}
		if ( isArray( arguments.value ) ) {
			return !arrayIsEmpty( arguments.value );
		}
		return false;
	}

	private function renderQuerySection ( template, context, partials, options ) {
		var results        = [];
		//  trim the trailing whitespace--so we don't print extra lines
		arguments.template = rTrim( arguments.template );

		/* toScript ERROR: Unimplemented cfloop condition:  query="arguments.context"

				<cfloop query="arguments.context">
			<cfset arrayAppend(results, renderFragment(arguments.template, arguments.context, arguments.partials, arguments.options, arguments.context.currentrow))/>
		</cfloop>

		*/

		return arrayToList( results, '' );
	}

	private function renderArraySection ( template, context, partials, options ) {
		var local           = {index : 1};
		//  trim the trailing whitespace--so we don't print extra lines
		arguments.template  = rTrim( arguments.template );
		savecontent variable="local.results" {
			for ( local.item in arguments.context ) {
				writeOutput(
					renderFragment(
						arguments.template,
						local.item,
						arguments.partials,
						arguments.options,
						local.index
					)
				);

				local.index++;
			}
		}
		return local.results;
	}

	private function renderTags (
		template,
		context,
		partials,
		options,
		index
	) {
		var local           = {};
		var lastTagPosition = 0;
		while ( condition = 'true' ) {
			// // find the next match of the content, but look after the last location //
			local.matchResults = reFindNoCaseValues( arguments.template, variables.Mustache.TagRegEx, lastTagPosition );
			local.matches      = local.matchResults.matches;
			if ( arrayLen( local.matches ) == 0 ) {
				break;
			}
			local.tag          = local.matches[1];
			local.type         = local.matches[2];
			local.tagName      = local.matches[3];
			//  gets the ".*" capture
			local.extra        = local.matches[4];
			arguments.template = replace(
				arguments.template,
				local.tag,
				renderTag(
					local.type,
					local.tagName,
					arguments.context,
					arguments.partials,
					arguments.options,
					local.extra,
					arguments.index
				)
			);
		}
		return arguments.template;
	}

	private function renderTag (
		type,
		tagName,
		context,
		partials,
		options,
		extra,
		index
	) {
		var local   = {};
		var results = '';
		var extras  = listToArray( arguments.extra, ':' );
		if ( arguments.type == '!' ) {
			return '';
		} else if ( (arguments.type == '{') || (arguments.type == '&') ) {
			arguments.value = get(
				arguments.tagName,
				arguments.context,
				arguments.partials,
				arguments.options,
				arguments.index
			);
			arguments.valueType = 'text';
			results             = textEncode( arguments.value, arguments.options, arguments );
		} else if ( arguments.type == '>' ) {
			arguments.value = renderPartial(
				arguments.tagName,
				arguments.context,
				arguments.partials,
				arguments.options
			);
			arguments.valueType = 'partial';
			results             = arguments.value;
		} else {
			arguments.value = get(
				arguments.tagName,
				arguments.context,
				arguments.partials,
				arguments.options,
				arguments.index
			);
			arguments.valueType = 'html';
			results             = htmlEncode( arguments.value, arguments.options, arguments );
		}
		return onRenderTag( results, arguments );
	}

	/**
	 * Encodes a plain text string (can be overridden)
	 */
	private function textEncode ( input, options, callerArgs ) {
		//  we normally don't want to do anything, but this function is manually so we can overwrite the default behavior of {{{token}}}
		return arguments.input;
	}

	/**
	 * Encodes a string into HTML (can be overridden)
	 */
	private function htmlEncode ( input, options, callerArgs ) {
		return encodeForHTML( arguments.input );
	}

	/**
	 * override this function in your methods to provide additional formatting to rendered content
	 */
	private function onRenderTag ( rendered, callerArgs ) {
		//  do nothing but return the passed in value
		return arguments.rendered;
	}

	/**
	 * If we have the partial registered, use that, otherwise use the registered text
	 */
	private function renderPartial (
		required name,
		required context,
		required partials,
		options
	) {
		if ( structKeyExists( arguments.partials, arguments.name ) ) {
			return this.render(
				arguments.partials[arguments.name],
				arguments.context,
				arguments.partials,
				arguments.options
			);
		} else {
			return this.render(
				readMustacheFile( arguments.name ),
				arguments.context,
				arguments.partials,
				arguments.options
			);
		}
	}

	private function readMustacheFile ( filename ) {
		var template = '';
		try {
			cffile(
				variable = "template",
				file     = "#getDirectoryFromPath( getMetadata( this ).path )##arguments.filename#.mustache",
				action   = "read"
			);
		} catch ( any cfcatch ) {
			if ( getRaiseErrors() ) {
				throw( message = 'Cannot not find `#arguments.filename#` template', type = 'Mustache.TemplateMissing' );
			} else {
				return '';
			}
		}
		return trim( template );
	}

	private function get (
		key,
		context,
		partials,
		options,
		index = ''
	) {
		var local = {};
		//  if we are the implicit iterator
		if ( arguments.key == '.' ) {
			return toString( context );
		} else if ( arguments.key == '@index' ) {
			return index;
			//  if we're a nested key, do a nested lookup
		} else if ( find( '.', arguments.key ) ) {
			local.key  = listRest( arguments.key, '.' );
			local.root = listFirst( arguments.key, '.' );
			if ( structKeyExists( arguments.context, local.root ) ) {
				return get(
					local.key,
					context[local.root],
					arguments.partials,
					arguments.options,
					arguments.index
				);
			} else {
				return '';
			}
		} else if ( isStruct( arguments.context ) && structKeyExists( arguments.context, arguments.key ) ) {
			if ( isCustomFunction( arguments.context[arguments.key] ) ) {
				return renderLambda(
					arguments.key,
					'',
					arguments.context,
					arguments.partials,
					arguments.options
				);
			} else {
				return arguments.context[arguments.key];
			}
		} else if ( isQuery( arguments.context ) ) {
			if ( listContainsNoCase( arguments.context.columnList, arguments.key ) ) {
				return arguments.context[arguments.key][arguments.context.currentrow];
			} else {
				return '';
			}
		} else {
			return '';
		}
	}

	private function reFindNoCaseValues ( text, re, numeric position = '0' ) {
		var local       = {};
		local.results   = {'position' : {'start' : 0, 'end' : 0}, 'matches' : []};
		local.matcher   = arguments.re.matcher( arguments.text );
		local.i         = 0;
		local.nextMatch = '';
		if ( local.matcher.Find( javacast( 'int', arguments.position ) ) ) {
			local.results.position.start = local.matcher.start();
			local.results.position.end   = local.matcher.end();
			for ( local.i = 0; local.i <= local.matcher.groupCount(); local.i++ ) {
				// // NOTE: For CF2018, we need to cast the counter to an int, otherwise it's passed in as a string //
				local.nextMatch = local.matcher.group( javacast( 'int', local.i ) );
				if ( isDefined( 'local.nextMatch' ) ) {
					arrayAppend( local.results.matches, local.nextMatch );
				} else {
					arrayAppend( local.results.matches, '' );
				}
			}
		}
		return local.results;
	}

	private function getPartial ( required name, partials ) {
		if ( structKeyExists( variables.Mustache.partials, arguments.name ) ) {
			return variables.Mustache.partials[arguments.name];
		} else if ( structKeyExists( arguments, 'partials' ) && structKeyExists( arguments.partials, arguments.name ) ) {
			return arguments.partials[arguments.name];
		} else {
			//  Fetch from file as last resort
			return readMustacheFile( arguments.name );
		}
	}

	public function getPartials ( ) {
		return variables.Mustache.partials;
	}

	public function setPartials ( required partials, options ) {
		variables.Mustache.partials = arguments.partials;
	}

	public function getRaiseErrors ( ) {
		return variables.Mustache.RaiseErrors;
	}

	public function setRaiseErrors ( required boolean value ) {
		variables.Mustache.RaiseErrors = arguments.value;
	}

	private function registerHelpers ( ) {
		registerHelper( 'if', helperIf );
		registerHelper( 'unless', helperUnless );
		registerHelper( 'repeat', helperRepeat );
		registerHelper( 'withRemainder', helperWithRemainder );
		registerHelper( 'noRemainder', helperNoRemainder );
	}

	private function helperIf ( template, params ) {
		return convertToBoolean( params[1] ) ? template : '';
	}

	private function helperUnless ( template, params ) {
		return convertToBoolean( params[1] ) ? '' : template;
	}

	private function helperRepeat ( template, params ) {
		if ( !isNumeric( params[1] ) ) {
			return '';
		}
		var sb = createObject( 'java', 'java.lang.StringBuilder' ).init();
		for ( i = 1; i <= params[1]; i++ ) {
			sb.append( template );
		}
		return sb.toString();
	}

	private function helperWithRemainder ( template, args ) {
		return (args[2] mod args[1]) ? template : '';
	}

	private function helperNoRemainder ( template, args ) {
		return (args[2] mod args[1]) ? '' : template;
	}

}
