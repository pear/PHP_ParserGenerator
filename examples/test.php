<?php
require_once 'PHP/ParserGenerator.php';
$a = new PHP_ParserGenerator;
$_SERVER['argv'] = array('lemon', '-s', '/development/lemon/PHP_Parser.y');
//$_SERVER['argv'] = array('lemon', '-s', '/development/File_ChessPGN/ChessPGN/Parser.y');
$a->main();