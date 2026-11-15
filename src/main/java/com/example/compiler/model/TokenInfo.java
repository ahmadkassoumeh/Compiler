package com.example.compiler.model;

public class TokenInfo {

    private final String type;
    private final String text;
    private final int line;
    private final int column;

    public TokenInfo(String type, String text, int line, int column) {
        this.type = type;
        this.text = text;
        this.line = line;
        this.column = column;
    }

    public String getType() {
        return type;
    }

    public String getText() {
        return text;
    }

    public int getLine() {
        return line;
    }

    public int getColumn() {
        return column;
    }
}
