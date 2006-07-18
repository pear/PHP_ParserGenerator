%name PHP

%include {
    static public $transTable = array();

    function __construct()
    {
        if (!count(self::$transTable)) {
            $start = 240; // start nice and low to be sure
            while (token_name($start) == 'UNKNOWN') {
                $start++;
            }
            $hash = array_flip(self::$yyTokenName);
            $map =
                array(
                    ord(',') => self::COMMA,
                    ord('=') => self::EQUALS,
                    ord('?') => self::QUESTION,
                    ord(':') => self::COLON,
                    ord('|') => self::BAR,
                    ord('^') => self::CARAT,
                    ord('&') => self::AMPERSAND,
                    ord('<') => self::LESSTHAN,
                    ord('>') => self::GREATERTHAN,
                    ord('+') => self::PLUS,
                    ord('-') => self::MINUS,
                    ord('.') => self::DOT,
                    ord('*') => self::TIMES,
                    ord('/') => self::DIVIDE,
                    ord('%') => self::PERCENT,
                    ord('!') => self::EXCLAM,
                    ord('~') => self::TILDE,
                    ord('@') => self::AT,
                    ord('[') => self::LBRACKET,
                    ord('(') => self::LPAREN,
                    ord(')') => self::RPAREN,
                    ord(';') => self::SEMI,
                    ord('{') => self::LCURLY,
                    ord('}') => self::RCURLY,
                    ord('`') => self::BACKQUOTE,
                    ord('$') => self::DOLLAR,
                    ord(']') => self::RBRACKET,
                    ord('"') => self::DOUBLEQUOTE,
                    ord("'") => self::SINGLEQUOTE,
                );
            for ($i = $start; $i < self::YYERRORSYMBOL + $start; $i++) {
                $lt = token_name($i);
                if (!isset($hash[$lt])) {
                    continue;
                }
                $lt = ($lt == 'T_ML_COMMENT') ? 'T_COMMENT' : $lt;
                $lt = ($lt == 'T_DOUBLE_COLON') ?  'T_PAAMAYIM_NEKUDOTAYIM' : $lt;
//                echo "$lt has hash? ".$hash[$lt]."\n";
//                continue;
                
                //echo "compare $lt with {$tokens[$i]}\n";
                $map[$i] = $hash[$lt];
            }
            //print_r($map);
            // set the map to false if nothing in there.
            self::$transTable = $map;
        }
    }
}

%left T_INCLUDE T_INCLUDE_ONCE T_EVAL T_REQUIRE T_REQUIRE_ONCE.
%left COMMA.
%left T_LOGICAL_OR.
%left T_LOGICAL_XOR.
%left T_LOGICAL_AND.
%right T_PRINT.
%left EQUALS T_PLUS_EQUAL T_MINUS_EQUAL T_MUL_EQUAL T_DIV_EQUAL T_CONCAT_EQUAL T_MOD_EQUAL T_AND_EQUAL T_OR_EQUAL T_XOR_EQUAL T_SL_EQUAL T_SR_EQUAL.
%left QUESTION COLON.
%left T_BOOLEAN_OR.
%left T_BOOLEAN_AND.
%left BAR.
%left CARAT.
%left AMPERSAND.
%nonassoc T_IS_EQUAL T_IS_NOT_EQUAL T_IS_IDENTICAL T_IS_NOT_IDENTICAL.
%nonassoc LESSTHAN T_IS_SMALLER_OR_EQUAL GREATERTHAN T_IS_GREATER_OR_EQUAL.
%left T_SL T_SR.
%left PLUS MINUS DOT.
%left TIMES DIVIDE PERCENT.
%right EXCLAM.
%nonassoc T_INSTANCEOF.
%right TILDE T_INC T_DEC T_INT_CAST T_DOUBLE_CAST T_STRING_CAST T_ARRAY_CAST T_OBJECT_CAST T_BOOL_CAST T_UNSET_CAST AT.
%right LBRACKET.
%nonassoc T_NEW T_CLONE.
%left T_ELSEIF.
%left T_ELSE.
%left T_ENDIF.
%right T_STATIC T_ABSTRACT T_FINAL T_PRIVATE T_PROTECTED T_PUBLIC.

start ::= top_statement_list.

top_statement_list ::= top_statement_list top_statement.
top_statement_list ::= .

top_statement ::= statement.
top_statement ::= function_declaration_statement.
top_statement ::= class_declaration_statement.
top_statement ::= T_HALT_COMPILER LPAREN RPAREN SEMI.

statement ::= unticked_statement.

unticked_statement ::= LCURLY inner_statement_list RCURLY.
unticked_statement ::= T_IF LPAREN expr RPAREN statement elseif_list else_single.
unticked_statement ::= T_IF LPAREN expr RPAREN COLON inner_statement_list new_elseif_list new_else_single T_ENDIF COLON.
unticked_statement ::= T_WHILE LPAREN expr RPAREN while_statement.
unticked_statement ::= T_DO statement T_WHILE LPAREN expr RPAREN SEMI.
unticked_statement ::= T_FOR 
			LPAREN
				for_expr
			COLON 
				for_expr
			SEMI
				for_expr
			RPAREN
			for_statement.
unticked_statement ::= T_SWITCH LPAREN expr RPAREN switch_case_list.
unticked_statement ::= T_BREAK SEMI.
unticked_statement ::= T_BREAK expr SEMI.
unticked_statement ::= T_CONTINUE SEMI.
unticked_statement ::= T_CONTINUE expr SEMI.
unticked_statement ::= T_RETURN SEMI.
unticked_statement ::= T_RETURN expr_without_variable SEMI.
unticked_statement ::= T_RETURN variable SEMI.
unticked_statement ::= T_GLOBAL global_var_list SEMI.
unticked_statement ::= T_STATIC static_var_list SEMI.
unticked_statement ::= T_ECHO echo_expr_list SEMI.
unticked_statement ::= T_INLINE_HTML.
unticked_statement ::= expr SEMI.
unticked_statement ::= T_USE use_filename SEMI.
unticked_statement ::= T_UNSET LPAREN unset_variables LPAREN SEMI.
unticked_statement ::= T_FOREACH LPAREN variable T_AS 
		foreach_variable foreach_optional_arg RPAREN
		foreach_statement.
unticked_statement ::= T_FOREACH LPAREN expr_without_variable T_AS 
		w_variable foreach_optional_arg RPAREN
		foreach_statement.
unticked_statement ::= T_DECLARE LPAREN declare_list RPAREN declare_statement.
unticked_statement ::= SEMI.
unticked_statement ::= T_TRY LCURLY inner_statement_list RCURLY
		T_CATCH LPAREN
		fully_qualified_class_name
		T_VARIABLE RPAREN
		LCURLY inner_statement_list RCURLY
		additional_catches.
unticked_statement ::= T_THROW expr SEMI.

additional_catches ::= non_empty_additional_catches.
additional_catches ::= .

non_empty_additional_catches ::= additional_catch.
non_empty_additional_catches ::= non_empty_additional_catches additional_catch.

additional_catch ::= T_CATCH LPAREN fully_qualified_class_name T_VARIABLE RPAREN LCURLY inner_statement_list RCURLY.

inner_statement_list ::= inner_statement_list inner_statement.
inner_statement_list ::= .

inner_statement ::= statement.
inner_statement ::= function_declaration_statement.
inner_statement ::= class_declaration_statement.
inner_statement ::= T_HALT_COMPILER LPAREN RPAREN SEMI.

statement ::= unticked_statement.

function_declaration_statement ::= unticked_function_declaration_statement.

class_declaration_statement ::= unticked_class_declaration_statement.

unticked_function_declaration_statement ::=
		T_FUNCTION is_reference T_STRING LPAREN parameter_list RPAREN
		LCURLY inner_statement_list RCURLY.

unticked_class_declaration_statement ::=
		class_entry_type T_STRING(C) extends_from
			implements_list
			LCURLY
				class_statement_list
			RCURLY.
unticked_class_declaration_statement ::=
		interface_entry T_STRING
			interface_extends_list
			LCURLY
				class_statement_list
			RCURLY.

class_entry_type ::= T_CLASS.
class_entry_type ::= T_ABSTRACT T_CLASS.
class_entry_type ::= T_FINAL T_CLASS.

extends_from ::= T_EXTENDS fully_qualified_class_name.
extends_from ::= .

interface_entry ::= T_INTERFACE.

interface_extends_list ::= T_EXTENDS interface_list.
interface_extends_list ::= .

implements_list ::= .
implements_list ::= T_IMPLEMENTS interface_list.

interface_list ::= fully_qualified_class_name.
interface_list ::= interface_list COMMA fully_qualified_class_name.

expr ::= r_variable.
expr ::= expr_without_variable.

expr_without_variable ::= T_LIST LPAREN assignment_list RPAREN EQUALS expr.
expr_without_variable ::= variable EQUALS expr.
expr_without_variable ::= variable EQUALS AMPERSAND variable.
expr_without_variable ::= variable EQUALS AMPERSAND T_NEW class_name_reference ctor_arguments.
expr_without_variable ::= T_NEW class_name_reference ctor_arguments.
expr_without_variable ::= T_CLONE expr.
expr_without_variable ::= variable T_PLUS_EQUAL expr.
expr_without_variable ::= variable T_MINUS_EQUAL expr.
expr_without_variable ::= variable T_MUL_EQUAL expr.
expr_without_variable ::= variable T_DIV_EQUAL expr.
expr_without_variable ::= variable T_CONCAT_EQUAL expr.
expr_without_variable ::= variable T_MOD_EQUAL expr.
expr_without_variable ::= variable T_AND_EQUAL expr.
expr_without_variable ::= variable T_OR_EQUAL expr.
expr_without_variable ::= variable T_XOR_EQUAL expr.
expr_without_variable ::= variable T_SL_EQUAL expr.
expr_without_variable ::= variable T_SR_EQUAL expr.
expr_without_variable ::= rw_variable T_INC.
expr_without_variable ::= T_INC rw_variable.
expr_without_variable ::= rw_variable T_DEC.
expr_without_variable ::= T_DEC rw_variable.
expr_without_variable ::= expr T_BOOLEAN_OR expr.
expr_without_variable ::= expr T_BOOLEAN_AND expr.
expr_without_variable ::= expr T_LOGICAL_OR expr.
expr_without_variable ::= expr T_LOGICAL_AND expr.
expr_without_variable ::= expr T_LOGICAL_XOR expr.
expr_without_variable ::= expr BAR expr.
expr_without_variable ::= expr AMPERSAND expr.
expr_without_variable ::= expr CARAT expr.
expr_without_variable ::= expr DOT expr.
expr_without_variable ::= expr PLUS expr.
expr_without_variable ::= expr MINUS expr.
expr_without_variable ::= expr TIMES expr.
expr_without_variable ::= expr DIVIDE expr.
expr_without_variable ::= expr PERCENT expr.
expr_without_variable ::= expr T_SL expr.
expr_without_variable ::= expr T_SR expr.
expr_without_variable ::= PLUS expr.
expr_without_variable ::= MINUS expr.
expr_without_variable ::= EXCLAM expr.
expr_without_variable ::= TILDE expr.
expr_without_variable ::= expr T_IS_IDENTICAL expr.
expr_without_variable ::= expr T_IS_NOT_IDENTICAL expr.
expr_without_variable ::= expr T_IS_EQUAL expr.
expr_without_variable ::= expr T_IS_NOT_EQUAL expr.
expr_without_variable ::= expr LESSTHAN expr.
expr_without_variable ::= expr T_IS_SMALLER_OR_EQUAL expr.
expr_without_variable ::= expr GREATERTHAN expr.
expr_without_variable ::= expr T_IS_GREATER_OR_EQUAL expr.
expr_without_variable ::= expr T_INSTANCEOF class_name_reference.
expr_without_variable ::= LPAREN expr RPAREN.
expr_without_variable ::= expr QUESTION
		expr COLON
		expr.
expr_without_variable ::= internal_functions_in_yacc.
expr_without_variable ::= T_INT_CAST expr.
expr_without_variable ::= T_DOUBLE_CAST expr.
expr_without_variable ::= T_STRING_CAST expr.
expr_without_variable ::= T_ARRAY_CAST expr.
expr_without_variable ::= T_OBJECT_CAST expr.
expr_without_variable ::= T_BOOL_CAST expr.
expr_without_variable ::= T_UNSET_CAST expr.
expr_without_variable ::= T_EXIT exit_expr.
expr_without_variable ::= AT expr.
expr_without_variable ::= scalar.
expr_without_variable ::= T_ARRAY LPAREN array_pair_list RPAREN.
expr_without_variable ::= BACKQUOTE encaps_list BACKQUOTE.
expr_without_variable ::= T_PRINT expr.

exit_expr ::= LPAREN RPAREN.
exit_expr ::= LPAREN expr RPAREN.
exit_expr ::= .

common_scalar ::=
		T_LNUMBER
	   |T_DNUMBER
	   |T_CONSTANT_ENCAPSED_STRING
	   |T_LINE
	   |T_FILE
	   |T_CLASS_C
	   |T_METHOD_C
	   |T_FUNC_C.

/* compile-time evaluated scalars */
static_scalar ::= common_scalar.
static_scalar ::= T_STRING.
static_scalar ::= T_ARRAY LPAREN static_array_pair_list RPAREN.
static_scalar ::= static_class_constant.

static_array_pair_list ::= non_empty_static_array_pair_list.
static_array_pair_list ::= non_empty_static_array_pair_list COMMA.
static_array_pair_list ::= .

non_empty_static_array_pair_list ::= non_empty_static_array_pair_list COMMA static_scalar T_DOUBLE_ARROW static_scalar.
non_empty_static_array_pair_list ::= non_empty_static_array_pair_list COMMA static_scalar.
non_empty_static_array_pair_list ::= static_scalar T_DOUBLE_ARROW static_scalar.
non_empty_static_array_pair_list ::= static_scalar.

static_class_constant ::= T_STRING T_PAAMAYIM_NEKUDOTAYIM T_STRING.

foreach_optional_arg ::= T_DOUBLE_ARROW foreach_variable.
foreach_optional_arg ::= .

foreach_variable ::= w_variable.
foreach_variable ::= AMPERSAND w_variable.

for_statement ::= statement.
for_statement ::= COLON inner_statement_list T_ENDFOR SEMI.

foreach_statement ::= statement.
foreach_statement ::= COLON inner_statement_list T_ENDFOREACH SEMI.


declare_statement ::= statement.
declare_statement ::= COLON inner_statement_list T_ENDDECLARE SEMI.

declare_list ::= T_STRING EQUALS static_scalar.
declare_list ::= declare_list COMMA T_STRING EQUALS static_scalar.

switch_case_list ::= LCURLY case_list RCURLY.
switch_case_list ::= LCURLY SEMI case_list RCURLY.
switch_case_list ::= COLON case_list T_ENDSWITCH SEMI.
switch_case_list ::= COLON SEMI case_list T_ENDSWITCH SEMI.

case_list ::= case_list T_CASE expr case_separator.
case_list ::= case_list T_DEFAULT case_separator inner_statement_list.
case_list ::= .

case_separator ::= COLON|SEMI.

while_statement ::= statement.
while_statement ::= COLON inner_statement_list T_ENDWHILE SEMI.

elseif_list ::= elseif_list T_ELSEIF LPAREN expr RPAREN statement.
elseif_list ::= .

new_elseif_list ::= new_elseif_list T_ELSEIF LPAREN expr RPAREN COLON inner_statement_list .
new_elseif_list ::= .

else_single ::= T_ELSE statement.
else_single ::= .

new_else_single ::= T_ELSE COLON inner_statement_list.
new_else_single ::= .

parameter_list ::= non_empty_parameter_list.
parameter_list ::= .

non_empty_parameter_list ::= optional_class_type T_VARIABLE.
non_empty_parameter_list ::= optional_class_type AMPERSAND T_VARIABLE.
non_empty_parameter_list ::= optional_class_type AMPERSAND T_VARIABLE EQUALS static_scalar.
non_empty_parameter_list ::= optional_class_type T_VARIABLE EQUALS static_scalar.
non_empty_parameter_list ::= non_empty_parameter_list COMMA optional_class_type T_VARIABLE.
non_empty_parameter_list ::= non_empty_parameter_list COMMA optional_class_type AMPERSAND T_VARIABLE.
non_empty_parameter_list ::= non_empty_parameter_list COMMA optional_class_type AMPERSAND T_VARIABLE EQUALS static_scalar.
non_empty_parameter_list ::= non_empty_parameter_list COMMA optional_class_type T_VARIABLE EQUALS static_scalar.


optional_class_type ::= T_STRING|T_ARRAY.
optional_class_type ::= .

function_call_parameter_list ::= non_empty_function_call_parameter_list.
function_call_parameter_list ::= .

non_empty_function_call_parameter_list ::= expr_without_variable.
non_empty_function_call_parameter_list ::= variable.
non_empty_function_call_parameter_list ::= AMPERSAND w_variable.
non_empty_function_call_parameter_list ::= non_empty_function_call_parameter_list COMMA expr_without_variable.
non_empty_function_call_parameter_list ::= non_empty_function_call_parameter_list COMMA variable.
non_empty_function_call_parameter_list ::= non_empty_function_call_parameter_list COMMA AMPERSAND w_variable.

global_var_list ::= global_var_list COMMA global_var.
global_var_list ::= global_var.

global_var ::= T_VARIABLE.
global_var ::= DOLLAR r_variable.
global_var ::= DOLLAR LCURLY expr RCURLY.


static_var_list ::= static_var_list COMMA T_VARIABLE.
static_var_list ::= static_var_list COMMA T_VARIABLE EQUALS static_scalar.
static_var_list ::= T_VARIABLE.
static_var_list ::= T_VARIABLE EQUALS static_scalar.

class_statement_list ::= class_statement_list class_statement.
class_statement_list ::= .

class_statement ::= variable_modifiers class_variable_declaration SEMI.
class_statement ::= class_constant_declaration SEMI.
class_statement ::= method_modifiers T_FUNCTION is_reference T_STRING LPAREN parameter_list RPAREN method_body.


method_body ::= SEMI. /* abstract method */
method_body ::= LCURLY inner_statement_list RCURLY.

variable_modifiers ::= non_empty_member_modifiers.
variable_modifiers ::= T_VAR.

method_modifiers ::= non_empty_member_modifiers.
method_modifiers ::= .

non_empty_member_modifiers ::= member_modifier.
non_empty_member_modifiers ::= non_empty_member_modifiers member_modifier.

member_modifier ::= T_PUBLIC|T_PROTECTED|T_PRIVATE|T_STATIC|T_ABSTRACT|T_FINAL.

class_variable_declaration ::= class_variable_declaration COMMA T_VARIABLE.
class_variable_declaration ::= class_variable_declaration COMMA T_VARIABLE EQUALS static_scalar.
class_variable_declaration ::= T_VARIABLE.
class_variable_declaration ::= T_VARIABLE EQUALS static_scalar.

class_constant_declaration ::= class_constant_declaration COMMA T_STRING EQUALS static_scalar.
class_constant_declaration ::= T_CONST T_STRING EQUALS static_scalar.

echo_expr_list ::= echo_expr_list COMMA expr.
echo_expr_list ::= expr.

unset_variables ::= unset_variable.
unset_variables ::= unset_variables COMMA unset_variable.

unset_variable ::= variable.

use_filename ::= T_CONSTANT_ENCAPSED_STRING.
use_filename ::= LCURLY T_CONSTANT_ENCAPSED_STRING RCURLY.

r_variable ::= variable.

w_variable ::= variable.

rw_variable ::= variable.

variable ::= base_variable_with_function_calls T_OBJECT_OPERATOR object_property method_or_not variable_properties.
variable ::= base_variable_with_function_calls.

variable_properties ::= variable_properties variable_property.
variable_properties ::= .

variable_property ::= T_OBJECT_OPERATOR object_property method_or_not.

method_or_not ::= LPAREN function_call_parameter_list RPAREN.
method_or_not ::= .

variable_without_objects ::= reference_variable.
variable_without_objects ::= simple_indirect_reference reference_variable.

static_member ::= fully_qualified_class_name T_PAAMAYIM_NEKUDOTAYIM variable_without_objects.

base_variable_with_function_calls ::= base_variable.
base_variable_with_function_calls ::= function_call.

base_variable ::= reference_variable.
base_variable ::= simple_indirect_reference reference_variable.
base_variable ::= static_member.
	
reference_variable ::= reference_variable LBRACKET dim_offset RBRACKET.
reference_variable ::= reference_variable LCURLY expr RCURLY.
reference_variable ::= compound_variable.

compound_variable ::= T_VARIABLE.
compound_variable ::= DOLLAR LCURLY expr RCURLY.

dim_offset ::= expr.
dim_offset ::= .

object_property ::= object_dim_list.
object_property ::= variable_without_objects.

object_dim_list ::= object_dim_list LBRACKET dim_offset RBRACKET.
object_dim_list ::= object_dim_list LCURLY expr RCURLY.
object_dim_list ::= variable_name .

variable_name ::= T_STRING.
variable_name ::= LCURLY expr RCURLY.

simple_indirect_reference ::= DOLLAR.
simple_indirect_reference ::= simple_indirect_reference DOLLAR.

assignment_list ::= assignment_list COMMA assignment_list_element.
assignment_list ::= assignment_list_element.

assignment_list_element ::= variable.
assignment_list_element ::= T_LIST LPAREN assignment_list RPAREN.
assignment_list_element ::= .

array_pair_list ::= non_empty_array_pair_list possible_comma.
array_pair_list ::= .

non_empty_array_pair_list ::= non_empty_array_pair_list COMMA expr T_DOUBLE_ARROW expr.
non_empty_array_pair_list ::= non_empty_array_pair_list COMMA expr.
non_empty_array_pair_list ::= expr T_DOUBLE_ARROW expr.
non_empty_array_pair_list ::= expr.
non_empty_array_pair_list ::= non_empty_array_pair_list COMMA expr T_DOUBLE_ARROW AMPERSAND w_variable.
non_empty_array_pair_list ::= non_empty_array_pair_list COMMA AMPERSAND w_variable.
non_empty_array_pair_list ::= expr T_DOUBLE_ARROW AMPERSAND w_variable.
non_empty_array_pair_list ::= AMPERSAND w_variable.

encaps_list ::= encaps_list encaps_var.
encaps_list ::= encaps_list T_STRING.
encaps_list ::= encaps_list T_NUM_STRING.
encaps_list ::= encaps_list T_ENCAPSED_AND_WHITESPACE.
encaps_list ::= encaps_list T_CHARACTER.
encaps_list ::= encaps_list T_BAD_CHARACTER.
encaps_list ::= encaps_list LBRACKET.
encaps_list ::= encaps_list RBRACKET.
encaps_list ::= encaps_list LCURLY.
encaps_list ::= encaps_list RCURLY.
encaps_list ::= encaps_list T_OBJECT_OPERATOR.
encaps_list ::= .



encaps_var ::= T_VARIABLE.
encaps_var ::= T_VARIABLE LBRACKET encaps_var_offset RBRACKET.
encaps_var ::= T_VARIABLE T_OBJECT_OPERATOR T_STRING.
encaps_var ::= T_DOLLAR_OPEN_CURLY_BRACES expr RCURLY.
encaps_var ::= T_DOLLAR_OPEN_CURLY_BRACES T_STRING_VARNAME LBRACKET expr RBRACKET RCURLY.
encaps_var ::= T_CURLY_OPEN variable RCURLY.

encaps_var_offset ::= T_STRING|T_NUM_STRING|T_VARIABLE.

internal_functions_in_yacc ::= T_ISSET LPAREN isset_variables RPAREN.
internal_functions_in_yacc ::= T_EMPTY LPAREN variable RPAREN.
internal_functions_in_yacc ::= T_INCLUDE expr.
internal_functions_in_yacc ::= T_INCLUDE_ONCE expr.
internal_functions_in_yacc ::= T_EVAL LPAREN expr RPAREN.
internal_functions_in_yacc ::= T_REQUIRE expr.
internal_functions_in_yacc ::= T_REQUIRE_ONCE expr.

isset_variables ::= variable.
isset_variables ::= isset_variables COMMA variable.

class_constant ::= fully_qualified_class_name T_PAAMAYIM_NEKUDOTAYIM T_STRING.

fully_qualified_class_name ::= T_STRING.

function_call ::= T_STRING LPAREN function_call_parameter_list RPAREN.
function_call ::= fully_qualified_class_name T_PAAMAYIM_NEKUDOTAYIM T_STRING LPAREN function_call_parameter_list RPAREN.
function_call ::= fully_qualified_class_name T_PAAMAYIM_NEKUDOTAYIM variable_without_objects LPAREN function_call_parameter_list RPAREN.
function_call ::= variable_without_objects LPAREN function_call_parameter_list RPAREN.

scalar ::= T_STRING.
scalar ::= T_STRING_VARNAME.
scalar ::= class_constant.
scalar ::= common_scalar.
scalar ::= DOUBLEQUOTE encaps_list DOUBLEQUOTE.
scalar ::= SINGLEQUOTE encaps_list SINGLEQUOTE.
scalar ::= T_START_HEREDOC encaps_list T_END_HEREDOC.

class_name_reference ::= T_STRING.
class_name_reference ::= dynamic_class_name_reference.

dynamic_class_name_reference ::= base_variable T_OBJECT_OPERATOR object_property dynamic_class_name_variable_properties.
dynamic_class_name_reference ::= base_variable.

dynamic_class_name_variable_properties ::= dynamic_class_name_variable_properties dynamic_class_name_variable_property.
dynamic_class_name_variable_properties ::= .

dynamic_class_name_variable_property ::= T_OBJECT_OPERATOR object_property.

ctor_arguments ::= LPAREN function_call_parameter_list RPAREN.
ctor_arguments ::= .

possible_comma ::= COMMA.
possible_comma ::= .

for_expr ::= non_empty_for_expr.
for_expr ::= .

non_empty_for_expr ::= non_empty_for_expr COMMA expr.
non_empty_for_expr ::= expr.

is_reference ::= AMPERSAND.
is_reference ::= .
