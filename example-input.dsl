KEYWORD<alphabetic>: [while for do in of not];
IDENTIFIER<alphabetic>: [(alphabetic)(*alphanumeric)] {-KEYWORD};

BOOLEAN<ALPHABETIC>: [true false];
NUMBER: [(numeric)('e')(*numeric), (*numeric))]

MODE STRING_OVERIDE: {
        CONTENT<GLOBAL::any>
}

STRING<DIV::STRING_OVERIDE>: [('\"', '\"')]

LITERAL: [BOOLEAN, NUMBER, STRING]

TYPEDEF OPERAND: [LITERAL, IDENTIFIER]

UNARYOPERATOR: [- + # $ & *] {
    [+1]: [KEYWORD]
}

BINARYOPERATOR: [
    - + * / % ': > >> < << == ='
] {
    [-1]: [-KEYWORD]
    [+1]: [-KEYWORD]
}

OPERATOR: [UNARYOPERATOR, BINARYOPERATOR]

PARANETHESIS<DIV>: [('(', ')')]
SQUARE<DIV>: ['[', ']']
CURLY<DIV>: ['{', '}']

ANGLE<DIV>: ['<', '>'] {
    [-1]: [IDENTIFIER]
}

BRACKET: [ANGLE, CURLY, SQUARE, PARANETHESIS]
