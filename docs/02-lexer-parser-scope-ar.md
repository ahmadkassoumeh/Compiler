# البند 2 — Lexer وParser ونطاق القواعد الحالية

## الفكرة العامة

يستقبل Lexer النص الخام ويحوّله إلى Tokens. بعد ذلك يقرأ Parser هذه الـ Tokens ويتحقق من ترتيبها وفق قواعد Grammar المكتوبة في ملفات `.g4`.

## الملفات

- `HtmlLexer.g4`: Lexer منفصل لأنه يستخدم أوضاعاً معجمية (Lexer Modes) للانتقال بين النص خارج الوسوم ومحتوى الوسم.
- `HtmlParser.g4`: قواعد Parser مستقلة تستخدم `tokenVocab=HtmlLexer`.
- `Css.g4`: Grammar مدمجة (Combined Grammar)؛ فهي تحتوي قواعد Parser بأسماء صغيرة وقواعد Lexer بأسماء كبيرة، ولا تحتاج حالياً إلى Lexer Modes.
- `JavaLexer.g4` و`JavaParser.g4`: فصلنا قواعد Java إلى Lexer وParser مستقلين، ويستهدفان مجموعة مفيدة من تراكيب Java الشائعة في Spring MVC.

## HTML / Thymeleaf

يدعم النطاق الحالي عناصر شائعة مثل `html`, `head`, `body`, `div`, `span`, `p`, `h1` إلى `h6`, `a`, `img`, `ul`, `li`, `form`, `input`, `button`, `table`, `section`, `main` وغيرها من القائمة الموجودة في `AnalyzerService.SUPPORTED_HTML_TAGS`.

يدعم كذلك خصائص Thymeleaf التي تبدأ بـ `th:` على مستوى التعرّف على اسم الخاصية، مثل `th:text` و`th:if` و`th:each`. تحليل التعبيرات داخل قيم الخصائص (مثل `${...}`) ليس بعد محللاً تعبيرياً كاملاً.

أضفنا تحققين بعد التحليل النحوي:

1. **اسم العنصر المدعوم:** إذا لم يكن اسم العنصر ضمن القائمة التي يدعمها المشروع، تظهر رسالة `Unsupported HTML element`. هذه رسالة عن حدود Grammar المشروع وليست حكماً عاماً بأن كل عنصر غير معروف غير صالح في HTML.
2. **تطابق وسم البداية والنهاية:** تقارن الخدمة اسم الوسم المفتوح باسم الوسم المغلق، مثل `<h1>...</h1>`. إذا اختلف الاسمان تظهر رسالة `HTML tag mismatch`.

العناصر الفارغة (Void Elements) المعرفة حالياً هي: `area`, `base`, `br`, `col`, `embed`, `hr`, `img`, `input`, `link`, `meta`, `param`, `source`, `track`, `wbr`. لا تحتاج هذه العناصر إلى وسم إغلاق.

## Java / Spring MVC

`JavaLexer.g4` يتعرّف على الكلمات المفتاحية والمعرّفات والسلاسل النصية والعوامل والفواصل والتعليقات والمسافات.

`JavaParser.g4` يدعم نطاقاً تعليمياً من:

- package وimport.
- class وinterface.
- annotations مثل `@Controller`, `@GetMapping`, `@PostMapping`.
- الحقول والتوابع والبارامترات والأنواع الشائعة.
- كتل التعليمات، return، if، while، for، واستدعاءات التوابع.

هذا ليس Java Parser كاملاً. الغرض الحالي هو البدء بتحليل ملفات Java ذات الصلة بمشروع Spring Boot، ثم توسيع القواعد وفق ملفات الاختبار الفعلية.

## CSS

Grammar الحالية تشمل قواعد selectors وdeclarations وcomponent values وبعض at-rules، وهي مجموعة تعليمية وليست مواصفة CSS كاملة.

## ملاحظات مهمة

- `-> skip` يتجاهل العنصر ولا يصدر Token، مثل تعليقات HTML وDOCTYPE.
- `channel(HIDDEN)` يبقي الـ Token في مجرى الرموز على قناة مخفية؛ Parser لا يستهلك هذه القناة افتراضياً، كما أن جدول Tokens في واجهتنا يخفيها.
- ANTLR يولّد ملفات Java من هذه القواعد أثناء Maven Build؛ لا تعدّل الملفات المولّدة داخل `target/generated-sources/antlr4` يدوياً.
