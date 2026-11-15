parser grammar HtmlParser;

options { tokenVocab=HtmlLexer; }

@header {
package com.example.compiler.parser.html;
}

document
    : node* EOF
    ;

node
    : element
    | TEXT
    ;

element
    : OPEN_TAG VOID_TAG attribute* (TAG_SLASH_CLOSE | TAG_CLOSE)                         # voidElement
    | OPEN_TAG TAG_NAME attribute* TAG_SLASH_CLOSE                                        # selfClosingElement
    | OPEN_TAG TAG_NAME attribute* TAG_CLOSE node* OPEN_TAG TAG_SLASH TAG_NAME TAG_CLOSE # pairedElement
    ;

attribute
    : (TH_ATTRIBUTE | TAG_NAME | VOID_TAG) (TAG_EQUALS attributeValue)?
    ;

attributeValue
    : TAG_STRING
    | TAG_NAME
    | VOID_TAG
    | TH_ATTRIBUTE
    ;
