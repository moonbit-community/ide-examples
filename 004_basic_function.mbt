/// Add is a function that takes two arguments and returns a Int value.
fn add(a : Int, b : Int) -> Int {
  // return the sum of a and b
  a + b
}

/// If the function have no return type, you can use Unit.
fn compute() -> Unit {
  println(add(2, 40))
}

fn main {
  compute()
}


