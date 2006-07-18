%name PHP_LexerGenerator_Parser
%declare_class {class PHP_LexerGenerator_Parser}
%include {
/* ?><?php {//*/
/**
 * PHP_LexerGenerator, a php 5 lexer generator.
 * 
 * This lexer generator translates a file in a format similar to
 * re2c ({@link http://re2c.org}) and translates it into a PHP 5-based lexer
 *
 * PHP version 5
 *
 * LICENSE: This source file is subject to version 3.01 of the PHP license
 * that is available through the world-wide-web at the following URI:
 * http://www.php.net/license/3_01.txt.  If you did not receive a copy of
 * the PHP License and are unable to obtain it through the web, please
 * send a note to license@php.net so we can mail you a copy immediately.
 *
 * @category   php
 * @package    PHP_LexerGenerator
 * @author     Gregory Beaver <cellog@php.net>
 * @copyright  2006 Gregory Beaver
 * @license    http://www.php.net/license/3_01.txt  PHP License 3.01
 * @version    CVS: $Id$
 * @since      File available since Release 0.1.0
 */
/**
 * Token parser for plex files.
 * 
 * This parser converts tokens pulled from {@link PHP_LexerGenerator_Lexer}
 * into abstract patterns and rules, then creates the output file
 * @package    PHP_LexerGenerator
 * @author     Gregory Beaver <cellog@php.net>
 * @copyright  2006 Gregory Beaver
 * @license    http://www.php.net/license/3_01.txt  PHP License 3.01
 * @version    @package_version@
 * @since      Class available since Release 0.1.0
 */
}
%syntax_error {
    echo "Syntax Error on line " . $this->lex->line . ": token '" . 
        $this->lex->value . "' while parsing rule:";
    foreach ($this->yystack as $entry) {
        echo $this->tokenName($entry->major) . ' ';
    }
    foreach ($this->yy_get_expected_tokens($yymajor) as $token) {
        $expect[] = self::$yyTokenName[$token];
    }
    throw new Exception('Unexpected ' . $this->tokenName($yymajor) . '(' . $TOKEN
        . '), expected one of: ' . implode(',', $expect));
}
%include_class {
    private $patterns;
    private $out;
    private $lex;
    private $input;
    private $counter;
    private $token;
    private $value;
    private $line;

    public $transTable = array(
        1 => self::PHPCODE,
        2 => self::COMMENTSTART,
        3 => self::COMMENTEND,
        4 => self::QUOTE,
        5 => self::PATTERN,
        6 => self::CODE,
        7 => self::SUBPATTERN,
        8 => self::PI,
    );

    function __construct($outfile, $lex)
    {
        $this->out = fopen($outfile, 'wb');
        if (!$this->out) {
            throw new Exception('unable to open lexer output file "' . $outfile . '"');
        }
        $this->lex = $lex;
    }

    function outputRules($rules, $statename)
    {
        static $ruleindex = 1;
        $patterns = array();
        $pattern = '/';
        foreach ($rules as $rule) {
            $patterns[] = '^(' . $rule['pattern'] . ')';
        }
        $pattern .= implode('|', $patterns);
        $pattern .= '/';
        if ($statename) {
            fwrite($this->out, '
    const ' . $statename . ' = ' . $ruleindex . ';
');
        }
        fwrite($this->out, '
    function yylex' . $ruleindex . '()
    {
        if (' . $this->counter . ' >= strlen(' . $this->input . ')) {
            return false; // end of input
        }
        ');
        fwrite($this->out, '    $yy_global_pattern = "' .
            $pattern . '";' . "\n");
        fwrite($this->out, '
        do {
            if (preg_match($yy_global_pattern, substr(' . $this->input . ', ' .
             $this->counter .
                    '), $yymatches)) {
                $yymatches = array_filter($yymatches, \'strlen\'); // remove empty sub-patterns
                if (!count($yymatches)) {
                    throw new Exception(\'Error: lexing failed because a rule matched\' .
                        \'an empty string\');
                }
                next($yymatches); // skip global match
                ' . $this->token . ' = key($yymatches); // token number
                ' . $this->value . ' = current($yymatches); // token value
                $r = $this->{\'yy_r' . $ruleindex . '_\' . ' . $this->token . '}();
                if ($r === null) {
                    ' . $this->counter . ' += strlen($this->value);
                    ' . $this->line . ' += substr_count("\n", ' . $this->value . ');
                    // accept this token
                    return true;
                } elseif ($r === true) {
                    // we have changed state
                    // process this token in the new state
                    return $this->yylex();
                } elseif ($r === false) {
                    ' . $this->counter . ' += strlen($this->value);
                    ' . $this->line . ' += substr_count("\n", ' . $this->value . ');
                    if (' . $this->counter . ' >= strlen(' . $this->input . ')) {
                        return false; // end of input
                    }
                    // skip this token
                    continue;
                } else {');
        fwrite($this->out, '                    $yy_yymore_patterns = array(' . "\n");
        for($i = 0; count($patterns); $i++) {
            unset($patterns[$i]);
            fwrite($this->out, '        ' . ($i + 1) . ' => "' .
                implode('|', $patterns) . "\",\n");
        }
        fwrite($this->out, '    );' . "\n");
        fwrite($this->out, '
                    // yymore is needed
                    do {
                        if (!strlen($yy_yymore_patterns[' . $this->token . '])) {
                            throw new Exception(\'cannot do yymore for the last token\');
                        }
                        if (preg_match($yy_yymore_patterns[' . $this->token . '],
                              substr(' . $this->input . ', ' . $this->counter . '), $yymatches)) {
                            $yymatches = array_filter($yymatches, \'strlen\'); // remove empty sub-patterns
                            next($yymatches); // skip global match
                            ' . $this->token . ' = key($yymatches); // token number
                            ' . $this->value . ' = current($yymatches); // token value
                            ' . $this->line . ' = substr_count("\n", ' . $this->value . ');
                        }
                    } while ($this->{\'yy_r' . $ruleindex . '_\' . ' . $this->token . '}() !== null);
                    // accept
                    ' . $this->counter . ' += strlen($this->value);
                    ' . $this->line . ' += substr_count("\n", ' . $this->value . ');
                    return true;
                }
            } else {
                throw new Exception(\'Unexpected input at line\' . ' . $this->line . ' .
                    \': \' . ' . $this->input . '[' . $this->counter . ']);
            }
            break;
        } while (true);
    } // end function

');
        foreach ($rules as $i => $rule) {
            fwrite($this->out, '    function yy_r' . $ruleindex . '_' . ($i + 1) . '()
    {
' . $rule['code'] .
'    }
');
        }
        $ruleindex++; // for next set of rules
    }

    function error($msg)
    {
        echo 'Error on line ' . $this->lex->line . ': ' . $msg;
    }

    function _validatePattern($pattern)
    {
        if ($pattern[0] == '^') {
            $this->error('Pattern "' . $pattern .
                '" should not begin with ^, lexer may fail');
        }
        if ($pattern[strlen($pattern) - 1] == '$') {
            $this->error('Pattern "' . $pattern .
                '" should not end with $, lexer may fail');
        }
        // match ( but not \( or (?:
        $savepattern = $pattern;
        $pattern = str_replace('\\\\', '', $pattern);
        $pattern = str_replace('\\(', '', $pattern);
        if (preg_match('/\([^?][^:]|\(\?[^:]|\(\?$|\($/', $pattern)) {
            $this->error('Pattern "' . $savepattern .
                '" must not contain sub-patterns (like this), generated lexer will fail');
        }
    }
}

start ::= lexfile.

lexfile ::= declare rules(B). {
    fwrite($this->out, '
    private $_yy_state = 1;
    private $_yy_stack = array();

    function yylex()
    {
        return $this->{\'yylex\' . $this->_yy_state}();
    }

    function yypushstate($state)
    {
        array_push($this->_yy_stack, $this->_yy_state);
        $this->_yy_state = $state;
    }

    function yypopstate()
    {
        $this->_yy_state = array_pop($this->_yy_stack);
    }

    function yybegin($state)
    {
        $this->_yy_state = $state;
    }

');
    foreach (B as $rule) {
        $this->outputRules($rule['rules'], $rule['statename']);
        if ($rule['code']) {
            fwrite($this->out, $rule['code']);
        }
    }
}
lexfile ::= declare(D) PHPCODE(B) rules(C). {
    fwrite($this->out, '
    private $_yy_state = 1;
    private $_yy_stack = array();

    function yylex()
    {
        return $this->{\'yylex\' . $this->_yy_state}();
    }

    function yypushstate($state)
    {
        array_push($this->_yy_stack, $this->_yy_state);
        $this->_yy_state = $state;
    }

    function yypopstate()
    {
        $this->_yy_state = array_pop($this->_yy_stack);
    }

    function yybegin($state)
    {
        $this->_yy_state = $state;
    }

');
    if (strlen(B)) {
        fwrite($this->out, B);
    }
    foreach (C as $rule) {
        $this->outputRules($rule['rules'], $rule['statename']);
        if ($rule['code']) {
            fwrite($this->out, $rule['code']);
        }
    }
}
lexfile ::= PHPCODE(B) declare(D) rules(C). {
    if (strlen(B)) {
        fwrite($this->out, B);
    }
    fwrite($this->out, '
    private $_yy_state = 1;
    private $_yy_stack = array();

    function yylex()
    {
        return $this->{\'yylex\' . $this->_yy_state}();
    }

    function yypushstate($state)
    {
        array_push($this->_yy_stack, $this->_yy_state);
        $this->_yy_state = $state;
    }

    function yypopstate()
    {
        $this->_yy_state = array_pop($this->_yy_stack);
    }

    function yybegin($state)
    {
        $this->_yy_state = $state;
    }

');
    foreach (C as $rule) {
        $this->outputRules($rule['rules'], $rule['statename']);
        if ($rule['code']) {
            fwrite($this->out, $rule['code']);
        }
    }
}
lexfile ::= PHPCODE(A) declare(D) PHPCODE(B) rules(C). {
    if (strlen(A)) {
        fwrite($this->out, A);
    }
    fwrite($this->out, '
    private $_yy_state = 1;
    private $_yy_stack = array();

    function yylex()
    {
        return $this->{\'yylex\' . $this->_yy_state}();
    }

    function yypushstate($state)
    {
        array_push($this->_yy_stack, $this->_yy_state);
        $this->_yy_state = $state;
    }

    function yypopstate()
    {
        $this->_yy_state = array_pop($this->_yy_stack);
    }

    function yybegin($state)
    {
        $this->_yy_state = $state;
    }

');
    if (strlen(B)) {
        fwrite($this->out, B);
    }
    foreach (C as $rule) {
        $this->outputRules($rule['rules'], $rule['statename']);
        if ($rule['code']) {
            fwrite($this->out, $rule['code']);
        }
    }
}

declare(A) ::= COMMENTSTART declarations(B) COMMENTEND. {
    A = B;
    $this->patterns = B['patterns'];
}

declarations(A) ::= processing_instructions(B) pattern_declarations(C). {
    $expected = array(
        'counter' => true,
        'input' => true,
        'token' => true,
        'value' => true,
        'line' => true,
    );
    foreach (B as $pi) {
        if (isset($expected[$pi['pi']])) {
            unset($expected[$pi['pi']]);
            continue;
        }
        if (count($expected)) {
            throw new Exception('Processing Instructions "' .
                implode(', ', array_keys($expected)) . '" must be defined');
        }
    }
    $expected = array(
        'counter' => true,
        'input' => true,
        'token' => true,
        'value' => true,
        'line' => true,
    );
    foreach (B as $pi) {
        if (isset($expected[$pi['pi']])) {
            $this->{$pi['pi']} = $pi['definition'];
            continue;
        }
        $this->error('Unknown processing instruction %' . $pi['pi'] .
            ', should be one of "' . implode(', ', array_keys($expected)) . '"');
    }
    A = array('patterns' => C, 'pis' => B);
}

processing_instructions(A) ::= PI(B) SUBPATTERN(C). {
    A = array(array('pi' => B, 'definition' => C));
}
processing_instructions(A) ::= PI(B) CODE(C). {
    A = array(array('pi' => B, 'definition' => C));
}
processing_instructions(A) ::= processing_instructions(P) PI(B) SUBPATTERN(C). {
    A = P;
    A[] = array('pi' => B, 'definition' => C);
}
processing_instructions(A) ::= processing_instructions(P) PI(B) CODE(C). {
    A = P;
    A[] = array('pi' => B, 'definition' => C);
}

pattern_declarations(A) ::= PATTERN(B) subpattern(C). {
    A = array(B => C);
}
pattern_declarations(A) ::= pattern_declarations(B) PATTERN(C) subpattern(D). {
    A = B;
    if (isset(A[C])) {
        throw new Exception('Pattern "' . C . '" is already defined as "' .
            A[C] . '", cannot redefine as "' . D . '"');
    }
    A[C] = D;
}

rules(A) ::= COMMENTSTART rule(B) COMMENTEND. {
    A = array(array('rules' => B, 'code' => '', 'statename' => ''));
}
rules(A) ::= COMMENTSTART PI(P) SUBPATTERN(S) rule(B) COMMENTEND. {
    if (P != 'statename') {
        throw new Exception('Error: only %statename processing instruction ' .
            'is allowed in rule sections');
    }
    A = array(array('rules' => B, 'code' => '', 'statename' => S));
}
rules(A) ::= COMMENTSTART rule(B) COMMENTEND PHPCODE(C). {
    A = array(array('rules' => B, 'code' => C, 'statename' => ''));
}
rules(A) ::= COMMENTSTART PI(P) SUBPATTERN(S) rule(B) COMMENTEND PHPCODE(C). {
    if (P != 'statename') {
        throw new Exception('Error: only %statename processing instruction ' .
            'is allowed in rule sections');
    }
    A = array(array('rules' => B, 'code' => C, 'statename' => S));
}
rules(A) ::= rules(R) COMMENTSTART rule(B) COMMENTEND. {
    A = R;
    A[] = array('rules' => B, 'code' => '', 'statename' => '');
}
rules(A) ::= rules(R) PI(P) SUBPATTERN(S) COMMENTSTART rule(B) COMMENTEND. {
    if (P != 'statename') {
        throw new Exception('Error: only %statename processing instruction ' .
            'is allowed in rule sections');
    }
    A = R;
    A[] = array('rules' => B, 'code' => '', 'statename' => S);
}
rules(A) ::= rules(R) COMMENTSTART rule(B) COMMENTEND PHPCODE(C). {
    A = R;
    A[] = array('rules' => B, 'code' => C, 'statename' => '');
}
rules(A) ::= rules(R) COMMENTSTART PI(P) SUBPATTERN(S) rule(B) COMMENTEND PHPCODE(C). {
    if (P != 'statename') {
        throw new Exception('Error: only %statename processing instruction ' .
            'is allowed in rule sections');
    }
    A = R;
    A[] = array('rules' => B, 'code' => C, 'statename' => S);
}

rule(A) ::= rule_subpattern(B) CODE(C). {
    A = array(array('pattern' => B, 'code' => C));
}
rule(A) ::= rule(R) rule_subpattern(B) CODE(C).{
    A = R;
    A[] = array('pattern' => B, 'code' => C);
}

rule_subpattern(A) ::= QUOTE(B). {
    A = str_replace(array('\\', '"'), array('\\\\', '\\"'), preg_quote(B, '/'));
}
rule_subpattern(A) ::= SUBPATTERN(B). {
    if (!isset($this->patterns[B])) {
        $this->error('Undefined pattern "' . B . '" used in rules');
        throw new Exception('Undefined pattern "' . B . '" used in rules');
    }
    A = $this->patterns[B];
}
rule_subpattern(A) ::= rule_subpattern(B) QUOTE(C). {
    A = B . str_replace(array('\\', '"'), array('\\\\', '\\"'), preg_quote(C, '/'));
}
rule_subpattern(A) ::= rule_subpattern(B) SUBPATTERN(C). {
    if (!isset($this->patterns[C])) {
        $this->error('Undefined pattern "' . C . '" used in rules');
        throw new Exception('Undefined pattern "' . C . '" used in rules');
    }
    A = B . $this->patterns[C];
}

subpattern(A) ::= QUOTE(B). {
    A = str_replace(array('\\', '"'), array('\\\\', '\\"'), preg_quote(B, '/'));
}
subpattern(A) ::= SUBPATTERN(B). {
    A = str_replace(array('/', '\\', '"'), array('\\/', '\\\\', '\"'), B);
    A = preg_replace('/\\\\([0-7]{1,3})/', '\\\1', A);
    A = preg_replace('/\\\\(x[0-9A-Fa-f]{1,2})/', '\\x\1', A);
    A = str_replace(array('\\\\t', '\\\\n', '\\\\r'), array('\\t', '\\n', '\\r'), A);
    $this->_validatePattern(A);
}
subpattern(A) ::= subpattern(B) QUOTE(C). {
    A = B . str_replace(array('\\', '"'), array('\\\\', '\\"'), preg_quote(C, '/'));
}
subpattern(A) ::= subpattern(B) SUBPATTERN(C). {
    A = str_replace(array('/', '\\', '"'), array('\\/', '\\\\', '\\"'), C);
    A = preg_replace('/\\\\([0-7]{1,3})/', '\\\1', A);
    A = preg_replace('/\\\\(x[0-9A-Fa-f]{1,2})/', '\\x\1', A);
    A = str_replace(array('\\\\t', '\\\\n', '\\\\r'), array('\\t', '\\n', '\\r'), A);
    A = B . A;
    $this->_validatePattern(A);
}