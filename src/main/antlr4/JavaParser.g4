parser grammar JavaParser;

options { tokenVocab=JavaLexer; }

@header {
package com.example.compiler.parser.java;
}

// Educational Java grammar focused on ordinary classes and Spring MVC code.
// It intentionally supports a useful subset, not the complete Java language.
compilationUnit
    : packageDeclaration? importDeclaration* typeDeclaration* EOF
    ;

packageDeclaration
    : PACKAGE qualifiedName SEMI
    ;

importDeclaration
    : IMPORT STATIC? qualifiedName (DOT STAR)? SEMI
    ;

typeDeclaration
    : modifier* (classDeclaration | interfaceDeclaration)
    | SEMI
    ;

classDeclaration
    : CLASS IDENTIFIER typeParameters? (EXTENDS typeType)? (IMPLEMENTS typeList)? classBody
    ;

interfaceDeclaration
    : INTERFACE IDENTIFIER typeParameters? (EXTENDS typeList)? classBody
    ;

classBody
    : LBRACE classBodyDeclaration* RBRACE
    ;

classBodyDeclaration
    : modifier* (classDeclaration | constructorDeclaration | methodDeclaration | fieldDeclaration | SEMI)
    ;

constructorDeclaration
    : IDENTIFIER formalParameters (THROWS qualifiedName (COMMA qualifiedName)*)? block
    ;

methodDeclaration
    : typeTypeOrVoid IDENTIFIER formalParameters (THROWS qualifiedName (COMMA qualifiedName)*)? methodBody
    ;

methodBody
    : block
    | SEMI
    ;

fieldDeclaration
    : typeType variableDeclarators SEMI
    ;

variableDeclarators
    : variableDeclarator (COMMA variableDeclarator)*
    ;

variableDeclarator
    : IDENTIFIER arraySuffix* (ASSIGN variableInitializer)?
    ;

variableInitializer
    : expression
    | arrayInitializer
    ;

arrayInitializer
    : LBRACE (variableInitializer (COMMA variableInitializer)* COMMA?)? RBRACE
    ;

formalParameters
    : LPAREN (formalParameter (COMMA formalParameter)*)? RPAREN
    ;

formalParameter
    : modifier* typeType ELLIPSIS? IDENTIFIER arraySuffix*
    ;

typeTypeOrVoid
    : typeType
    | VOID
    ;

typeType
    : primitiveType typeArguments? arraySuffix*
    | qualifiedName typeArguments? arraySuffix*
    ;

primitiveType
    : BOOLEAN | BYTE | SHORT | INT | LONG | CHAR | FLOAT | DOUBLE
    ;

typeArguments
    : LESS (typeType (COMMA typeType)*)? GREATER
    ;

typeParameters
    : LESS typeParameter (COMMA typeParameter)* GREATER
    ;

typeParameter
    : IDENTIFIER (EXTENDS typeType (BIT_AND typeType)*)?
    ;

typeList
    : typeType (COMMA typeType)*
    ;

arraySuffix
    : LBRACK RBRACK
    ;

qualifiedName
    : IDENTIFIER (DOT IDENTIFIER)*
    ;

modifier
    : annotation
    | PUBLIC | PROTECTED | PRIVATE | STATIC | ABSTRACT | FINAL
    ;

annotation
    : AT qualifiedName (LPAREN (expression (COMMA expression)*)? RPAREN)?
    ;

block
    : LBRACE blockStatement* RBRACE
    ;

blockStatement
    : localVariableDeclaration SEMI
    | statement
    ;

localVariableDeclaration
    : FINAL? typeType variableDeclarators
    ;

statement
    : block
    | RETURN expression? SEMI
    | IF LPAREN expression RPAREN statement (ELSE statement)?
    | WHILE LPAREN expression RPAREN statement
    | FOR LPAREN forControl RPAREN statement
    | THROW expression SEMI
    | TRY block (CATCH LPAREN formalParameter RPAREN block)* (FINALLY block)?
    | expression SEMI
    | SEMI
    ;

forControl
    : (localVariableDeclaration | expressionList)? SEMI expression? SEMI expressionList?
    | expressionList
    ;

expressionList
    : expression (COMMA expression)*
    ;

expression
    : assignmentExpression
    ;

assignmentExpression
    : conditionalExpression (ASSIGN assignmentExpression)?
    ;

conditionalExpression
    : additiveExpression ((EQUAL | NOT_EQUAL | LESS | LESS_EQUAL | GREATER | GREATER_EQUAL | INSTANCEOF) additiveExpression)*
    ;

additiveExpression
    : multiplicativeExpression ((PLUS | MINUS | AND_AND | OR_OR | BIT_AND | BIT_OR | CARET) multiplicativeExpression)*
    ;

multiplicativeExpression
    : unaryExpression ((STAR | DIV | MOD) unaryExpression)*
    ;

unaryExpression
    : (BANG | PLUS | MINUS)? postfixExpression
    ;

postfixExpression
    : primaryExpression postfixPart*
    ;

postfixPart
    : DOT (IDENTIFIER | CLASS) typeArguments? arguments?
    | arguments
    | LBRACK expression RBRACK
    | INC
    | DEC
    ;

primaryExpression
    : literal
    | IDENTIFIER
    | THIS
    | SUPER
    | NEW typeType arguments classBody?
    | LPAREN expression RPAREN
    ;

arguments
    : LPAREN (expression (COMMA expression)*)? RPAREN
    ;

literal
    : STRING_LITERAL
    | TEXT_BLOCK
    | CHAR_LITERAL
    | NUMBER_LITERAL
    | TRUE
    | FALSE
    | NULL
    ;
