///|
fn init {
  let empty : Stack[Int] = Stack::empty()
  println("empty is Empty: \{empty}")
  let one = empty.push(1)
  let two = one.push(1)
  let (top, rest) = two.pop()
  match top {
    Some(value) => println("top should be Some(1): \{value}")
    None => abort("error")
  }
  println("rest should equal to one: \{rest} == \{one}")
  let empty_queue : Queue[Int] = Queue::empty()
  let one_queue = empty_queue.push(1)
  println("one_queue should contain 1 in front: \{one_queue}")
  let two_queue = one_queue.push(2)
  println("two_queue should contain 1 in front and 2 in back: \{two_queue}")
  let (first, rest) = two_queue.pop()
  match first {
    Some(value) => println("first should be Some(1): \{value}")
    None => abort("error")
  }
  println("rest should contain 2 in front: \{rest}")
}

///|
enum IntStack {
  Empty
  NonEmpty(Int, IntStack)
} derive(Show, Eq)

///|
fn IntStack::empty() -> IntStack {
  Empty
}

///|
fn IntStack::push(self : IntStack, value : Int) -> IntStack {
  NonEmpty(value, self)
}

///|
fn IntStack::pop(self : IntStack) -> (Int?, IntStack) {
  match self {
    Empty => (None, Empty)
    NonEmpty(top, rest) => (Some(top), rest)
  }
}

///|
enum StringStack {
  Empty
  NonEmpty(String, StringStack)
} derive(Show, Eq)

///|
fn StringStack::empty() -> StringStack {
  Empty
}

///|
fn StringStack::push(self : StringStack, value : String) -> StringStack {
  NonEmpty(value, self)
}

///|
fn StringStack::pop(self : StringStack) -> (String?, StringStack) {
  match self {
    Empty => (None, Empty)
    NonEmpty(top, rest) => (Some(top), rest)
  }
}

///|
enum Stack[T] {
  Empty
  NonEmpty(T, Stack[T])
} derive(Show, Eq)

///|
fn[T] Stack::empty() -> Stack[T] {
  Empty
}

///|
fn[T] Stack::push(self : Stack[T], value : T) -> Stack[T] {
  NonEmpty(value, self)
}

///|
fn[T] Stack::pop(self : Stack[T]) -> (T?, Stack[T]) {
  match self {
    Empty => (None, Empty)
    NonEmpty(top, rest) => (Some(top), rest)
  }
}

///|
struct Queue[T] {
  front : Stack[T]
  back : Stack[T]
} derive(Show, Eq)

///|
fn[T] Queue::empty() -> Queue[T] {
  { front: Empty, back: Empty }
}

///|
fn[T] Queue::push(self : Queue[T], value : T) -> Queue[T] { // push element to the end of the queue 将元素存入队尾
  Queue::normalize({ ..self, back: self.back.push(value) })
}

///|
fn[T] Queue::pop(self : Queue[T]) -> (T?, Queue[T]) { // remove the first element 取出第一个元素
  match self.front {
    Empty => (None, self)
    NonEmpty(top, rest) =>
      (Some(top), Queue::normalize({ ..self, front: rest }))
  }
}

///|
fn[T] Queue::normalize(self : Queue[T]) -> Queue[T] { // if front is empty, revert back into front 如果front为空，反转back到front
  match self.front {
    Empty => { front: self.back.reverse(), back: Empty }
    _ => self
  }
}

///|
fn[T] Stack::reverse(self : Stack[T]) -> Stack[T] { // aux: reverse stack 辅助函数：反转堆栈
  fn go(acc, xs : Stack[T]) {
    match xs {
      Empty => acc
      NonEmpty(top, rest) => go((NonEmpty(top, acc) : Stack[T]), rest)
    }
  }

  go(Empty, self)
}

///|
fn[A, B] fold_right(list : List[A], f : (A, B) -> B, b : B) -> B {
  match list {
    Nil => b
    Cons(hd, tl) => f(hd, fold_right(tl, f, b))
  }
}

///|
fn[A, B] map(list : List[A], f : (A) -> B) -> List[B] {
  match list {
    Nil => Nil
    Cons(hd, tl) => Cons(f(hd), map(tl, f))
  }
}

///|
fn[A, B] map_with_fold_right(list : List[A], f : (A) -> B) -> List[B] {
  fold_right(list, fn(value, cumulator) { Cons(f(value), cumulator) }, Nil)
}

///|
fn[A, B] fold_left(list : List[A], f : (B, A) -> B, b : B) -> B {
  match list {
    Nil => b
    Cons(hd, tl) => fold_left(tl, f, f(b, hd))
  }
}

///|
/// convert list to string 将列表转化为字符串
fn[T : Show] List::to_string(self : List[T]) -> String {
  fn go(ls : List[T]) {
    match ls {
      Nil => ""
      Cons(x, Nil) => "\{x}"
      Cons(x, xs) => "\{x}, " + go(xs)
    }
  }

  "[" + go(self) + "]"
}

///|
impl[T : Show] Show for List[T] with output(self : List[T], logger : &Logger) -> Unit {
  logger.write_string(self.to_string())
}

///|
enum List[T] {
  Nil
  Cons(T, List[T])
}

///|
fn init {
  println(
    fold_left(
      Cons("1", Cons("2", Cons("3", Nil))),
      fn(b : String, a) { "(\{b} + \{a})" },
      "0",
    ),
  )
  println(
    fold_right(
      Cons("1", Cons("2", Cons("3", Nil))),
      fn(a : String, b : String) { "(\{a} + \{b})" },
      "0",
    ),
  )
  println(map(Cons(0, Cons(1, Cons(2, Cons(3, Nil)))), fn(i) { i * 10 }))
}
