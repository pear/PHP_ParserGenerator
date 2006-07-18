<?php
/* Driver template for the LEMON parser generator.
** The author disclaims copyright to this source code.
*/
/** The following structure represents a single element of the
 * parser's stack.  Information stored includes:
 *
 *   +  The state number for the parser at this level of the stack.
 *
 *   +  The value of the token stored at this level of the stack.
 *      (In other words, the "major" token.)
 *
 *   +  The semantic value stored at this level of the stack.  This is
 *      the information used by the action routines in the grammar.
 *      It is sometimes called the "minor" token.
 */
class PHPyyStackEntry
{
    public $stateno;       /* The state-number */
    public $major;         /* The major token value.  This is the code
                     ** number for the token at this stack level */
    public $minor; /* The user-supplied minor token value.  This
                     ** is the value of the token  */
};

/**
 * The state of the parser is completely contained in an instance of
 * the following structure
 */
class PHPyyParser
{
/* First off, code is include which follows the "include" declaration
** in the input file. */
#line 3 "PHP.y"

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
#line 98 "0"

/* Next is all token values, in a form suitable for use by makeheaders.
** This section will be null unless lemon is run with the -m switch.
*/
/* 
** These constants (all generated automatically by the parser generator)
** specify the various kinds of tokens (terminals) that the parser
** understands. 
**
** Each symbol here is a terminal symbol in the grammar.
*/
    const T_INCLUDE                      =  1;
    const T_INCLUDE_ONCE                 =  2;
    const T_EVAL                         =  3;
    const T_REQUIRE                      =  4;
    const T_REQUIRE_ONCE                 =  5;
    const COMMA                          =  6;
    const T_LOGICAL_OR                   =  7;
    const T_LOGICAL_XOR                  =  8;
    const T_LOGICAL_AND                  =  9;
    const T_PRINT                        = 10;
    const EQUALS                         = 11;
    const T_PLUS_EQUAL                   = 12;
    const T_MINUS_EQUAL                  = 13;
    const T_MUL_EQUAL                    = 14;
    const T_DIV_EQUAL                    = 15;
    const T_CONCAT_EQUAL                 = 16;
    const T_MOD_EQUAL                    = 17;
    const T_AND_EQUAL                    = 18;
    const T_OR_EQUAL                     = 19;
    const T_XOR_EQUAL                    = 20;
    const T_SL_EQUAL                     = 21;
    const T_SR_EQUAL                     = 22;
    const QUESTION                       = 23;
    const COLON                          = 24;
    const T_BOOLEAN_OR                   = 25;
    const T_BOOLEAN_AND                  = 26;
    const BAR                            = 27;
    const CARAT                          = 28;
    const AMPERSAND                      = 29;
    const T_IS_EQUAL                     = 30;
    const T_IS_NOT_EQUAL                 = 31;
    const T_IS_IDENTICAL                 = 32;
    const T_IS_NOT_IDENTICAL             = 33;
    const LESSTHAN                       = 34;
    const T_IS_SMALLER_OR_EQUAL          = 35;
    const GREATERTHAN                    = 36;
    const T_IS_GREATER_OR_EQUAL          = 37;
    const T_SL                           = 38;
    const T_SR                           = 39;
    const PLUS                           = 40;
    const MINUS                          = 41;
    const DOT                            = 42;
    const TIMES                          = 43;
    const DIVIDE                         = 44;
    const PERCENT                        = 45;
    const EXCLAM                         = 46;
    const T_INSTANCEOF                   = 47;
    const TILDE                          = 48;
    const T_INC                          = 49;
    const T_DEC                          = 50;
    const T_INT_CAST                     = 51;
    const T_DOUBLE_CAST                  = 52;
    const T_STRING_CAST                  = 53;
    const T_ARRAY_CAST                   = 54;
    const T_OBJECT_CAST                  = 55;
    const T_BOOL_CAST                    = 56;
    const T_UNSET_CAST                   = 57;
    const AT                             = 58;
    const LBRACKET                       = 59;
    const T_NEW                          = 60;
    const T_CLONE                        = 61;
    const T_ELSEIF                       = 62;
    const T_ELSE                         = 63;
    const T_ENDIF                        = 64;
    const T_STATIC                       = 65;
    const T_ABSTRACT                     = 66;
    const T_FINAL                        = 67;
    const T_PRIVATE                      = 68;
    const T_PROTECTED                    = 69;
    const T_PUBLIC                       = 70;
    const T_HALT_COMPILER                = 71;
    const LPAREN                         = 72;
    const RPAREN                         = 73;
    const SEMI                           = 74;
    const LCURLY                         = 75;
    const RCURLY                         = 76;
    const T_IF                           = 77;
    const T_WHILE                        = 78;
    const T_DO                           = 79;
    const T_FOR                          = 80;
    const T_SWITCH                       = 81;
    const T_BREAK                        = 82;
    const T_CONTINUE                     = 83;
    const T_RETURN                       = 84;
    const T_GLOBAL                       = 85;
    const T_ECHO                         = 86;
    const T_INLINE_HTML                  = 87;
    const T_USE                          = 88;
    const T_UNSET                        = 89;
    const T_FOREACH                      = 90;
    const T_AS                           = 91;
    const T_DECLARE                      = 92;
    const T_TRY                          = 93;
    const T_CATCH                        = 94;
    const T_VARIABLE                     = 95;
    const T_THROW                        = 96;
    const T_FUNCTION                     = 97;
    const T_STRING                       = 98;
    const T_CLASS                        = 99;
    const T_EXTENDS                      = 100;
    const T_INTERFACE                    = 101;
    const T_IMPLEMENTS                   = 102;
    const T_LIST                         = 103;
    const T_EXIT                         = 104;
    const T_ARRAY                        = 105;
    const BACKQUOTE                      = 106;
    const T_LNUMBER                      = 107;
    const T_DNUMBER                      = 108;
    const T_CONSTANT_ENCAPSED_STRING     = 109;
    const T_LINE                         = 110;
    const T_FILE                         = 111;
    const T_CLASS_C                      = 112;
    const T_METHOD_C                     = 113;
    const T_FUNC_C                       = 114;
    const T_DOUBLE_ARROW                 = 115;
    const T_PAAMAYIM_NEKUDOTAYIM         = 116;
    const T_ENDFOR                       = 117;
    const T_ENDFOREACH                   = 118;
    const T_ENDDECLARE                   = 119;
    const T_ENDSWITCH                    = 120;
    const T_CASE                         = 121;
    const T_DEFAULT                      = 122;
    const T_ENDWHILE                     = 123;
    const DOLLAR                         = 124;
    const T_VAR                          = 125;
    const T_CONST                        = 126;
    const T_OBJECT_OPERATOR              = 127;
    const RBRACKET                       = 128;
    const T_NUM_STRING                   = 129;
    const T_ENCAPSED_AND_WHITESPACE      = 130;
    const T_CHARACTER                    = 131;
    const T_BAD_CHARACTER                = 132;
    const T_DOLLAR_OPEN_CURLY_BRACES     = 133;
    const T_STRING_VARNAME               = 134;
    const T_CURLY_OPEN                   = 135;
    const T_ISSET                        = 136;
    const T_EMPTY                        = 137;
    const DOUBLEQUOTE                    = 138;
    const SINGLEQUOTE                    = 139;
    const T_START_HEREDOC                = 140;
    const T_END_HEREDOC                  = 141;
    const YY_NO_ACTION = 1040;
    const YY_ACCEPT_ACTION = 1039;
    const YY_ERROR_ACTION = 1038;

/* Next are that tables used to determine what action to take based on the
** current state and lookahead token.  These tables are used to implement
** functions that take a state number and lookahead value and return an
** action integer.  
**
** Suppose the action integer is N.  Then the action is determined as
** follows
**
**   0 <= N < YYNSTATE                  Shift N.  That is, push the lookahead
**                                      token onto the stack and goto state N.
**
**   YYNSTATE <= N < YYNSTATE+YYNRULE   Reduce by rule N-YYNSTATE.
**
**   N == YYNSTATE+YYNRULE              A syntax error has occurred.
**
**   N == YYNSTATE+YYNRULE+1            The parser accepts its input.
**
**   N == YYNSTATE+YYNRULE+2            No such action.  Denotes unused
**                                      slots in the yy_action[] table.
**
** The action table is constructed as a single large table named yy_action[].
** Given state S and lookahead X, the action is computed as
**
**      yy_action[ yy_shift_ofst[S] + X ]
**
** If the index value yy_shift_ofst[S]+X is out of range or if the value
** yy_lookahead[yy_shift_ofst[S]+X] is not equal to X or if yy_shift_ofst[S]
** is equal to YY_SHIFT_USE_DFLT, it means that the action is not in the table
** and that yy_default[S] should be used instead.  
**
** The formula above is for computing the action when the lookahead is
** a terminal symbol.  If the lookahead is a non-terminal (as occurs after
** a reduce action) then the yy_reduce_ofst[] array is used in place of
** the yy_shift_ofst[] array and YY_REDUCE_USE_DFLT is used in place of
** YY_SHIFT_USE_DFLT.
**
** The following are the tables generated in this section:
**
**  yy_action[]        A single table containing all actions.
**  yy_lookahead[]     A table containing the lookahead for each entry in
**                     yy_action.  Used to detect hash collisions.
**  yy_shift_ofst[]    For each state, the offset into yy_action for
**                     shifting terminals.
**  yy_reduce_ofst[]   For each state, the offset into yy_action for
**                     shifting non-terminals after a reduce.
**  yy_default[]       Default action for each state.
*/
