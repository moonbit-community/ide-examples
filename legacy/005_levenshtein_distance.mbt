// This example calculates the Levenshtein distance between two strings using dynamic programming.
// It demonstrates MoonBit's imperative features.
// MoonBit supports the implementation of efficient imperative algorithms and data structures.

/// `levenshtein(a: String, b: String)`
///
/// Calculate the Levenshtein distance between two strings using dynamic programming.
/// This function calculates the Levenshtein distance between two input strings `a` and `b`,
/// which is defined as the minimum number of single-character edits (insertions, deletions,
/// or substitutions) required to transform string `a` into string `b`.
fn levenshtein(a : String, b : String) -> Int {
  let m = a.length()
  let n = b.length()
  let s = [[], []]
  // create Array of length n+1 with elements initialized to 0
  s[0] = Array::make(n + 1, 0)
  s[1] = Array::make(n + 1, 0)
  let mut j = 1
  while j <= n {
    s[0][j] = j
    j = j + 1
  }
  let mut i = 1
  while i <= m {
    s[i.land(1)][0] = i
    let mut j = 1
    while j <= n {
      s[i.land(1)][j] = if a[i - 1] == b[j - 1] {
        s[(i - 1).land(1)][j - 1]
      } else {
        1 + min(
          min(s[(i - 1).land(1)][j - 1], s[(i - 1).land(1)][j]),
          s[i.land(1)][j - 1],
        )
      }
      j = j + 1
    }
    i = i + 1
  }
  s[m.land(1)][n]
}

fn main {
  println(levenshtein("abcdheloworldabcd", "abcdhellowoorldabcd"))
}

/// Find the minimum of two integers.
fn min(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}
