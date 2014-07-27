// Playground - noun: a place where people can play

import Cocoa


var str = "Hello, playground"
let names = ["Chris", "Alex", "Ewa", "Barry", "Daniella"]
func backwards(s1: String, s2: String) -> Bool {
    return s1 > s2
}

//function is defined
var reversed = sorted(names, backwards)

//function is inlined
var inlined = sorted(names, { (s1: String, s2: String) -> Bool in
    return s1 > s2
})

//params are inferred
var inferred = sorted(names, { s1, s2 in return s1 > s2 })
println(inferred)

//omit the return statement
inferred = sorted(names, { s1, s2 in s1 > s2 })
println(inferred)

//write closer outside of parens
inferred = sorted(names) { s1, s2 in s1 > s2 }
println(inferred)


//omit the return and names in favor of positional
inferred = sorted(names, { $0 > $1 } )

//just absurd inference of params from an operator
inferred = sorted(names, >)











