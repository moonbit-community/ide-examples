// This example demonstrates some string-related operations in MoonBit

enum T {
  A
  B
}

/// convert T to string
fn to_string(self : T) -> String {
  match self {
    A => "A"
    B => "B"
  }
}

fn main {
  let a = T::A
  let b = T::B

  // Format strings contain "replacement fields" surrounded by \()
  // Custom data types with the [to_string] method can be spliced directly
  println("Hello a: \(a) & b: \(b) -- wow~")
  let c = "string" + " to" + " append"
  println(c)

  // multi-line string literal
  let m =
    #| A
    #| multi-line
    #| string
  println(m)
}
