// This example demonstrate operator overloading in MoonBit.
// Currently, the following operators can be overloaded in MoonBit:
//
// | operator name        | method name |
// | -------------------- | ----------- |
// | `+`                  | `op_add`    |
// | `-`                  | `op_sub`    |
// | `*`                  | `op_mul`    |
// | `/`                  | `op_div`    |
// | `%`                  | `op_mod`    |
// | `-`(unary)           | `op_neg`    |
// | `_[_]`(get item)     | `op_get`    |
// | `_[_] = _`(set item) | `op_set`    |

pub struct T {
  x : Int
} derive(Debug)

/// `op_add(self: T, other: T)`
///
/// Perform addition operation between two objects of type T.
pub fn op_add(self : T, other : T) -> T {
  { x: self.x + other.x }
}

fn main {
  let a = { x: 0 }
  let b = { x: 2 }
  debug(a + b)
}
