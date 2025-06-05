// This example implements a simple functional queue data structure in MoonBit

///|
struct Queue[T] {
  front : @list.T[T]
  back : @list.T[T]
}

///| Create a queue from a list.
fn[T] from_list(front : @list.T[T]) -> Queue[T] {
  { front, back: @list.empty() }
}

///| Check if a given queue is empty.
fn[T] is_empty(q : Queue[T]) -> Bool {
  match q {
    { front: Empty, back: Empty } => true
    _ => false
  }
}

///| Normalize a queue by reversing its back portion and updating the front and back pointers accordingly.
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
fn[T] Queue::norm(q : Queue[T]) -> Queue[T] {
  match q {
    { front: Empty, back: b } => { front: b.rev(), back: @list.empty() }
    q => q
  }
}

///| Enqueue an element into a queue using pattern matching.
///
/// # Examples
/// ```moonbit
/// let q = { front: Nil, back: Nil }
/// let newQ = enqueue(q, 42)
/// ```
///
/// In the example above, `enqueue` is called to enqueue the element `42` into the queue `q`,
/// resulting in a new queue `newQ` with the element enqueued at the back.
fn[T] Queue::enqueue(q : Queue[T], x : T) -> Queue[T] {
  match q {
    { front: f, back: b } => { front: f, back: b.add(x) }.norm()
  }
}

///| Peek at the front element.
fn[T] Queue::peek(q : Queue[T]) -> T? {
  match q {
    { front: Empty, back: _ } => None
    { front: More(x, ..), back: _ } => Some(x)
  }
}

///| Dequeues an element from the front of the given queue and returns the resulting queue.
fn[T] Queue::dequeue(q : Queue[T]) -> Queue[T]? {
  match q {
    { front: Empty, back: _ } => None
    { front: More(_, tail=f), back: b } => Some({ front: f, back: b }.norm())
  }
}

///| Convert an array to a linked list using recursion.
fn[T] from_array(arr : Array[T]) -> Queue[T] {
  (loop arr.length(), @list.empty() {
    0, acc => acc
    i, acc => continue i - 1, acc.add(arr[i - 1])
  })
  |> from_list
}

///|
fn main {
  let q0 = from_array([])
  if is_empty(q0) {
    let q0_ = q0.enqueue(1)
    guard q0_.peek() is Some(1)
  }
  let q1 = from_array([10, 20, 30])
  guard q1.peek() is Some(x)
  println(x)
  guard q1.dequeue() is Some(q2) && q2.peek() is Some(y)
  println(y)
  let q3 = from_list(@list.empty()).enqueue(1).enqueue(2)
  guard q3.dequeue() is Some(q4) && q4.dequeue() is Some(_q5)
  println("Success")
}
