///|
using @list {type List}

///|
let pi = 3.141592653578

///|
let surface_r_1 : Double = {
  let r = 1.0
  pi * r * r
}

///|
let surface_r_2 : Double = {
  let r = 2.0
  pi * r * r
}

///|
let surface_r_3 : Double = {
  let r = 3.0
  pi * r * r
}

///|
fn 面积(半径 : Double) -> Double {
  pi * 半径 * 半径
}

// The following two lines are equivalent 下方两行等价
// let result: (Double, Double, Double) = (surface_r_1, surface_r_2, surface_r_3)

///|
let result : (Double, Double, Double) = (面积(1.0), 面积(2.0), 面积(3.0))

///|
fn one() -> Int {
  1
}

///|
fn add_char(ch : Char, str : String) -> String {
  ch.to_string() + str
}

///|
let moonbit : String = add_char(Int::unsafe_to_char(109), "oonbit")

///|
let ch : Char = Int::unsafe_to_char(-1)

///|
let nan : Int = 1 / 0

///|
fn div(a : Int, b : Int) -> Int? {
  if b == 0 {
    None
  } else {
    Some(a / b)
  }
}

///|
let answer : () -> Int = fn() {
  fn real_answer(_i) {
    42
  }

  real_answer("Ultimate answer")
}

///|
let int_list : List[Int] = @list.cons(
  1,
  @list.cons(2, @list.cons(3, @list.empty())),
)

///|
let char_list : List[Char] = @list.cons(
  '一',
  @list.cons('句', @list.cons('话', @list.empty())),
)

// The following three lines do not compile as they are not valid lists 下方三行无法通过编译，不是合法的列表
// let not_list1: List[Int] = Cons(1, Cons(true, Cons(3, Nil)))
// let not_list2: List[Int] = Cons(1, 2)
// let not_list3: List[Int] = Cons(1, Cons(Nil, Nil))

///|
fn head_opt(list : List[Int]) -> Int? {
  match list {
    Empty => None
    More(head, ..) => Some(head)
  }
}

///|
let first_elem : Int? = head_opt(@list.cons(1, @list.cons(2, @list.empty()))) // Some(1)

///|
fn get(option_int : Int?, default : Int) -> Int {
  match option_int {
    Some(value) => value
    None => default
  }
}

///|
fn fib(n : Int) -> Int {
  if n == 1 || n == 2 {
    1
  } else {
    fib(n - 1) + fib(n - 2)
  }
}

///|
fn even(n : Int) -> Bool {
  n != 1 && (n == 0 || odd(n - 1))
}

///|
fn odd(n : Int) -> Bool {
  n != 0 && (n == 1 || even(n - 1))
}

///|
fn length(list : List[Int]) -> Int {
  match list {
    Empty => 0
    More(_, tail=tl) => 1 + length(tl)
  }
}

///|
let n : Int = length(@list.cons(1, @list.cons(2, @list.empty())))

///|
fn tail(list : List[Int]) -> List[Int] {
  match list {
    Empty => @list.empty()
    More(_, tail=tl) => tl
  }
}
