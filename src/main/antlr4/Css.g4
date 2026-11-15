grammar Css;

@header {
package com.example.compiler.parser.css;
}

stylesheet
    : (atRule | qualifiedRule)* EOF
    ;

atRule
    : AT_KEYWORD componentValue* (SEMICOLON | LBRACE (atRule | qualifiedRule | declaration)* RBRACE)
    ;

qualifiedRule
    : selectorList LBRACE declaration* RBRACE
    ;

selectorList
    : selector (COMMA selector)*
    ;

selector
    : selectorPart+
    ;

selectorPart
    : typeSelector
    | universalSelector
    | classSelector
    | idSelector
    | attributeSelector
    | pseudoSelector
    | combinator
    ;

typeSelector
    : IDENT
    ;

universalSelector
    : STAR
    ;

classSelector
    : DOT IDENT
    ;

idSelector
    : HASH
    ;

attributeSelector
    : LBRACK componentValue* RBRACK
    ;

pseudoSelector
    : COLON COLON? IDENT (LPAREN componentValue* RPAREN)?
    ;

combinator
    : GREATER
    | PLUS
    | TILDE
    ;

declaration
    : IDENT COLON componentValue+ SEMICOLON?
    ;

componentValue
    : IDENT
    | HASH
    | STRING
    | DIMENSION
    | PERCENTAGE
    | NUMBER
    | COLON
    | DOT
    | COMMA
    | SLASH
    | PLUS
    | MINUS
    | STAR
    | GREATER
    | TILDE
    | BANG
    | OTHER
    | LPAREN componentValue* RPAREN
    | LBRACK componentValue* RBRACK
    ;

COMMENT : '/*' .*? '*/' -> skip;
AT_KEYWORD : '@' [a-zA-Z_-] [a-zA-Z0-9_-]*;
HASH : '#' [a-zA-Z0-9_-]+;
STRING
    : '"' ( '\\' . | ~["\\\r\n] )* '"'
    | '\'' ( '\\' . | ~['\\\r\n] )* '\''
    ;
DIMENSION : NUMBER_CORE IDENT_START IDENT_CHAR*;
PERCENTAGE : NUMBER_CORE '%';
NUMBER : NUMBER_CORE;
IDENT : '--' IDENT_CHAR+ | '-'? IDENT_START IDENT_CHAR*;
LBRACE : '{';
RBRACE : '}';
LBRACK : '[';
RBRACK : ']';
LPAREN : '(';
RPAREN : ')';
COLON : ':';
SEMICOLON : ';';
COMMA : ',';
DOT : '.';
GREATER : '>';
PLUS : '+';
TILDE : '~';
STAR : '*';
SLASH : '/';
MINUS : '-';
BANG : '!';
WS : [ \t\r\n\f]+ -> skip;
OTHER : .;

fragment NUMBER_CORE
    : [+-]? ([0-9]+ ('.' [0-9]*)? | '.' [0-9]+) ([eE] [+-]? [0-9]+)?
    ;
fragment IDENT_START : [a-zA-Z_];
fragment IDENT_CHAR : [a-zA-Z0-9_-];
