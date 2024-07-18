/// `odd(x : Int)`
///
/// Determine if an integer is odd using recursion and pattern matching.
/// Returns `true` if the input integer is odd, `false` otherwise.
pub fn odd(x : Int) -> Bool {
  match x {
    0 => false
    1 => true
    _ => even(x - 1)
  }
}
