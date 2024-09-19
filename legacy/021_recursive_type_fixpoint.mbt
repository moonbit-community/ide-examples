// Rectype mu w/ a `Fold` constructor
// Intuitively, Mu[T] is the solution of Mu[T] ~= Mu[T] -> T
enum Mu[T] {
  Fold((Mu[T]) -> T)
}

// Unfold that expand the rectype w/ pattern matching
fn unfold[T](folded : Mu[T]) -> (Mu[T]) -> T {
  match folded {
    Fold(f) => f
  }
}

// M Combinator: λx.xx
fn m[T](x : Mu[T]) -> T {
  unfold(x)(x)
}

// An isorecursive approach of the Y Combinator: M W
// MoonBit is a strict language thus the Z combinator is used instead of Y
fn fix[T](f : ((T) -> T) -> (T) -> T) -> (T) -> T {
  // W Combinator: λxλyλz.xyyz
  let wt : Mu[(T) -> T] = Fold(fn(x) { f(fn(t : T) { unfold(x)(x)(t) }) })
  m(wt)
}

// A modified factorial definition to *generate* a recursive factorial function
fn gen_factorial(f : (Int) -> Int) -> (Int) -> Int {
  fn(n : Int) { if n == 0 { 1 } else { n * f(n - 1) } }
}

// We can also implement the fixpoint using recursion. -- There's no point.
fn fix_rec[T](f : ((T) -> T) -> (T) -> T) -> (T) -> T {
  fn(x) { f(fix_rec(f))(x) }
}

fn gen_fibonacci(f : (Int) -> Int) -> (Int) -> Int {
  fn(n : Int) {
    match n {
      0 => 0
      1 => 1
      n => f(n - 1) + f(n - 2)
    }
  }
}

// As one would use in APL.
fn iota(n : Int) -> Array[Int] {
  match n {
    0 => []
    n => iota(n - 1) + [n]
  }
}

fn main {
  println(iota(10).map(fix(gen_factorial)))
  // => [1, 2, 6, 24, 120, 720, 5040, 40320, 362880, 3628800]
  println(iota(10).map(fix_rec(gen_fibonacci)))
  // => [1, 1, 2, 3, 5, 8, 13, 21, 34, 55]
}
