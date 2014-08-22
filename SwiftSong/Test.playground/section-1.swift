// Playground - noun: a place where people can play

import Cocoa


var str = "Hello, playground"
let names = ["Chris", "Alex", "Ewa", "Barry", "Daniella"]
func backwards(s1: String, s2: String) -> Bool {
    return s1 > s2
}


find(names,"Alexa")





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

var x = NSDate()

var y = NSDate()

var time = y.timeIntervalSinceDate(x) * 1000


var r = Int(arc4random_uniform((UInt32(50))))

func shuffle<T>(var list: Array<T>) -> Array<T> {
    for i in 0..<list.count {
        let j = Int(arc4random_uniform(UInt32(list.count - i))) + i
        list.insert(list.removeAtIndex(j), atIndex: i)
    }
    return list
}
shuffle([1, 2, 3, 4, 5, 6, 7, 8])        // e.g., [6, 1, 8, 3, 2, 4, 7, 5]
shuffle(["hello", "goodbye", "ciao"])    // e.g., ["ciao", "goodbye", "hello"]



class Foo
{
    
}


var songs = Dictionary<String, [Int]>()
songs["Foo"] = [2,5,1,6]
songs["Bar"] = [10,3,1,2]
songs["Ack"] = [1,3,2]


songs


