// This example implements a generic linked list data structure,
// and various operations on it in MoonBit

///|
fn main {
  let ls = List::from_array([1, 2, 3, 4, 5]) // create a new List
    .map(fn { x => x * 2 }) // double each element
    .filter(fn { x => x < 9 }) // pick those smaller than 9
  println(ls)

  // use `reduce` to calculate the sum of each elements
  let sum = ls.reduce(fn(a, b) { a + b }, 0)
  println("sum: \{sum}")

  // collect elements of List `ls` into Array
  let ary = ls.collect()
  let len = ary.length()
  println("length: \{len}")

  // print each element of List `ls`
  for i in ls {
    println("element: \{i}")
  }
}

///|
enum List[X] {
  Nil
  Cons(X, List[X])
}

///| OO style
pub fn[X] concat(self : List[X], ys : List[X]) -> List[X] {
  match self {
    Nil => ys
    Cons(x, rest) => Cons(x, rest.concat(ys))
  }
}

///| apply function `f` to each element of List, collect the results into a new List.
fn[X, Y] map(self : List[X], f : (X) -> Y) -> List[Y] {
  match self {
    Nil => Nil
    Cons(x, rest) => Cons(f(x), rest.map(f))
  }
}

///| reverse the List.
pub fn[X] reverse(self : List[X]) -> List[X] {
  fn go(acc, xs : List[X]) {
    match xs {
      Nil => acc
      Cons(x, rest) => go((Cons(x, acc) : List[X]), rest)
    }
  }

  go(Nil, self)
}

///| apply function `f` to each element of List.
pub fn[X] iter(self : List[X]) -> Iter[X] {
  Iter::new(fn {
    yield_ =>
      loop self {
        Nil => IterContinue
        Cons(x, rest) => {
          guard yield_(x) is IterContinue else { return IterEnd }
          continue rest
        }
      }
  })
}

///| construct List from Array.
fn[T] List::from_array(arr : Array[T]) -> List[T] {
  loop arr.length() - 1, List::Nil {
    0, acc => List::Cons(arr[0], acc)
    i, acc => continue i - 1, List::Cons(arr[i], acc)
  }
}

///| collect each elements of List into new Array
fn[T] collect(self : List[T]) -> Array[T] {
  match self {
    Nil => abort("List::collect")
    Cons(x, _) => {
      let ary = Array::make(self.length(), x)
      fn go(xs, idx) {
        match xs {
          (Nil : List[T]) => ()
          Cons(x, xs) => {
            ary[idx] = x
            go(xs, idx + 1)
          }
        }
      }

      go(self, 0)
      ary
    }
  }
}

///| returns the List of those elements that satisfy the predicate.
fn[T] filter(self : List[T], predicate : (T) -> Bool) -> List[T] {
  match self {
    Nil => Nil
    Cons(x, xs) =>
      if predicate(x) {
        Cons(x, xs.filter(predicate))
      } else {
        xs.filter(predicate)
      }
  }
}

///| length of List
fn[T] length(self : List[T]) -> Int {
  match self {
    Nil => 0
    Cons(_, xs) => 1 + xs.length()
  }
}

///|
fn[T] reduce(self : List[T], accumulator : (T, T) -> T, initial : T) -> T {
  match self {
    Nil => initial
    Cons(x, xs) => xs.reduce(accumulator, accumulator(initial, x))
  }
}

///| convert list to string
impl[T : Show] Show for List[T] with output(self : List[T], logger : &Logger) -> Unit {
  fn go(ls : List[T]) {
    match ls {
      Nil => ()
      Cons(x, Nil) => logger..write_string("\{x}")
      Cons(x, xs) => {
        logger..write_string("\{x}, ")
        go(xs)
      }
    }
  }

  logger.write_char('[')
  go(self)
  logger.write_char(']')
}
