///|
/// Symbolic differentiation 符号微分
enum Symbol {
  Constant(Double)
  Var(Int)
  Add(Symbol, Symbol)
  Mul(Symbol, Symbol)
} derive(Show)

///|
fn Symbol::constant(d : Double) -> Symbol {
  Constant(d)
}

///|
fn Symbol::var_(i : Int) -> Symbol {
  Var(i)
}

///|
impl Add for Symbol with add(f1, f2) {
  // Add(f1, f2) // Without simplification 无化简实现
  // With simplification 以下为化简实现
  match (f1, f2) {
    (Constant(0.0), a) => a
    (Constant(a), Constant(b)) => Constant(a * b)
    (a, Constant(_) as konst) => konst + a
    _ => Add(f1, f2)
  }
}

///|
impl Mul for Symbol with mul(f1, f2) {
  // Mul(f1, f2) // Without simplification 无化简实现
  // With simplification 以下为化简实现
  match (f1, f2) {
    (Constant(0.0), _) => Constant(0.0)
    (Constant(1.0), a) => a
    (Constant(a), Constant(b)) => Constant(a * b)
    (a, Constant(_) as konst) => konst * a
    _ => Mul(f1, f2)
  }
}

///|
fn Symbol::compute(self : Symbol, input : Array[Double]) -> Double {
  match self {
    Constant(d) => d
    Var(i) => input[i] // get value following index 根据下标取值
    Add(f1, f2) => f1.compute(input) + f2.compute(input)
    Mul(f1, f2) => f1.compute(input) * f2.compute(input)
  }
}

// val is the index of the variable to be differentiated
// val代表当前微分的变量

///|
fn Symbol::differentiate(self : Symbol, val : Int) -> Symbol {
  match self {
    Constant(_) => Constant(0.0)
    Var(i) => if i == val { Constant(1.0) } else { Constant(0.0) } // determine if is the variable to be differentiated 根据下标判断是否为微分对象
    Add(f1, f2) => f1.differentiate(val) + f2.differentiate(val)
    Mul(f1, f2) => f1 * f2.differentiate(val) + f1.differentiate(val) * f2
  }
}

///|
fn example() -> Symbol {
  Symbol::constant(5.0) * Symbol::var_(0) * Symbol::var_(0) + Symbol::var_(1)
}

///|
test {
  let input = [10.0, 100.0]
  println("Symbolic differentiation 符号微分")
  let symbol : Symbol = example()
  println(symbol.compute(input))
  println("Expression of df/dx 关于x的偏微分表达式树")
  println(symbol.differentiate(0))
  println(symbol.differentiate(0).compute(input))
  println(symbol.differentiate(1).compute(input))
  println("======")
}

// Abstraction of computation 对运算的抽象

///|
trait Number: Add + Mul {
  constant(Double) -> Self
  // op_add(Self, Self) -> Self
  // op_mul(Self, Self) -> Self
  value(Self) -> Double
}

// Implement abstraction for Double 对浮点数实现抽象

// Compute max with native control flow 利用原生控制流求最大值

///|
fn[N : Number] max(x : N, y : N) -> N {
  if x.value() > y.value() {
    x
  } else {
    y
  }
}
// Rectified linear unit 线性整流函数

///|
fn[N : Number] relu(x : N) -> N {
  max(x, N::constant(0.0))
}

// Forward differentiation: dual number 前向微分，二元数

///|
struct Forward {
  value : Double
  derivative : Double
} derive(Show)

///|
fn Forward::constant(d : Double) -> Forward {
  { value: d, derivative: 0.0 }
}

// diff: weather differentiate this variable
// diff：是否对当前变量求偏微分

///|
fn Forward::var_(d : Double, diff : Bool) -> Forward {
  { value: d, derivative: if diff { 1.0 } else { 0.0 } }
}

///|
impl Add for Forward with add(f, g) {
  { value: f.value + g.value, derivative: f.derivative + g.derivative } // f' + g',,,
}

///|
impl Mul for Forward with mul(f, g) {
  {
    value: f.value * g.value,
    derivative: f.value * g.derivative + g.value * f.derivative, // f * g' + g * f',,,
  }
}

///|
impl Number for Forward with value(f) {
  f.value
}

///|
impl Number for Forward with constant(d) {
  { value: d, derivative: 0.0 }
}

///|
impl Number for Double with value(f) {
  f
}

///|
impl Number for Double with constant(d) {
  d
}

///|
fn init {
  println("Compute using abstraction 利用抽象进行计算值")
  println(relu(10.0))
  println(relu(-10.0))
  println(
    "Forward differentiation with abstraction 利用抽象进行前向微分",
  )
  println(relu(Forward::var_(10.0, true)))
  println(relu(Forward::var_(-10.0, true)))
  (Forward::var_(10.0, false) * Forward::var_(100.0, true)) |> println // f(x, y) = x * y, 求df/dy(10, 100)
  println("======")
}

// Backward differentiation 后向微分
// Warning : this implementation is not fully correct as it can cause exponential complexity
// 警告：这个实现并不完全正确，可能会导致指数级复杂度的计算

///|
struct Backward {
  value : Double
  backward : (Double) -> Unit // update the partial derivative of the current path 更新当前路径获得的偏微分
}

///|
fn Backward::constant(d : Double) -> Backward {
  { value: d, backward: _ => () }
}

///|
fn Backward::var_(value : Double, diff : Ref[Double]) -> Backward {
  { value, backward: d => diff.val = diff.val + d } // accumulate partial derivative 累加偏微分
}

///|
fn Backward::backward(b : Backward, d : Double) -> Unit {
  (b.backward)(d)
}

///|
impl Number for Backward with value(b) {
  b.value
}

///|
impl Number for Backward with constant(d) {
  Backward::constant(d)
}

///|
impl Add for Backward with add(b1, b2) {
  {
    value: b1.value + b2.value,
    backward: fn(diff) {
      b1.backward(diff)
      b2.backward(diff)
    },
  }
}

///|
impl Mul for Backward with mul(b1, b2) {
  {
    value: b1.value * b2.value,
    backward: fn(diff) {
      b1.backward(diff * b2.value)
      b2.backward(diff * b1.value)
    },
  }
}

///|
test {
  println("Backward differentiation 后向微分")
  let diff_x = Ref::{ val: 0.0 }
  let diff_y = Ref::{ val: 0.0 }
  let x = Backward::var_(10.0, diff_x)
  let y = Backward::var_(100.0, diff_y)
  (x * y).backward(1.0) // df / df = 1
  println(diff_x)
  println(diff_y)
  println("======")
}

///|
fn[N : Number] example_newton(x : N) -> N {
  x * x * x + N::constant(-10.0) * x * x + x + N::constant(1.0)
}

///|
test {
  println("Newton's method 牛顿迭代法案例")
  fn abs(d : Double) -> Double {
    if d >= 0.0 {
      d
    } else {
      -d
    }
  }

  let val = loop Forward::var_(1.0, true) { // initial value 初始值
    x => {
      let { value, derivative } = example_newton(x)
      if abs(value / derivative) < 1.0e-9 {
        break x.value // end the loop and have x.value as the value of the loop body 结束循环，并且将x.value作为整个循环体的值
      }
      continue Forward::var_(x.value - value / derivative, true) // continue the loop 继续循环
    }
  }
  println(val)
}
