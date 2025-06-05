// This example demonstrate operator overloading in MoonBit.
// Currently, the following operators can be overloaded in MoonBit:
//
// | operator name        | target name |
// | -------------------- | ----------- |
// | `+`                  | `Add`(trait)|
// | `-`                  | `Sub`(trait)|
// | `*`                  | `Mul`(trait)|
// | `/`                  | `Div`(trait)|
// | `%`                  | `Mod`(trait)|
// | `-`(unary)           | `Neg`(trait)|
// | `_[_]`(get item)     | `op_get`(method) |
// | `_[_] = _`(set item) | `op_set`(method) |
//
// For more, see : https://docs.moonbitlang.com/en/latest/language/methods.html#operator-overloading

pub struct T {
  x : Int
} derive(Show)

/// `op_add(self: T, other: T)`
///
/// Perform addition operation between two objects of type T.
pub impl Add for T with op_add(self : T, other : T) -> T {
  { x: self.x + other.x }
}

fn main {
  let a = { x: 0 }
  let b = { x: 2 }
  println(a + b)
}
