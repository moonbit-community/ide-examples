///|
struct Queue {
  mut array : Array[Int]
  mut start : Int
  mut end : Int
  mut length : Int
} derive(Show)

///|
fn Queue::make() -> Queue {
  { array: Array::make(5, 0), start: 0, end: 0, length: 0 }
}

///|
fn Queue::push(self : Queue, t : Int) -> Queue {
  if self.length == self.array.length() {
    let new_array = Array::make(self.array.length() * 2, 0)
    for i = 0; i < self.array.length(); i = i + 1 {
      new_array[i] = self.array[(self.start + i) % self.array.length()]
    }
    self.start = 0
    self.end = self.array.length()
    self.array = new_array
    self.push(t)
  } else {
    self.array[self.end] = t
    self.end = (self.end + 1) % self.array.length()
    self.length = self.length + 1
    self
  }
}

///|
fn Queue::peek(self : Queue) -> Int? {
  if self.end == self.start {
    None
  } else {
    Some(self.array[self.start])
  }
}

///|
fn Queue::pop(self : Queue) -> Queue {
  self.start = (self.start + 1) % self.array.length()
  self.length = self.length - 1
  self
}

///|
fn Queue::length(self : Queue) -> Int {
  self.length
}

///|
fn Queue::display(self : Queue) -> Unit {
  for i = 0; i < self.length; i = i + 1 {
    println(
      self.array[(self.start + i) % self.array.length()].to_string() + " ",
    )
  }
  println("")
}

///|
fn init {
  let queue = Queue::make()
  let _ = queue
    .push(1)
    .push(5)
    .push(10)
    .pop()
    .pop()
    .pop()
    .push(100)
    .push(1000)
    .push(6)
    .push(7)
    .push(8)
    .push(10)
  println(queue.length())
  queue.display()
}

///|
struct LinkedList[T] {
  mut head : Node[T]?
  mut tail : Node[T]?
} derive(Show)

///|
struct Node[T] {
  value : T
  mut next : Node[T]?
} derive(Show)

///|
fn[T] LinkedList::make() -> LinkedList[T] {
  { head: None, tail: None }
}

///|
fn[T] LinkedList::push(self : LinkedList[T], value : T) -> LinkedList[T] {
  let node = { value, next: None }
  match self.tail {
    None => {
      self.head = Some(node)
      self.tail = Some(node)
    }
    Some(n) => {
      n.next = Some(node)
      self.tail = Some(node)
    }
  }
  self
}

///|
fn[T] LinkedList::peek(self : LinkedList[T]) -> T? {
  match self.head {
    None => None
    Some(n) => Some(n.value)
  }
}

///|
fn[T] LinkedList::pop(self : LinkedList[T]) -> LinkedList[T] {
  match self.head {
    None => ()
    Some(n) =>
      match n.next {
        None => {
          self.head = None
          self.tail = None
        }
        Some(_) => self.head = n.next
      }
  }
  self
}

///|
fn[T] LinkedList::length(self : LinkedList[T]) -> Int {
  // fn aux(node: Option[Node[T]]) -> Int {
  //   match node {
  //     None => 0
  //     Some(node) => 1 + aux(node.next)
  //   }
  // }
  // aux(self.head)
  fn aux2(node : Node[T]?, cumul) -> Int {
    match node {
      None => cumul
      Some(node) => aux2(node.next, 1 + cumul)
    }
  }

  aux2(self.head, 0)
}

///|
fn init {
  let list = LinkedList::make()
  for i = 0; i < 100000; i = i + 1 {
    let _ = list.push(i)

  }
  println(list.length())
}
