enum IntTree {
  Empty
  Node(Int, IntTree, IntTree)
}

fn dfs_search(target : Int, tree : IntTree) -> Bool {
  match tree {
    Empty => false
    Node(value, left, right) =>
      value == target || dfs_search(target, left) || dfs_search(target, right)
  }
}

fn bfs_search(target : Int, queue : Queue[IntTree]) -> Bool {
  match pop(queue) {
    // if the queue is empty, abort search 若队列为空，结束搜索
    (None, _) => false
    // else, pop a tree and process 否则，取出一棵树并进行操作
    (Some(head), tail) =>
      match head {
        // if the tree is empty, process the rest of the queue 若树为空树，则对剩余队列进行操作
        Empty => bfs_search(target, tail)
        // else check the root node 否则，检查根节点
        Node(value, left, right) =>
          if value == target {
            true
            // if it does not match the target, add subtrees into the queue 如果不是搜索目标，将子树加入队列
          } else {
            bfs_search(target, enqueue(enqueue(tail, left), right))
          }
      }
  }
}

fn dfs_print(tree : IntTree) -> String {
  match tree {
    Empty => ""
    Node(value, left, right) => {
      let value_str = value.to_string()
      let left_str = dfs_print(left)
      let right_str = dfs_print(right)
      // modify the order to get different results 修改顺序以获得不同输出
      left_str + value_str + " " + right_str
    }
  }
}

fn bfs_print(queue : Queue[IntTree]) -> String {
  match pop(queue) {
    (None, _) => ""
    (Some(v), tail) =>
      match v {
        Empty => bfs_print(tail)
        Node(value, left, right) =>
          value.to_string() +
          " " +
          bfs_print(enqueue(enqueue(tail, left), right))
      }
  }
}

fn construct(array : Array[Int?]) -> IntTree {
  fn aux(n : Int) -> IntTree {
    if n >= array.length() {
      Empty
    } else {
      match array[n] {
        Some(value) => Node(value, aux(n * 2 + 1), aux(n * 2 + 2))
        None => Empty
      }
    }
  }

  aux(0)
}

fn init {
  let tree = construct(
    [
      Some(0),
      Some(1),
      Some(2),
      Some(3),
      Some(4),
      None,
      None,
      None,
      None,
      None,
      Some(5),
    ],
  )
  println("dfs_print: " + dfs_print(tree))
  println("bfs_print: " + bfs_print(from_list(Cons(tree, Nil))))
  if dfs_search(3, tree).not() {
    abort("")
  }
  if bfs_search(3, enqueue(from_list(Nil), tree)).not() {
    abort("")
  }
}

// ----- Queue -----

struct Queue[T] {
  front : @immut/list.T[T]
  back : @immut/list.T[T]
}

/// `Queue::default[T]()`
///
/// Create an empty queue 创建空队列
fn Queue::default[T]() -> Queue[T] {
  { front: Nil, back: Nil }
}

/// `from_list[T](front: @immut/list.T[T])`
///
/// Create queue from a list 从列表创建队列
fn Queue::from_list[T](front : @immut/list.T[T]) -> Queue[T] {
  { front, back: Nil }
}

/// `is_empty[T](q: Queue[T])`
///
/// Check if a queue is empty 检查列表是否为空
fn Queue::is_empty[T](q : Queue[T]) -> Bool {
  match q {
    { front: Nil, back: Nil } => true
    _ => false
  }
}

/// `list_rev[T](xs: @immut/list.T[T])`
///
/// Reverse a list with tail recursion 基于尾递归的列表反转
fn list_rev[T](xs : @immut/list.T[T]) -> @immut/list.T[T] {
  fn go(acc, xs : @immut/list.T[T]) {
    match xs {
      Nil => acc
      Cons(x, rest) => go((Cons(x, acc) : @immut/list.T[T]), rest)
    }
  }

  go(Nil, xs)
}

/// `norm[T](q: Queue[T])`
///
/// Feed `back` into `front` so that `front` always have something 反转队列结构；确保列表头始终有元素
fn norm[T](q : Queue[T]) -> Queue[T] {
  match q {
    { front: Nil, back: b } => { front: list_rev(b), back: Nil }
    q => q
  }
}

/// `enqueue[T](q: Queue[T], x: T)`
///
/// Add an element to the end of the queue 向队尾添加一个元素
fn enqueue[T](q : Queue[T], x : T) -> Queue[T] {
  match q {
    { front: f, back: b } => norm({ front: f, back: Cons(x, b) })
  }
}

/// `pop[T](q: Queue[T])`
///
/// Remove the first element from the queue 取出队列中第一个元素
fn pop[T](q : Queue[T]) -> (T?, Queue[T]) {
  match q {
    { front: Nil, back: _ } => (None, q)
    { front: Cons(x, f), back: b } => (Some(x), norm({ front: f, back: b }))
  }
}
