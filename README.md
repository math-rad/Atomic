# pex
A lexer written in roblox lua(luau)

A tokenizer that accounts for positions within brackets 

some rambling at 3am















the parser shall not have any hard coded symbols or concepts of brackets. all it will know are attribute sets and special subdivision sets whose decendents create branches(sub divisions) within the syntax tree. these sets have no nesting limit, for each branch represents a new chain to attribute to a token. 

the parser also has rules for which you are to define how to differentiate sets in the case that there are shared symbols. for you see, it knows naught of brackets, only subdivisors. all names are arbitrary in the scheme of this parser/lexer. 

rules never contain literal cases, they utilize attributess
expressions ought to be a meta attribute defined within rules
differentiation of <> brackets and less than and greater than operators will be tough to do, let alone generalize

literals can contain expressions and expressions can contain literals 
expression: [uniOP literal, literal OP literal]


   literal: [number, string, boolean]

literal is an attribute 

rules: [
expression: [
   [uniop, literal]
   [literal, binop, literal]

during Lexing, a token can be in an ambiguous state. 

parsing rules are as follows: there will be presumption for enclosure such that in ambiguous cases between subdivisors and non subdivisors, abstract implementations for expressions are constructed on a white list basis(presumption). said can induce syntax like "[alphanumeric, literal]," is the condition for perpetuating a subdivision; if not terminated with closing sub divisor in paired mode, it is determined that the following is not a subdivision

it can't ever consider xn1, xn2

It has to understand xN



The lexxer is simple. it doesn't form syntax trees. it assigns attributes and diffs tokens. the parser is what has to understand sub divisors, and sub divisor may sub divide n many times


it needs to have dynamic stacks. 


for each sub divisor token encounter, a latent counter is started. as the parser runs through each expression we should consider the concept of it not looking ahead and remaining unsure. when each divisor is reached, we observe our current stack. Everytime we enter the stack we add a count to a different stack which define how many potential subdivisors we are in. per each iteration (one new traversal) you check the most recent elements conditions. perhaps a cascade implementation need be for there may also be non subdivisor rules






c<a>
<a, b, c>
<<a,b>a<b>
a < b > c

a < <ab>











