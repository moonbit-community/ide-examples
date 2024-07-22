// This example demonstrates the trait system of MoonBit.
// MoonBit's trait system is structural:
// types with all required methods automatically implement a trait.

/// [Number] trait captures the common operations of number-like types
trait Number {
  from_int(Int) -> Self
  op_add(Self, Self) -> Self
  op_sub(Self, Self) -> Self
  op_mul(Self, Self) -> Self
  op_div(Self, Self) -> Self
  op_neg(Self) -> Self
}

/// [average] is a generic function
/// that calculates the average of an array of any number-like type
fn average[N : Number](xs : Array[N]) -> N {
  for i = 0, sum = N::from_int(0); i < xs.length(); i = i + 1, sum = sum + xs[i] {

  } else {
    sum / N::from_int(xs.length())
  }
}

struct Point[N] {
  x : N
  y : N
} derive(Debug)

fn main {
  let xs = [1, 2, 3, 4, 5]
  debug(average(xs))
  let ps : Array[Point[Int]] = [
    { x: 1, y: 5 },
    { x: 2, y: 4 },
    { x: 3, y: 3 },
    { x: 4, y: 2 },
    { x: 5, y: 1 },
  ]
  debug(average(ps))
  let ps2 : Array[Point[Double]] = [
    { x: 1.25, y: 5.25 },
    { x: 2.25, y: 4.25 },
    { x: 3.25, y: 3.25 },
    { x: 4.25, y: 2.25 },
    { x: 5.25, y: 1.25 },
  ]
  debug(average(ps2))
}

// implement [Number] for [Point]

fn Point::from_int[N : Number](i : Int) -> Point[N] {
  let n = N::from_int(i)
  { x: n, y: n }
}

fn op_add[N : Number](self : Point[N], other : Point[N]) -> Point[N] {
  { x: self.x + other.x, y: self.y + other.y }
}

fn op_sub[N : Number](self : Point[N], other : Point[N]) -> Point[N] {
  { x: self.x - other.x, y: self.y - other.y }
}

fn op_mul[N : Number](self : Point[N], other : Point[N]) -> Point[N] {
  { x: self.x * other.x, y: self.y * other.y }
}

fn op_div[N : Number](self : Point[N], other : Point[N]) -> Point[N] {
  { x: self.x / other.x, y: self.y / other.y }
}

fn op_neg[N : Number](self : Point[N]) -> Point[N] {
  { x: -self.x, y: -self.y }
}

// In MoonBit, only the owner of a type can define methods for it.
// However, sometimes we need to extend the functionality of some foreign types.
// For example, [Int] and [Double] has no method [from_int],
// so to make them satisfies [Number], we have to extend their functionality.
//
// To handle this kind of scenario, MoonBit provides a mechanism called extension methods.
// Extension methods allow you to implement new traits for foreign types, if you are the owner of the trait.
// Extension methods can only be used to implement the specified trait, and cannot be called via dot-syntax directly
fn Number::from_int(x : Int) -> Int {
  x
}

fn Number::from_int(x : Int) -> Double {
  x.to_double()
}
