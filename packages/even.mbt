/// `even(x : Int)`
///
/// Determine if an integer is even using recursion and pattern matching.
/// Returns `true` if the input integer is even, `false` otherwise.
pub fn even(x : Int) -> Bool {
  match x {
    0 => true
    1 => false
    _ => odd(x - 1)
  }
}

