// FFI(Foreign function Interface) demo
fn answer() -> Int = "universe" "answer"

fn get_pi() -> Double = "Math" "get_pi"

fn random() -> Double = "Math" "random"

fn add(x : Int, y : Int) -> Int = "Runtime" "add"

fn sqrt(n : Double) -> Double = "(func (param $n f64) (result f64) (f64.sqrt (local.get $n)))"

fn main {
  println(answer())
  println(random())
  println(get_pi())
  println(add(1, 2))
  println(sqrt(4.0))
}
