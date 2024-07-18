// FFI(Foreign function Interface) demo
fn answer() -> Int = "universe" "answer"

fn get_pi() -> Double = "Math" "get_pi"

fn random() -> Double = "Math" "random"

fn add(x : Int, y : Int) -> Int = "Runtime" "add"

fn sqrt(n : Double) -> Double = "(func (param $n f64) (result f64) (f64.sqrt (local.get $n)))"

fn init {
  println(answer())
  println(random())
  println(get_pi())
  println(add(1, 2))
  let s = Js_string::new("123")
  let ss = Js_string::new("abc\n")
  s.log()
  (s + ss).log()
  println(sqrt(4.0))
}
