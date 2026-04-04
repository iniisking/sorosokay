class TextFormatter {
  TextFormatter._();

  // ── Patterns (compiled once) ──────────────────────────────────

  static final _multiSpace = RegExp(r'\s{2,}');

  static final _fillers = RegExp(
    r'\b(?:um+|uh+|ah+|er+|hmm+|like uh|you know what i mean)\b\s*',
    caseSensitive: false,
  );

  /// Standalone "i" and its contractions that STT often lowercases.
  static final _pronounI = RegExp(r"(?<=^|\s)(i)((?:'m|'ve|'ll|'d)?(?=\s|$|[,.:;!?]))");

  /// Interrogative-word openings.
  static final _interrogativeStart = RegExp(
    r'^(?:who|what|where|when|why|how|which)\b',
    caseSensitive: false,
  );

  /// Auxiliary-verb openings (inverted subject → question).
  static final _auxStart = RegExp(
    r"^(?:is|are|was|were|do|does|did|can|could|would|should|will|shall|have|has|had|am|isn't|aren't|wasn't|weren't|don't|doesn't|didn't|won't|can't|couldn't|wouldn't|shouldn't)\b",
    caseSensitive: false,
  );

  /// Tag-question endings.
  static final _tagEnding = RegExp(
    r"\b(?:right|correct|huh|no|isn't it|aren't they|aren't you|don't you|don't you think|doesn't it|didn't it|won't you|can't you|wouldn't it)\s*$",
    caseSensitive: false,
  );

  /// Introductory words / phrases that take a trailing comma.
  static final _introPhrase = RegExp(
    r'^('
    r'well|so|actually|basically|honestly|anyway|however|meanwhile|therefore|'
    r'furthermore|moreover|nevertheless|unfortunately|fortunately|obviously|'
    r'clearly|personally|apparently|interestingly|surprisingly|technically|'
    r'certainly|indeed|okay|alright|look|listen|now|also|yes|no|'
    r'of course|in fact|for example|for instance|on the other hand|'
    r'by the way|first of all|in addition|as a result|in conclusion|'
    r'to be honest|to be fair|at the same time|in other words|after all|'
    r'I mean|you know|you see'
    r')\s',
    caseSensitive: false,
  );

  /// Coordinating conjunctions that may deserve a preceding comma when they
  /// join two clauses (heuristic: ≥ 3 words before the conjunction).
  static final _conjunction = RegExp(
    r'(\S+(?:\s+\S+){2,})\s+(but|yet|however|so|because|although|though|since|'
    r'while|whereas|unless|even though|except)\s',
    caseSensitive: false,
  );

  /// Terminal punctuation.
  static final _endsWithPunctuation = RegExp(r'[.!?]$');

  /// Duplicated punctuation artefacts.
  static final _duplicatePunctuation = RegExp(r'([.!?,;:])\1+');

  /// Space before punctuation.
  static final _spaceBeforePunct = RegExp(r'\s+([.!?,;:])');

  /// Missing space after punctuation (but not inside numbers like 3.14).
  static final _missingSpaceAfterPunct = RegExp(r'([.!?,;:])([A-Za-z])');

  // ── Public API ────────────────────────────────────────────────

  /// Format a single final-result chunk coming from STT.
  static String formatFinalChunk(String input) {
    var text = input.trim();
    if (text.isEmpty) return text;

    text = _collapseWhitespace(text);
    text = _removeFillers(text);
    text = text.trim();
    if (text.isEmpty) return text;

    text = _fixPronounI(text);
    text = _insertIntroComma(text);
    text = _insertConjunctionCommas(text);
    text = _capitalizeFirst(text);
    text = _ensureTerminalPunctuation(text);

    return text;
  }

  /// Run a final polish over the entire accumulated transcript (called once
  /// when the user presses stop). This fixes cross-sentence issues that
  /// per-chunk formatting can't catch.
  static String polishFullText(String input) {
    var text = input.trim();
    if (text.isEmpty) return text;

    text = _collapseWhitespace(text);
    text = _fixPronounI(text);
    text = _fixPunctuationSpacing(text);
    text = _capitalizeAfterPunctuation(text);

    return text;
  }

  // ── Private helpers ───────────────────────────────────────────

  static String _collapseWhitespace(String t) =>
      t.replaceAll(_multiSpace, ' ');

  static String _removeFillers(String t) =>
      t.replaceAll(_fillers, '').trim();

  static String _fixPronounI(String t) =>
      t.replaceAllMapped(_pronounI, (m) => 'I${m.group(2)}');

  static String _capitalizeFirst(String t) {
    if (t.isEmpty) return t;
    return t[0].toUpperCase() + t.substring(1);
  }

  /// Add comma after a recognised introductory word/phrase if one isn't
  /// already there.
  static String _insertIntroComma(String t) {
    final match = _introPhrase.firstMatch(t);
    if (match == null) return t;

    final phrase = match.group(1)!;
    final afterPhrase = t.substring(match.end).trimLeft();
    if (afterPhrase.startsWith(',')) return t;

    return '$phrase, $afterPhrase';
  }

  /// Insert a comma before coordinating conjunctions that join two
  /// reasonably-sized clauses, unless a comma is already present.
  static String _insertConjunctionCommas(String t) {
    return t.replaceAllMapped(_conjunction, (m) {
      final before = m.group(1)!;
      final conj = m.group(2)!;
      if (before.endsWith(',')) return m.group(0)!;
      return '$before, $conj ';
    });
  }

  /// Determine terminal punctuation: ? for questions, . otherwise.
  /// Does nothing if punctuation already exists (e.g. from autoPunctuation).
  static String _ensureTerminalPunctuation(String t) {
    if (_endsWithPunctuation.hasMatch(t)) return t;
    return _isQuestion(t) ? '$t?' : '$t.';
  }

  static bool _isQuestion(String t) {
    final lower = t.toLowerCase().trim();
    if (_interrogativeStart.hasMatch(lower)) return true;
    if (_auxStart.hasMatch(lower)) return true;
    if (_tagEnding.hasMatch(lower)) return true;
    return false;
  }

  static String _capitalizeAfterPunctuation(String t) {
    return t.replaceAllMapped(
      RegExp(r'([.!?]\s+)([a-z])'),
      (m) => '${m.group(1)}${m.group(2)!.toUpperCase()}',
    );
  }

  static String _fixPunctuationSpacing(String t) {
    var r = t;
    r = r.replaceAll(_duplicatePunctuation, r'$1');
    r = r.replaceAll(_spaceBeforePunct, r'$1');
    r = r.replaceAllMapped(
      _missingSpaceAfterPunct,
      (m) => '${m.group(1)} ${m.group(2)}',
    );
    return r;
  }
}
