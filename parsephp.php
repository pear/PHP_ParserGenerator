<?php
require_once '/development/PHP_ParserGenerator/PHP_Parser.php';
require_once '/development/PHP_ParserGenerator/Tokenizer.php';
$a = new PHP_Parser_Tokenizer('<?php
function test()
{
    throw new Exception("boo");
}
?>');
$b = new PHPyyParser;
$b->printTrace();
while ($a->advance()) {
    $b->doParse($a->token, $a->getValue(), $a);
}
$b->doParse(0, 0);
