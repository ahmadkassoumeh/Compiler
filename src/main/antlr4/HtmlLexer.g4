lexer grammar HtmlLexer;

options { caseInsensitive = true; }

@header {
package com.example.compiler.parser.html;
}

// Ignore comments and the document type declaration: neither is needed
// by the current parser subset, so ANTLR does not emit tokens for them.
COMMENT : '<!--' .*? '-->' -> skip;
DOCTYPE : '<!' .*? '>' -> skip;

// Outside a tag, the lexer reads text. After '<', it switches to TAG_MODE.
OPEN_TAG : '<' -> pushMode(TAG_MODE);
TEXT : ~[<]+;

mode TAG_MODE;

// End of a tag: return to the default mode and read text again.
TAG_SLASH_CLOSE : '/>' -> popMode;
TAG_CLOSE : '>' -> popMode;
TAG_EQUALS : '=';
TAG_SLASH : '/';

// HTML void elements are special: they do not have closing tags.
// This list is the subset explicitly recognized by this project.
VOID_TAG
    : 'area' | 'base' | 'br' | 'col' | 'embed' | 'hr' | 'img'
    | 'input' | 'link' | 'meta' | 'param' | 'source' | 'track' | 'wbr'
    ;

// Thymeleaf attributes receive their own token type.
TH_ATTRIBUTE : 'th:' NAME_START NAME_CHAR*;
TAG_NAME : NAME_START NAME_CHAR*;
TAG_STRING : '"' ~["\r\n]* '"' | '\'' ~['\r\n]* '\'';
TAG_WS : [ \t\r\n]+ -> channel(HIDDEN);
TAG_OTHER : .;

// These are fragments: helper patterns used by other lexer rules.
// caseInsensitive=true makes [a-z] cover uppercase too.
fragment NAME_START : [a-z_:];
fragment NAME_CHAR : [a-z0-9_:.-];
