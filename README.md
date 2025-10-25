# Atomical - A novel, constraint based meta parser
A soon-to-be implemented meta parser with fine grain control of how the generated parser interprets language.

### Preface
This beautiful idea has been reoccurring in my mind in various forms for years now, and only a couple of years ago did I make my first attempt at making a lexer in Lua—it took a couple of attempts. So far I have read little on formally developing lexers and parsers, as I enjoy the process of obsessively philosophizing about them. This design in particular combines the parser and lexer into one machine and operates on deductive reasoning through explicit and imperative constraints.

# Atomical's Philosophy
## Design Pillars
### 1. Primitive Constructs 
The most emphasized aspect of this program is that it **should absolutely have no syntax, grammar, or characters hard coded; it operates only the notion of a token(a collection of characters) and such that divides the AST**. We shall call these *divisors*, or that which contains *token(s)*. We can immediately associate symbols like brackets, but also observe that strings behave similarly; the only distinction would be that strings only comprise a singular token.  
### 2. Typesets
Every token eventually is assigned a set of types, and the way in which these types are derived reveal a hierarchical correspondence, wherein an individual typeset functions as a set and as one component to the identity of a token. An easy way to understand is that a token's type can be seen as the path to an object, where each index represents a typeset. For example:
`operator.unary.plus`, `bracket.square`, `alphabetic.keyword`, `alphanumeric.identifier`

There exists an implicit set which contains all possible top-level sets, we shall refer to this set as the `master` set. It is omitted from a tokens type since no other type can precede it, it only serves to keep the internal mechanisms of assigning a type coherent. The MP by default has common primitive typesets available, like
`whitespace`, `alphabetic`, `numeric`, `alphanumeric`

An important feature to note is that there are no provided typesets for brackets, strings, etc. This is intentional so  as to help the author writing their DSL—or more broadly, any language—realize the dynamic nature of this MP. They must reconstruct such *divisors* with the provided means to define more sophisticated tokens. At runtime, the generator will interpret the grammar and constraints(meta) provided to develop a mapping for individual characters' respective memberships to typesets. Typesets are declared with explicit and imperative criteria: explicit criteria refers to discrete tokens such as the literal `true`; imperative criteria utilizes negative and exclusive framing, for the resulting parser operates on a deductive approach to the differentiation of types, though I may implement ways to weigh specific structures more when ambiguous contexts prove to be difficult. To demonstrate how criteria is formed, one might declare the meta of their keywords and identifiers as such:
`keyword<alphabetic>: [if then for while  of not] {};`
`identifier<alphanumeric>: [^(alphabetic)(alphanumeric)*$] {-keyword}`

>Here, the two typesets `keyword` and `identifier` may only contain alphabetic and alphanumeric characters respectively (note that keywords are explicitly written and quotes are optional for most cases). If there is no imperative criteria, you at minimum must end with empty {} brackets. The identifier typeset is declared to be (of) the built-in alphanumeric typeset and uses a quasi-regex(TBD) syntax for the explicit criteria. Observe that while only one element is defined explicitly, it is still surrounded by [] brackets. Then for the imperative criteria, the identifier is to be differentiated against such that it may never be a keyword. 

Consider the following meta:
`A<alphabetic>: [the then there] {};`
`B<alphabetic>: [] {-A}`;

The design as of when this was written presupposes that during the token delimitation process, if the current token buffer completely matches an explicit criterion of type `A`, there is absolute certainty the current buffer must *at least* be of type `(...).A`, and therefore can deduce that type `(...).B` is not a valid typeset candidate, consequently reducing the candidate list. However, per each consequential pruning by virtue of imperative criteria, or more specifically here the criteria that asserts the negative against another typeset, eliminated typesets are moved to a list under the candidate that propagated the removal thereof, so that what candidates pruned are reactivated in the event the candidate it was stored under is pruned itself. 
