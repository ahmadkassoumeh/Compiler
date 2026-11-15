package com.example.compiler.controller;

import com.example.compiler.model.AnalysisResult;
import com.example.compiler.service.AnalyzerService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class AnalyzerController {

    private final AnalyzerService analyzerService;

    public AnalyzerController(AnalyzerService analyzerService) {
        this.analyzerService = analyzerService;
    }

    @GetMapping("/")
    public String home(Model model) {
        model.addAttribute("language", "html");
        model.addAttribute("source", "<div th:if=\"${showProduct}\">\n"
                + "  <h1 th:text=\"${productName}\">Product</h1>\n"
                + "  <img src=\"/images/product.png\" alt=\"Product\">\n"
                + "</div>");
        return "index";
    }

    @PostMapping("/analyze")
    public String analyze(@RequestParam("language") String language,
                          @RequestParam("source") String source,
                          Model model) {
        AnalysisResult result = analyzerService.analyze(language, source);
        model.addAttribute("language", language);
        model.addAttribute("source", source);
        model.addAttribute("result", result);
        return "index";
    }
}
