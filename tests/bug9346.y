%name ProtoParser_
%declare_class {class ProtoParser}
%syntax_error { echo "SYNTAX ERROR"; }

proto ::= returns NAME PAR_OPEN PAR_CLOSE.

returns ::= RESOURCE NAME.
%code {
$tokens = array(
array("token"=>ProtoParser::RESOURCE,
"value"=>"resource"),
array("token"=>ProtoParser::NAME,    
"value"=>"some_res"),
array("token"=>ProtoParser::NAME,    
"value"=>"some_function"),
array("token"=>ProtoParser::PAR_OPEN,
"value"=>"("),
array("token"=>ProtoParser::PAR_CLOSE,
"value"=>")"),
);

$parser = new ProtoParser();
foreach ($tokens as $token) {
    $parser->doParse($token["token"],
$token["value"]);
}
$parser->doParse(0, 0);}