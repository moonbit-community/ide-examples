// This example demonstrates tuple accessor in MoonBit.
// The components of tuple can be extracted directly via [.index] (zero based)

fn main {
  // access via index
  let x = (1, 2)
  println(x.0) // 1
  println(x.1) // 2

  // print(x.2) // error, 2-tuple has no field `2`

  let y = ("apple", "tomato", "banana")
  println(y.2) // "banana"
  // access via pattern matching
  let (a, b) = (100, 200)
  println("a: \(a), b: \(b)")
}
