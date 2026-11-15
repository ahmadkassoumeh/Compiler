package com.example.compiler.service;

import com.example.compiler.model.AnalysisResult;
import com.example.compiler.model.TokenInfo;
import com.example.compiler.parser.css.CssLexer;
import com.example.compiler.parser.css.CssParser;
import com.example.compiler.parser.html.HtmlLexer;
import com.example.compiler.parser.html.HtmlParser;
import com.example.compiler.parser.java.JavaLexer;
import com.example.compiler.parser.java.JavaParser;
import java.util.ArrayList;
import java.util.Locale;
import java.util.Set;
import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.Vocabulary;
import org.antlr.v4.runtime.tree.ParseTree;
import org.springframework.stereotype.Service;

@Service
public class AnalyzerService {

    // A deliberately finite HTML element set supported by this project.
    // An element outside this set is reported as unsupported by OUR grammar,
    // not necessarily invalid according to every HTML extension or browser.
    private static final Set<String> SUPPORTED_HTML_TAGS = Set.of(
            "html", "head", "body", "title", "meta", "link", "style", "script",
            "div", "span", "p", "h1", "h2", "h3", "h4", "h5", "h6",
            "a", "img", "br", "hr", "strong", "em", "small", "b", "i",
            "ul", "ol", "li", "dl", "dt", "dd",
            "form", "label", "input", "button", "select", "option", "textarea",
            "table", "thead", "tbody", "tfoot", "tr", "th", "td", "caption",
            "header", "footer", "nav", "main", "section", "article", "aside",
            "area", "base", "col", "embed", "param", "source", "track", "wbr"
    );

    private static final Set<String> VOID_HTML_TAGS = Set.of(
            "area", "base", "br", "col", "embed", "hr", "img",
            "input", "link", "meta", "param", "source", "track", "wbr"
    );

    public AnalysisResult analyze(String language, String source) {
        if ("css".equalsIgnoreCase(language)) {
            return analyzeCss(source);
        }
        if ("java".equalsIgnoreCase(language)) {
            return analyzeJava(source);
        }
        return analyzeHtml(source);
    }

    private AnalysisResult analyzeHtml(String source) {
        var errors = new ArrayList<String>();
        HtmlLexer lexer = new HtmlLexer(CharStreams.fromString(source));
        lexer.removeErrorListeners();
        lexer.addErrorListener(new CollectingErrorListener(errors));

        CommonTokenStream tokenStream = new CommonTokenStream(lexer);
        tokenStream.fill();
        var tokenInfo = toTokenInfo(tokenStream.getTokens(), lexer.getVocabulary());
        tokenStream.seek(0);

        HtmlParser parser = new HtmlParser(tokenStream);
        parser.removeErrorListeners();
        parser.addErrorListener(new CollectingErrorListener(errors));
        HtmlParser.DocumentContext tree = parser.document();

        // These checks are semantic/structural validation on top of syntax parsing.
        validateHtmlElements(tree, errors);

        return new AnalysisResult(tokenInfo, tree.toStringTree(parser), errors);
    }

    private void validateHtmlElements(ParseTree tree, java.util.List<String> errors) {
        if (tree instanceof HtmlParser.VoidElementContext element) {
            String name = element.VOID_TAG().getText().toLowerCase(Locale.ROOT);
            checkSupportedTag(name, element.getStart(), errors);
        } else if (tree instanceof HtmlParser.SelfClosingElementContext element) {
            String name = element.TAG_NAME().getText().toLowerCase(Locale.ROOT);
            checkSupportedTag(name, element.getStart(), errors);
        } else if (tree instanceof HtmlParser.PairedElementContext element) {
            String openingName = element.TAG_NAME(0).getText().toLowerCase(Locale.ROOT);
            String closingName = element.TAG_NAME(1).getText().toLowerCase(Locale.ROOT);
            checkSupportedTag(openingName, element.getStart(), errors);

            if (!openingName.equals(closingName)) {
                Token closingToken = element.TAG_NAME(1).getSymbol();
                errors.add("HTML tag mismatch at line " + closingToken.getLine()
                        + ": opening <" + openingName + "> but closing </" + closingName + ">.");
            }
            if (VOID_HTML_TAGS.contains(openingName)) {
                errors.add("HTML void element <" + openingName + "> must not have a closing tag.");
            }
        }

        for (int i = 0; i < tree.getChildCount(); i++) {
            validateHtmlElements(tree.getChild(i), errors);
        }
    }

    private void checkSupportedTag(String name, Token token, java.util.List<String> errors) {
        if (!SUPPORTED_HTML_TAGS.contains(name)) {
            errors.add("Unsupported HTML element <" + name + "> at line " + token.getLine()
                    + ". This analyzer currently supports a defined subset of HTML elements.");
        }
    }

    private AnalysisResult analyzeCss(String source) {
        var errors = new ArrayList<String>();
        CssLexer lexer = new CssLexer(CharStreams.fromString(source));
        lexer.removeErrorListeners();
        lexer.addErrorListener(new CollectingErrorListener(errors));

        CommonTokenStream tokenStream = new CommonTokenStream(lexer);
        tokenStream.fill();
        var tokenInfo = toTokenInfo(tokenStream.getTokens(), lexer.getVocabulary());
        tokenStream.seek(0);

        CssParser parser = new CssParser(tokenStream);
        parser.removeErrorListeners();
        parser.addErrorListener(new CollectingErrorListener(errors));
        String parseTree = parser.stylesheet().toStringTree(parser);

        return new AnalysisResult(tokenInfo, parseTree, errors);
    }

    private AnalysisResult analyzeJava(String source) {
        var errors = new ArrayList<String>();
        JavaLexer lexer = new JavaLexer(CharStreams.fromString(source));
        lexer.removeErrorListeners();
        lexer.addErrorListener(new CollectingErrorListener(errors));

        CommonTokenStream tokenStream = new CommonTokenStream(lexer);
        tokenStream.fill();
        var tokenInfo = toTokenInfo(tokenStream.getTokens(), lexer.getVocabulary());
        tokenStream.seek(0);

        JavaParser parser = new JavaParser(tokenStream);
        parser.removeErrorListeners();
        parser.addErrorListener(new CollectingErrorListener(errors));
        String parseTree = parser.compilationUnit().toStringTree(parser);

        return new AnalysisResult(tokenInfo, parseTree, errors);
    }

    private java.util.List<TokenInfo> toTokenInfo(java.util.List<Token> tokens, Vocabulary vocabulary) {
        var result = new ArrayList<TokenInfo>();
        for (Token token : tokens) {
            if (token.getType() == Token.EOF || token.getChannel() != Token.DEFAULT_CHANNEL) {
                continue;
            }
            String name = vocabulary.getSymbolicName(token.getType());
            if (name == null) {
                name = vocabulary.getDisplayName(token.getType());
            }
            result.add(new TokenInfo(name, token.getText(), token.getLine(), token.getCharPositionInLine()));
        }
        return result;
    }

    private static class CollectingErrorListener extends BaseErrorListener {

        private final java.util.List<String> errors;

        private CollectingErrorListener(java.util.List<String> errors) {
            this.errors = errors;
        }

        @Override
        public void syntaxError(Recognizer<?, ?> recognizer,
                                Object offendingSymbol,
                                int line,
                                int charPositionInLine,
                                String message,
                                RecognitionException exception) {
            errors.add("Line " + line + ", column " + charPositionInLine + ": " + message);
        }
    }
}
