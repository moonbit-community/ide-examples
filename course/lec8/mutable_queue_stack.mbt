struct Queue {
  mut array: Array[Int]
  mut start: Int
  mut end: Int
  mut length: Int
} derive (Debug, Show)

fn Queue::make() -> Queue {
  {
    array: Array::make(5, 0),
    start: 0,
    end: 0,
    length: 0
  }
}

fn push(self: Queue, t: Int) -> Queue {
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

fn peek(self: Queue) -> Option[Int] {
  if self.end == self.start { None } else { Some(self.array[self.start]) }
}

fn pop(self: Queue) -> Queue {
  self.start = (self.start + 1) % self.array.length()
  self.length = self.length - 1
  self
}

fn length(self: Queue) -> Int {
  self.length
}

fn display(self: Queue) -> Unit {
  for i = 0; i < self.length; i = i + 1 {
    print(self.array[(self.start + i) % self.array.length()].to_string() + " ")
  }
  println("")
}

fn init {
  let queue = Queue::make()

  let _ = queue.push(1).push(5).push(10).pop().pop().pop().push(100).push(1000).push(6).push(7).push(8).push(10)
  println(queue.length())
  queue.display()
}

struct LinkedList[T] {
  mut head: Option[Node[T]]
  mut tail: Option[Node[T]]
} derive(Debug, Show)

struct Node[T] {
  value: T
  mut next: Option[Node[T]]
} derive(Debug, Show)

fn LinkedList::make[T]() -> LinkedList[T] {
  { head: None, tail: None }
}

fn push[T](self: LinkedList[T], value: T) -> LinkedList[T] {
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

fn peek[T](self: LinkedList[T]) -> Option[T] {
  match self.head {
    None => None
    Some(n) => Some(n.value)
  }
}

fn pop[T](self: LinkedList[T]) -> LinkedList[T] {
  match self.head {
    None => ()
    Some(n) => { match n.next {
      None => {
        self.head = None
        self.tail = None
      }
      Some(_) => {
        self.head = n.next
      }
    } }
  }
  self
}

fn length[T](self: LinkedList[T]) -> Int {
  // fn aux(node: Option[Node[T]]) -> Int {
  //   match node {
  //     None => 0
  //     Some(node) => 1 + aux(node.next)
  //   }
  // }
  // aux(self.head)
  fn aux2(node: Option[Node[T]], cumul) -> Int {
    match node {
      None => cumul
      Some(node) => aux2(node.next, 1 + cumul)
    }
  }
  aux2(self.head, 0)
}

fn init {
  let list = LinkedList::make()
  for i = 0; i < 100000; i = i + 1 {
    let _ = list.push(i)
  }
  println(list.length())
}
