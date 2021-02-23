# Source text

SourceCharacter :: /[\u0009\u000A\u000D\u0020-\uFFFF]/

## Comments

Comment :: `//` CommentChar*

CommentChar :: SourceCharacter but not LineTerminator

```example
// This is a comment
```

## Line Terminators

LineTerminator ::
  - "New Line (U+000A)"
  - "Carriage Return (U+000D)" [ lookahead ! "New Line (U+000A)" ]
  - "Carriage Return (U+000D)" "New Line (U+000A)"
