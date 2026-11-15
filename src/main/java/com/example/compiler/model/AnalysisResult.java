package com.example.compiler.model;

import java.util.List;

public class AnalysisResult {

    private final List<TokenInfo> tokens;
    private final String parseTree;
    private final List<String> errors;

    public AnalysisResult(List<TokenInfo> tokens, String parseTree, List<String> errors) {
        this.tokens = List.copyOf(tokens);
        this.parseTree = parseTree;
        this.errors = List.copyOf(errors);
    }

    public List<TokenInfo> getTokens() {
        return tokens;
    }

    public String getParseTree() {
        return parseTree;
    }

    public List<String> getErrors() {
        return errors;
    }

    public boolean hasErrors() {
        return !errors.isEmpty();
    }
}
