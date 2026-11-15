# إضافة تحليل Java

أضفنا خيار Java في قائمة `Language to analyze`.

التدفق هو:

1. صفحة `index.html` ترسل القيمة `java` مع النص في طلب POST إلى `/analyze`.
2. `AnalyzerController` يستقبل `language` و`source` ويمررهما إلى `AnalyzerService`.
3. `AnalyzerService.analyze(...)` يختار `analyzeJava(source)` عندما تكون اللغة `java`.
4. `JavaLexer` يحوّل النص إلى Tokens.
5. `JavaParser.compilationUnit()` يبني Parse Tree وفق `JavaParser.g4`.
6. الخدمة ترسل قائمة Tokens وشجرة Parse Tree والأخطاء إلى Thymeleaf لعرضها.

## مثال اختبار

```java
package com.example.demo;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class ProductController {
    @GetMapping("/products")
    public String listProducts(Model model) {
        model.addAttribute("pageTitle", "Products");
        return "products/list";
    }
}
```

في هذه المرحلة نحصل على التحليل اللفظي والنحوي. استخراج العلاقات فعلياً بين `@GetMapping` و`Model.addAttribute(...)` واسم القالب المرجع من `return` سيكون مرحلة تالية تعتمد على AST/Visitor، ثم تُربط نتائجها بقوالب Thymeleaf.
