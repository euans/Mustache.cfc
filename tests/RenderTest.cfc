<cfcomponent extends="mxunit.framework.TestCase">

	<cffunction name="_customHelper" access="private">
		<cfargument name="template">
		<cfargument name="args">

		<cfreturn template & " " & args[1] & " " & args[2]>
	</cffunction>

	<cffunction name="setup">
		<cfset partials = {} />
		<cfset stache = createObject("component", "mustache.Mustache").init() />
		<cfset stache.registerHelper("customHelper", _customHelper)>
	</cffunction>

	<cffunction name="tearDown">
<!---
		<cfoutput>#htmlCodeFormat(expected)#</cfoutput>
		<hr />
		<cfoutput>#htmlCodeFormat(stache.render(template, context, partials))#</cfoutput>
		<cfabort />
--->
		<cfset assertEquals(expected, stache.render(template, context, partials))/>
	</cffunction>

  <cffunction name="basic">
    <cfset context = { thing = 'world'} />
    <cfset template = "Hello, {{thing}}!" />
    <cfset expected = "Hello, World!" />
  </cffunction>

  <cffunction name="basicWithSpace">
    <cfset context = { thing = 'world'} />
    <cfset template = "Hello, {{ thing }}!" />
    <cfset expected = "Hello, World!" />
  </cffunction>

  <cffunction name="basicWithMuchSpace">
    <cfset context = { thing = 'world'} />
    <cfset template = "Hello, {{             thing    }}!" />
    <cfset expected = "Hello, World!" />
  </cffunction>

  <cffunction name="lessBasic">
    <cfset context = { beverage = 'soda', person = 'Bob' } />
    <cfset template = "It's a nice day for {{beverage}}, right {{person}}?" />
    <cfset expected = "It's a nice day for soda, right Bob?"/>
  </cffunction>

  <cffunction name="evenLessBasic">
    <cfset context = { name = 'Jon', thing = 'racecar'} />
    <cfset template = "I think {{name}} wants a {{thing}}, right {{name}}?">
    <cfset expected = "I think Jon wants a racecar, right Jon?" />
  </cffunction>

  <cffunction name="ignoresMisses">
    <cfset context = { name = 'Jon'} />
    <cfset template = "I think {{name}} wants a {{thing}}, right {{name}}?">
    <cfset expected = "I think Jon wants a , right Jon?" />
  </cffunction>

  <cffunction name="renderZero">
    <cfset context = { value = 0 } />
    <cfset template = "My value is {{value}}." />
    <cfset expected = "My value is 0." />
  </cffunction>

  <cffunction name="comments">
    <cfset context = structNew() />
    <cfset context['!'] = "FAIL" />
    <cfset context['the'] = "FAIL" />
    <cfset template = "What {{!the}} what?" />
    <cfset expected = "What what?" />
  </cffunction>

  <cffunction name="falseSectionsAreHidden">
    <cfset context =  { set = false } />
    <cfset template = "Ready {{##set}}set {{/set}}go!" />
    <cfset expected = "Ready go!" />
  </cffunction>

   <cffunction name="trueSectionsAreShown">
    <cfset context =  { set = true }  />
    <cfset template = "Ready {{##set}}set {{/set}}go!" />
    <cfset expected = "Ready set go!" />
  </cffunction>

  <cffunction name="falseSectionsWithSpaceAreHidden">
    <cfset context =  { set = false } />
    <cfset template = "Ready {{ ##set }}set {{ /set }}go!" />
    <cfset expected = "Ready go!" />
  </cffunction>

   <cffunction name="trueSectionsWithSpaceAreShown">
    <cfset context =  { set = true }  />
    <cfset template = "Ready {{ ##set }}set {{ /set }}go!" />
    <cfset expected = "Ready set go!" />
  </cffunction>

  <cffunction name="falseSectionsAreShownIfInverted">
    <cfset context =  { set = false }  />
    <cfset template = "Ready {{^set}}set {{/set}}go!" />
    <cfset expected = "Ready set go!" />
  </cffunction>

  <cffunction name="trueSectionsAreHiddenIfInverted">
    <cfset context =  { set = true }  />
    <cfset template = "Ready {{^set}}set {{/set}}go!" />
    <cfset expected = "Ready go!" />
  </cffunction>

  <cffunction name="emptyStringsAreFalse">
    <cfset context =  { set = "" }  />
    <cfset template = "Ready {{##set}}set {{/set}}go!" />
    <cfset expected = "Ready go!" />
  </cffunction>

  <cffunction name="emptyQueriesAreFase">
    <cfset context =  { set = QueryNew('firstname,lastname') }  />
    <cfset template = "Ready {{^set}}No records found {{/set}}go!" />
     <cfset expected = "Ready No records found go!" />
  </cffunction>

  <cffunction name="emptyStructsAreFalse">
    <cfset context =  { set = {} } />
     <cfset template = "Ready {{^set}}No records found {{/set}}go!" />
     <cfset expected = "Ready No records found go!" />
  </cffunction>

  <cffunction name="emptyArraysAreFalse">
    <cfset context =  { set = [] }  />
     <cfset template = "Ready {{^set}}No records found {{/set}}go!" />
     <cfset expected = "Ready No records found go!" />
  </cffunction>

	<cffunction name="nonEmptyStringsAreTrue">
    <cfset context =  { set = "x" }  />
    <cfset template = "Ready {{##set}}set {{/set}}go!" />
    <cfset expected = "Ready set go!" />
  </cffunction>

	<cffunction name="skipMissingField">
		<cfset context =  structNew()  />
    <cfset template = "There's something {{##foo}}missing{{/foo}}!" />
    <cfset expected = "There's something !" />
	</cffunction>

  <cffunction name="structAsSection">
    <cfset context = {
      contact = { name = 'Jenny', phone = '867-5309'}
    } />
    <cfset template = "{{##contact}}({{name}}'s number is {{phone}}){{/contact}}">
    <cfset expected = "(Jenny's number is 867-5309)" />
  </cffunction>

  <cffunction name="noSpaceTokenTest_array">
    <cfset context = {
      list = [{item='a'}, {item='b'}, {item='c'}, {item='d'}, {item='e'}]
    } />
    <cfset template = "{{##list}}({{item}}){{/list}}" />
    <cfset expected = "(a)(b)(c)(d)(e)" />
  </cffunction>

  <cffunction name="implicitIterator_String">
    <cfset context = {
      list = ['a', 'b', 'c', 'd', 'e']
    } />
    <cfset template = "{{##list}}({{.}}){{/list}}" />
    <cfset expected = "(a)(b)(c)(d)(e)" />
  </cffunction>

  <cffunction name="implicitIterator_Integer">
    <cfset context = {
      list = [1, 2, 3, 4, 5]
    } />
    <cfset template = "{{##list}}({{.}}){{/list}}" />
    <cfset expected = "(1)(2)(3)(4)(5)" />
  </cffunction>

  <cffunction name="implicitIterator_Decimal">
    <cfset context = {
      list = [1.10, 2.20, 3.30, 4.40, 5.50]
    } />
    <cfset template = "{{##list}}({{.}}){{/list}}" />
    <cfset expected = "(1.10)(2.20)(3.30)(4.40)(5.50)" />
  </cffunction>

  <cffunction name="arrayIndexSimple">
    <cfset context = {
      fruitsAndNumbers = ["apple","banana","orange",1234,1337.575]
    } />
    <cfset template = "{{##fruitsAndNumbers}}({{@index}}:{{.}}){{/fruitsAndNumbers}}">
    <cfset expected = "(1:apple)(2:banana)(3:orange)(4:1234)(5:1337.575)" />
  </cffunction>

  <cffunction name="arrayIndexNested">
    <cfset context = {
      movies = [
	  	{name="From Dusk Till Dawn", actors=["Clooney", "Keitel", "Tarantino"]},
	  	{name="Pulp Fiction", actors=["Travolta", "Jackson", "Thurman", "Willis"]},
	  	{name="Django Unchained", actors=["Foxx", "Waltz"]}
      ]
    } />
    <cfset template = "{{##movies}}(Movie {{@index}}:{{##actors}} {{@index}}. {{.}}{{/actors}}){{/movies}}">
    <cfset expected = "(Movie 1: 1. Clooney 2. Keitel 3. Tarantino)(Movie 2: 1. Travolta 2. Jackson 3. Thurman 4. Willis)(Movie 3: 1. Foxx 2. Waltz)" />
  </cffunction>

  <cffunction name="indexShouldBeEmptyIfNotInsideLoop">
    <cfset context = {
      foobar = ["a","b"]
    } />
    <cfset template = "{{@index}}{{##foobar}}.{{/foobar}}{{@index}}">
    <cfset expected = ".." />
  </cffunction>

  <cffunction name="queryIndex">
    <cfset contacts = queryNew("name")/>
    <cfset queryAddRow(contacts)>
    <cfset querySetCell(contacts, "name", "Peter") />
    <cfset queryAddRow(contacts)>
    <cfset querySetCell(contacts, "name", "Laura") />
    <cfset context = {contacts = contacts} />
    <cfset template = "{{##contacts}}({{@index}}. {{name}}){{/contacts}}">
    <cfset expected = "(1. Peter)(2. Laura)" />
  </cffunction>

  <cffunction name="queryAsSection">
    <cfset contacts = queryNew("name,phone")/>
    <cfset queryAddRow(contacts)>
    <cfset querySetCell(contacts, "name", "Jenny") />
    <cfset querySetCell(contacts, "phone", "867-5309") />
    <cfset queryAddRow(contacts)>
    <cfset querySetCell(contacts, "name", "Tom") />
    <cfset querySetCell(contacts, "phone", "555-1234") />
    <cfset context = {contacts = contacts} />
    <cfset template = "{{##contacts}}({{name}}'s number is {{phone}}){{/contacts}}">
    <cfset expected = "(Jenny's number is 867-5309)(Tom's number is 555-1234)" />
  </cffunction>

  <cffunction name="missingQueryColumnIsSkipped">
    <cfset contacts = queryNew("name")/>
    <cfset queryAddRow(contacts)>
    <cfset querySetCell(contacts, "name", "Jenny") />
    <cfset context = {contacts = contacts} />
    <cfset template = "{{##contacts}}({{name}}'s number is {{phone}}){{/contacts}}">
    <cfset expected = "(Jenny's number is )" />
  </cffunction>

  <cffunction name="arrayAsSection">
    <cfset context = {
      contacts = [
        { name = 'Jenny', phone = '867-5309'}
        , { name = 'Tom', phone = '555-1234'}
      ]
    } />
    <cfset template = "{{##contacts}}({{name}}'s number is {{phone}}){{/contacts}}">
    <cfset expected = "(Jenny's number is 867-5309)(Tom's number is 555-1234)" />
  </cffunction>

  <cffunction name="missingStructKeyIsSkipped">
    <cfset context = {
      contacts = [
        { name = 'Jenny', phone = '867-5309'}
        , { name = 'Tom'}
      ]
    } />
    <cfset template = "{{##contacts}}({{name}}'s number is {{^phone}}unlisted{{/phone}}{{phone}}){{/contacts}}">
    <cfset expected = "(Jenny's number is 867-5309)(Tom's number is unlisted)" />
  </cffunction>

  <cffunction name="escape">
    <cfset context = { thing = '<b>world</b>'} />
    <cfset template = "Hello, {{thing}}!" />
    <cfset expected = "Hello, &lt;b&gt;world&lt;/b&gt;!" />
  </cffunction>

  <cffunction name="dontEscape">
    <cfset template = "Hello, {{{thing}}}!" />
    <cfset context = { thing = '<b>world</b>'} />
    <cfset expected = "Hello, <b>world</b>!" />
  </cffunction>

  <cffunction name="dontEscapeWithAmpersand">
    <cfset context = { thing = '<b>world</b>'} />
    <cfset template = "Hello, {{&thing}}!" />
    <cfset expected = "Hello, <b>world</b>!" />
  </cffunction>

  <cffunction name="ignoreWhitespace">
    <cfset context = { thing = 'world'} />
    <cfset template = "Hello, {{   thing   }}!" />
    <cfset expected = "Hello, world!" />
  </cffunction>

  <cffunction name="ignoreWhitespaceInSection">
    <cfset context =  { set = true }  />
    <cfset template = "Ready {{##  set  }}set {{/  set  }}go!" />
    <cfset expected = "Ready set go!" />
  </cffunction>

  <cffunction name="callAFunction">
    <cfset context = createObject("component", "Person")/>
    <cfset context.firstname = "Chris" />
    <cfset context.lastname = "Wanstrath" />
    <cfset template = "Mustache was created by {{fullname}}." />
    <cfset expected = "Mustache was created by Chris Wanstrath." />
  </cffunction>

  <cffunction name="lambdaTest" access="private">
		<cfreturn "Chris Wanstrath" />
	</cffunction>

  <cffunction name="lambda">
		<cfset context = {fullname=lambdaTest} />
    <cfset template = "Mustache was created by {{fullname}}." />
    <cfset expected = "Mustache was created by Chris Wanstrath." />
  </cffunction>
  
  <cffunction name="ifHelper">
    <cfset q1 = queryNew("name")/>
    <cfset queryAddRow(q1)>
    <cfset querySetCell(q1, "name", "Jenny") />
    <cfset q2 = queryNew("name")/>
    <cfset context = {
    	true1=true,
    	true2=1,
    	true3=55.34,
    	true4="Test",
    	true5={"foobar"=1},
    	true6=["a"],
    	true7=q1,
    	false1=false,
    	false2=0,
    	false3=0.0,
    	false4="",
    	false5={},
    	false6=[],
    	false7=q2
    	}/>
    <cfset template = "{{##if true1}}(t1){{/if}}{{##if true2}}(t2){{/if}}{{##if true3}}(t3){{/if}}{{##if true4}}(t4){{/if}}{{##if true5}}(t5){{/if}}{{##if true6}}(t6){{/if}}{{##if true7}}(t7){{/if}}" />
    <cfset template &= "{{##if false1}}(f1){{/if}}{{##if false2}}(f2){{/if}}{{##if false3}}(f3){{/if}}{{##if false4}}(f4){{/if}}{{##if false5}}(f5){{/if}}{{##if false6}}(f6){{/if}}{{##if false7}}(f7){{/if}}" />
    <cfset expected = "(t1)(t2)(t3)(t4)(t5)(t6)(t7)" />
  </cffunction>

  <cffunction name="repeatHelper">
    <cfset context = {nTimes=3}/>
    <cfset template = "{{##repeat nTimes}}A{{/repeat}}{{##repeat ""5""}}B{{/repeat}}" />
    <cfset expected = "AAABBBBB" />
  </cffunction>

  <cffunction name="withRemainderHelper">
    <cfset context = {names=["Peter","Hans","Fritz","Susanne","Maria"]}/>
    <cfset template = '{{##names}}({{.}}){{##withRemainder "2" @index}}<br>{{/withRemainder}}{{/names}}' />
    <cfset expected = "(Peter)<br>(Hans)(Fritz)<br>(Susanne)(Maria)<br>" />
  </cffunction>

  <cffunction name="noRemainderHelper">
    <cfset context = {names=["Peter","Hans","Fritz","Susanne","Maria"]}/>
    <cfset template = '{{##names}}({{.}}){{##noRemainder "2" @index}}<br>{{/noRemainder}}{{/names}}' />
    <cfset expected = "(Peter)(Hans)<br>(Fritz)(Susanne)<br>(Maria)" />
  </cffunction>

  <cffunction name="customHelper">
    <cfset context = {firstName="Foo"}/>
    <cfset template = '{{##customHelper firstName "Bar"}}My name is{{/customHelper}}' />
    <cfset expected = "My name is Foo Bar" />
  </cffunction>

  <cffunction name="filter">
    <cfset context = createObject("component", "Filter")/>
    <cfset template = "Hello, {{##bold}}world{{/bold}}." />
    <cfset expected = "Hello, <b>world</b>." />
  </cffunction>

  <cffunction name="partial">
	  <!--- using a subclass so that it will look for the partial in this directory --->
		<cfset stache = createObject("component", "Winner").init()/>
    <cfset context = { word = 'Goodnight', name = 'Gracie' } />
    <cfset template = "<ul><li>Say {{word}}, {{name}}.</li><li>{{> gracie_allen}}</li></ul>" />
    <cfset expected = "<ul><li>Say Goodnight, Gracie.</li><li>Goodnight</li></ul>" />
  </cffunction>

	<cffunction name="globalRegisteredPartial">
		<!--- reinit, passing in the global partial --->
		<cfscript>
			var initPartials =
			{
				gracie_allen = fileRead(expandPath("/tests/gracie_allen.mustache"))
			};
		</cfscript>

		<cfset stache = createObject("component", "mustache.Mustache").init(initPartials)/>
		<cfset context = { word = 'Goodnight', name = 'Gracie' }/>
		<cfset template = "<ul><li>Say {{word}}, {{name}}.</li><li>{{> gracie_allen}}</li></ul>"/>
		<cfset expected = "<ul><li>Say Goodnight, Gracie.</li><li>Goodnight</li></ul>"/>
	</cffunction>

	<cffunction name="runtimeRegisteredPartial">

		<cfscript>
			partials =
			{
				gracie_allen = fileRead(expandPath("/tests/gracie_allen.mustache"))
			};
		</cfscript>

		<cfset context = { word = 'Goodnight', name = 'Gracie' }/>
		<cfset template = "<ul><li>Say {{word}}, {{name}}.</li><li>{{> gracie_allen}}</li></ul>"/>
		<cfset expected = "<ul><li>Say Goodnight, Gracie.</li><li>Goodnight</li></ul>"/>

	</cffunction>

	<cffunction name="invertedSectionHiddenIfStructureNotEmpty">
		<cfset context =  {set = {something='whatever'}}  />
		<cfset template = "{{##set}}This sentence should be showing.{{/set}}{{^set}}This sentence should not.{{/set}}" />
		<cfset expected = "This sentence should be showing." />
	</cffunction>

	<cffunction name="invertedSectionHiddenIfQueryNotEmpty">
		<cfset contacts = queryNew("name,phone")/>
		<cfset queryAddRow(contacts)>
		<cfset querySetCell(contacts, "name", "Jenny") />
		<cfset querySetCell(contacts, "phone", "867-5309") />
		<cfset context = {set = contacts} />
		<cfset template = "{{##set}}This sentence should be showing.{{/set}}{{^set}}This sentence should not.{{/set}}" />
		<cfset expected = "This sentence should be showing." />
	</cffunction>

	<cffunction name="invertedSectionHiddenIfArrayNotEmpty">
		<cfset context =  {set = [1]}  />
		<cfset template = "{{##set}}This sentence should be showing.{{/set}}{{^set}}This sentence should not.{{/set}}" />
		<cfset expected = "This sentence should be showing." />
	</cffunction>

	<cffunction name="dotNotation">
		<cfset context =  {}  />
		<cfset context["value"] = "root" />
		<cfset context["level1"] = {} />
		<cfset context["level1"]["value"] = "level 1" />
		<cfset context["level1"]["level2"] = {} />
		<cfset context["level1"]["level2"]["value"] = "level 2" />

		<cfset template = "{{value}}|{{level1.value}}|{{level1.level2.value}}|{{notExist}}|{{level1.notExists}}|{{levelX.levelY}}" />
		<cfset expected = "root|level 1|level 2|||" />
	</cffunction>

	<cffunction name="whitespaceHeadAndTail">
    <cfset context = { thing = 'world'} />

		<cfset template = "#chr(32)##chr(9)##chr(32)#{{thing}}#chr(32)##chr(9)##chr(32)#" />
		<cfset expected = "#chr(32)##chr(9)##chr(32)#world#chr(32)##chr(9)##chr(32)#" />
	</cffunction>

	<cffunction name="whitespaceEmptyLinesInHeadAndTail">
    <cfset context = { thing = 'world'} />

		<cfset template = "#chr(10)##chr(32)##chr(9)##chr(32)#{{thing}}#chr(32)##chr(9)##chr(32)##chr(10)#" />
		<cfset expected = "#chr(32)##chr(9)##chr(32)#world#chr(32)##chr(9)##chr(32)#" />
	</cffunction>

	<cffunction name="whitespaceEmptyLinesWithCarriageReturnInHeadAndTail">
    <cfset context = { thing = 'world'} />

		<cfset template = "#chr(13)##chr(10)##chr(32)##chr(9)##chr(32)#{{thing}}#chr(32)##chr(9)##chr(32)##chr(13)##chr(10)#" />
		<cfset expected = "#chr(32)##chr(9)##chr(32)#world#chr(32)##chr(9)##chr(32)#" />
	</cffunction>

	<cffunction name="whiteSpaceManagement">
		<cfscript>
			context = {
				  name="Dan"
				, value=1000
				, taxValue=600
				, in_ca=true
				, html="<b>some html</b>"
			};

			context.list = [];
			context.list[1] = {item="First note"};
			context.list[2] = {item="Second note"};
			context.list[3] = {item="Third note"};
			context.list[4] = {item="Etc, etc, etc."};

			template = trim('
Hello "{{name}}"
You have just won ${{value}}!

{{##in_ca}}
Well, ${{taxValue}}, after taxes.
{{/in_ca}}

I did{{^in_ca}} <strong><em>not</em></strong>{{/in_ca}} calculate taxes.

Here is some HTML: {{html}}
Here is some unescaped HTML: {{{html}}}

Here are the history notes:

{{##list}}
  * {{item}}
{{/list}}
			');

			expected = trim('
Hello "Dan"
You have just won $1000!

Well, $600, after taxes.

I did calculate taxes.

Here is some HTML: &lt;b&gt;some html&lt;/b&gt;
Here is some unescaped HTML: <b>some html</b>

Here are the history notes:

  * First note
  * Second note
  * Third note
  * Etc, etc, etc.
			');
		</cfscript>
	</cffunction>

	<cffunction name="whiteSpaceManagementWithFalseBlocks">
		<cfscript>
			context = {
				  name="Dan"
				, value=1000
				, taxValue=600
				, in_ca=false
				, html="<b>some html</b>"
			};

			context.list = [];
			context.list[1] = {item="First note"};
			context.list[2] = {item="Second note"};
			context.list[3] = {item="Third note"};
			context.list[4] = {item="Etc, etc, etc."};

			template = trim('
Hello "{{name}}"
You have just won ${{value}}!

{{##in_ca}}
Well, ${{taxValue}}, after taxes.
{{/in_ca}}

I did{{^in_ca}} <strong><em>not</em></strong>{{/in_ca}} calculate taxes.

Here is some HTML: {{html}}
Here is some unescaped HTML: {{{html}}}

Here are the history notes:

{{##list}}
  * {{item}}
{{/list}}
			');

			expected = trim('
Hello "Dan"
You have just won $1000!

I did <strong><em>not</em></strong> calculate taxes.

Here is some HTML: &lt;b&gt;some html&lt;/b&gt;
Here is some unescaped HTML: <b>some html</b>

Here are the history notes:

  * First note
  * Second note
  * Third note
  * Etc, etc, etc.
			');
		</cfscript>
	</cffunction>

	<cffunction name="whiteSpaceManagementWithElseIffy">
		<cfscript>
			context = {
				  name="Dan"
				, value=1000
				, taxValue=600
				, in_ca=false
				, html="<b>some html</b>"
			};

			template = trim('
Hello "{{name}}"
You have just won ${{value}}!

{{##in_ca}}
Well, ${{taxValue}}, after taxes.
{{/in_ca}}
{{^in_ca}}
No new taxes!
{{/in_ca}}

I did{{^in_ca}} <strong><em>not</em></strong>{{/in_ca}} calculate taxes.
			');

			expected = trim('
Hello "Dan"
You have just won $1000!

No new taxes!

I did <strong><em>not</em></strong> calculate taxes.
			');
		</cfscript>
	</cffunction>

	<cffunction name="whiteSpaceManagementWithEmptyElseIffy">
		<cfscript>
			context = {
				  name="Dan"
				, value=1000
				, taxValue=600
				, in_ca=false
				, html="<b>some html</b>"
			};

			template = trim('
Hello "{{name}}"
You have just won ${{value}}!

{{##in_ca}}
Well, ${{taxValue}}, after taxes.
{{/in_ca}}
{{^in_ca}}
{{/in_ca}}

I did{{^in_ca}} <strong><em>not</em></strong>{{/in_ca}} calculate taxes.
			');

			expected = trim('
Hello "Dan"
You have just won $1000!

I did <strong><em>not</em></strong> calculate taxes.
			');
		</cfscript>
	</cffunction>

	<cffunction name="whiteSpaceManagementWithEmptyValue">
		<cfscript>
			context = {
				  empty_value=""
			};

			template = trim('
First line!

{{empty_value}}

Last line!
			');

			expected = trim('
First line!



Last line!
			');
		</cfscript>
	</cffunction>

	<cffunction name="whiteSpaceManagementWithNonEmptyValue">
		<cfscript>
			context = {
				  not_empty_value="here!"
			};

			template = trim('
First line!

{{not_empty_value}}

Last line!
			');

			expected = trim('
First line!

here!

Last line!
			');
		</cfscript>
	</cffunction>

	<cffunction name="multilineComments">
		<cfscript>
	    context = { thing = 'world'};

			template = trim('
Hello {{!inline comment should only produce one space}} {{thing}}!
{{!
	a multi
	line comment
}}
Bye{{!inline comment should only produce one space}} {{thing}}!
No{{! break }}space!
			');

			expected = trim('
Hello world!
Bye world!
Nospace!
			');
		</cfscript>
	</cffunction>

	<cffunction name="complexTemplate">
		<cfset var Helper = createObject("component", "tests.Helper") />
		<cfset context = Helper.getComplexContext() />
		<cfset template = Helper.getComplexTemplate() />
		<cfset expected = trim('
Please do not respond to this message. This is for information purposes only.

FOR SECURITY PURPOSES, PLEASE DO NOT FORWARD THIS EMAIL TO OTHERS.

A new ticket has been entered and assigned to Tommy.

Ticket No: 1234
Priority: Medium
Name: Jenny
Subject: E-mail not working
Phone Number: 867-5309

Description:
Here''s a description

with some

new lines

Public Note:
User needs to update their software to the latest version.

Thank you,
Support Team
		') />
	</cffunction>

	<cffunction name="complexTemplateRev2">
		<cfset var Helper = createObject("component", "tests.Helper") />
		<cfset context = Helper.getComplexContext() />

		<!---// change context //--->
		<cfset context.Settings.EnableEmailUpdates = false />
		<cfset context.Settings.ShowPrivateNote = true />
		<cfset context.Assignee.Name = "" />
		<cfset context.Customer.Room = "100" />
		<cfset context.Customer.Department = "Human Resources" />
		<cfset context.Ticket.Note = "" />
		<cfset context.Ticket.Description = "" />

		<cfset template = Helper.getComplexTemplate() />
		<cfset expected = trim('
FOR SECURITY PURPOSES, PLEASE DO NOT FORWARD THIS EMAIL TO OTHERS.

A new ticket has been entered and is UNASSIGNED.

Ticket No: 1234
Priority: Medium
Name: Jenny
Subject: E-mail not working
Phone Number: 867-5309
Room: 100
Department: Human Resources

Description:


Private Note:
Client doesn''t want to listen to instructions

Thank you,
Support Team
		') />
	</cffunction>

</cfcomponent>
