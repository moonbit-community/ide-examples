// This example demonstrates MoonBit's ability to automatically derive implementations for some traits

struct T {
  x : Int
  y : Int
} derive(Eq, Compare, Debug, Show, Default)

fn main {
  let t1 = T::default()
  let t2 = { x: 1, y: 1 }
  println(t1) // {x: 0, y: 0}
  println(t2) // {x: 1, y: 1}
  println(t1 == t2) // false
  println(t1 < t2) // true
}
