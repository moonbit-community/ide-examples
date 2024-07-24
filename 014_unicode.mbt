// This example demonstrates unicode support in MoonBit

type T Int derive(Show)

fn 😀(self : T) -> Unit {
  println(self)
}

fn main {
  let 🤣 = T::T(3)
  🤣.😀()
}
