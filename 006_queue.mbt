// This example implements a simple functional queue data structure in MoonBit

struct Queue[T] {
  front : @immut/list.List[T]
  back : @immut/list.List[T]
}

/// `from_list[T](front: @immut/list.List[T])`
///
/// Create a queue from a list.
fn from_list[T](front : @immut/list.List[T]) -> Queue[T] {
  { front, back: Nil }
}

/// `is_empty[T](q: Queue[T])`
///
/// Check if a given queue is empty.
fn is_empty[T](q : Queue[T]) -> Bool {
  match q {
    { front: Nil, back: Nil } => true
    _ => false
  }
}

/// `list_rev[T](xs: @immut/list.List[T])`
///
/// Reverse a list using tail-recursive pattern matching.
fn list_rev[T](xs : @immut/list.List[T]) -> @immut/list.List[T] {
  fn go(acc, xs : @immut/list.List[T]) {
    match xs {
      Nil => acc
      Cons(x, rest) => go((Cons(x, acc) : @immut/list.List[T]), rest)
    }
  }

  go(Nil, xs)
}

/// `norm[T](q: Queue[T])`
///
/// Normalize a queue by reversing its back portion and updating the front and back pointers accordingly.
///
/// # Examples
/// ```moonbit
/// let originalQueue = { front: [1, 2, 3], back: [4, 5, 6] }
/// let normalizedQueue = norm(originalQueue)
/// // normalizedQueue will be { front: [6, 5, 4], back: [3, 2, 1] }
///
/// let unchangedQueue = { front: [7, 8], back: Nil }
/// let result = norm(unchangedQueue)
/// // result will be { front: [7, 8], back: Nil }
///
/// let emptyQueue = { front: Nil, back: Nil }
/// let result = norm(emptyQueue)
/// // result will be { front: Nil, back: Nil }
/// ```
fn norm[T](q : Queue[T]) -> Queue[T] {
  match q {
    { front: Nil, back: b } => { front: list_rev(b), back: Nil }
    q => q
  }
}

/// `enqueue[T](q: Queue[T], x: T)`
///
/// Enqueue an element into a queue using pattern matching.
///
/// # Examples
/// ```moonbit
/// let q = { front: Nil, back: Nil }
/// let newQ = enqueue(q, 42)
/// ```
///
/// In the example above, `enqueue` is called to enqueue the element `42` into the queue `q`,
/// resulting in a new queue `newQ` with the element enqueued at the back.
fn enqueue[T](q : Queue[T], x : T) -> Queue[T] {
  match q {
    { front: f, back: b } => norm({ front: f, back: Cons(x, b) })
  }
}

/// `peek[T](q: Queue[T])`
///
/// Peek at the front element.
fn peek[T](q : Queue[T]) -> T? {
  match q {
    { front: Nil, back: _ } => None
    { front: Cons(x, _), back: _ } => Some(x)
  }
}

/// `dequeue[T](q: Queue[T])`
///
/// Dequeues an element from the front of the given queue and returns the resulting queue.
fn dequeue[T](q : Queue[T]) -> Queue[T]? {
  match q {
    { front: Nil, back: _ } => None
    { front: Cons(_, f), back: b } => Some(norm({ front: f, back: b }))
  }
}

/// `to_list[T](self: Array[T])`
///
/// Convert an array to a linked list using recursion.
fn Queue::from_array[T](arr : Array[T]) -> Queue[T] {
  loop arr.length(), @immut/list.List::Nil {
    0, acc => acc
    i, acc => continue i - 1, @immut/list.List::Cons(arr[i - 1], acc)
  }
  |> from_list
}

fn main {
  let q0 = Queue::from_array([])
  if is_empty(q0) {
    let q0 = enqueue(q0, 1)
    match peek(q0) {
      Some(x) => println(x)
      _ => println("error")
    }
  }
  let q1 = Queue::from_array([10, 20, 30])
  match peek(q1) {
    Some(x) => println(x)
    None => println("error")
  }
  match dequeue(q1) {
    None => abort("error")
    Some(q2) =>
      match peek(q2) {
        Some(x) => println(x)
        None => println("error")
      }
  }
  let q3 = enqueue(enqueue(from_list(Nil), 1), 2)
  match dequeue(q3) {
    Some(q4) =>
      match dequeue(q4) {
        Some(_q5) => println("success")
        None => println("error")
      }
    None => println("error")
  }
}
