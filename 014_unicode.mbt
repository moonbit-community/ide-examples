// This example demonstrates unicode support in MoonBit

type T Int derive(Debug)

fn 😀(self : T) -> Unit {
  debug(self)
}

fn init {
  let 🤣 = T::T(3)
  🤣.😀()
}

