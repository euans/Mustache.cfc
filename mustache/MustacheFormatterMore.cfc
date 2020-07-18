component extends="MustacheFormatter" {

	private function __dollarFormat ( string value ) {
		return dollarFormat( arguments.value );
	}

	private function __decimalFormat ( string value ) {
		return numberFormat( arguments.value, '0.00' );
	}

	private function __percentFormat ( string value ) {
		return numberFormat( arguments.value, '0.00' ) & '%';
	}

	private function __dateFormat ( string value, string format = 'mm/dd/yyyy' ) {
		return dateFormat( arguments.value, arguments.format );
	}

	private function __dateTimeFormat ( string value, string dateFormat = 'mm/dd/yyyy ', string timeFormat = 'hh:mm tt' ) {
		return dateFormat( arguments.value, arguments.dateFormat ) & timeFormat( arguments.value, arguments.timeFormat );
	}

	private function __properCase ( string value ) {
		var local        = {};
		local.exceptions = 'diMartini,ColdFusion';
		local.exceptions = reReplace( local.exceptions, ',\s+', ',', 'all' );
		arguments.value  = reReplace(
			lCase( arguments.value ),
			'([a-z])\1{2}\s',
			'\u\0',
			'all'
		);
		arguments.value = reReplace(
			arguments.value,
			'[\w]+',
			'\u\0',
			'all'
		);
		arguments.value = reReplace(
			arguments.value,
			"'([A-Z]\s)",
			"'\l\1",
			'all'
		);
		arguments.value = reReplace(
			arguments.value,
			'(Ma?c)([a-z])',
			'\1\u\2',
			'all'
		);
		arguments.value = reReplace(
			arguments.value,
			"(D[eia]?')([a-zA-Z])",
			'\l\1\u\2',
			'all'
		);
		arguments.value = reReplace(
			arguments.value,
			'((D[eia]|L[ea]|V[ao]n)\s)',
			'\l\1',
			'all'
		);
		arguments.value = reReplace(
			arguments.value,
			'([FMS]t)(\s)',
			'\1.\2',
			'all'
		);
		arguments.value = reReplaceNoCase(
			arguments.value,
			'(\s?)(an|the|at|by|for|of|in|up|on|to|and|as|but|or|nor|a)(\s)',
			'\1\l\2\3',
			'all'
		);
		for ( local.word in reMatchNoCase( '([a-z])\1{2}\s', arguments.value ) ) {
			arguments.value = replace( arguments.value, local.word, uCase( local.word ) );
		}
		for ( local.word in listToArray( arguments.value, ' ' ) ) {
			local.index = listFindNoCase( local.exceptions, local.word );
			if ( local.index > 0 ) {
				arguments.value = replace( arguments.value, local.word, listGetAt( local.exceptions, local.index ) );
			}
		}
		return arguments.value;
	}

	private function __antiSpam ( required string value, boolean mailTo = 'false' ) {
		var local           = {};
		var local.rtnString = '';
		for ( local.i = 1; local.i <= len( arguments.value ); local.i++ ) {
			local.rtnString = local.rtnString & '&##' & asc( mid( arguments.value, local.i, 1 ) ) & ';';
		}
		if ( arguments.mailTo ) {
			return '<a href=' & 'mailto:' & local.rtnString & '>' & local.rtnString & '</a>';
		}
		return local.rtnString;
	}

	/**
	 * Takes a number as an argument, and returns the 2 letter english text ordinal appropriate for the number
	 */
	public string function __ordinal ( string value ) {
		if ( !isNumeric( arguments.value ) ) {
			return arguments.value;
		}
		if ( listFind( '11,12,13', right( arguments.value, 2 ) ) ) {
			return arguments.value & 'th';
		}
		switch ( right( arguments.number, 1 ) ) {
			case 1:
				return arguments.value & 'st';
				break;
			case 2:
				return arguments.value & 'nd';
				break;
			case 3:
				return arguments.value & 'rd';
				break;
			default:
				return arguments.value & 'th';
				break;
		}
	}

	private function __country ( string value, property = 'commonName', source = 'abv3' ) {
		return createObject( 'component', 'regionHelper' ).getProperty( argumentCollection = arguments );
	}

	private function __state ( string value, property = 'commonName', source = 'abv2' ) {
		return createObject( 'component', 'regionHelper' ).getProperty( argumentCollection = arguments );
	}

	private function __list ( string value ) {
		return reReplace( listChangeDelims( arguments.value, ', ' ), '(,)([^,]*)$', ' & \2' );
	}

	private function __listRandom ( string value, numeric count = '1' ) {
		var local   = {};
		local.array = [];
		for ( local.i = 1; local.i <= min( arguments.count, listLen( arguments.value ) ); local.i++ ) {
			arrayAppend( local.array, listGetAt( arguments.value, randRange( 1, listLen( arguments.value ) ) ) );
		}
		return arrayToList( local.array );
	}

	private function __plural ( string value ) {
		return new plugins.inflector().pluralize( arguments.value );
	}

	private function __singular ( string value ) {
		return new plugins.inflector().singularize( arguments.value );
	}

	private function __inflect ( string value, string string, string delimiters = ',&' ) {
		arguments.string = reReplace(
			arguments.string,
			"^[""']|[""']$",
			'',
			'all'
		);
		return listLen( arguments.value, arguments.delimiters ) > 1 ? new plugins.inflector().pluralize(
			arguments.string
		) : new plugins.inflector().singularize( arguments.string );
	}

	private function __ifMultiple (
		string value,
		string multiple,
		string singular,
		string delimiters = ',&'
	) {
		arguments.multiple = reReplace(
			arguments.multiple,
			"^[""']|[""']$",
			'',
			'all'
		);
		arguments.singular = reReplace(
			arguments.singular,
			"^[""']|[""']$",
			'',
			'all'
		);
		return listLen( arguments.value, arguments.delimiters ) > 1 ? arguments.multiple : arguments.singular;
	}

}
