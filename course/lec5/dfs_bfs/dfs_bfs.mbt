///|
using @list {type List}

///|
enum IntTree {
  Empty
  Node(Int, IntTree, IntTree)
}

///|
fn dfs_search(target : Int, tree : IntTree) -> Bool {
  match tree {
    Empty => false
    Node(value, left, right) =>
      value == target || dfs_search(target, left) || dfs_search(target, right)
  }
}

///|
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

///|
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

///|
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

///|
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

///|
fn init {
  let tree = construct([
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
  ])
  println("dfs_print: " + dfs_print(tree))
  println(
    "bfs_print: " + bfs_print(Queue::from_list(@list.cons(tree, @list.empty()))),
  )
  if !dfs_search(3, tree) {
    abort("")
  }
  if !bfs_search(3, enqueue(Queue::from_list(@list.empty()), tree)) {
    abort("")
  }
}

// ----- Queue -----

///|
struct Queue[T] {
  front : List[T]
  back : List[T]
}

///|
/// `Queue::default[T]()`
///
/// Create an empty queue 创建空队列
fn[T] Queue::default() -> Queue[T] {
  { front: @list.empty(), back: @list.empty() }
}

///|
/// `from_list[T](front: @immut/list.T[T])`
///
/// Create queue from a list 从列表创建队列
fn[T] Queue::from_list(front : List[T]) -> Queue[T] {
  { front, back: @list.empty() }
}

///|
/// `is_empty[T](q: Queue[T])`
///
/// Check if a queue is empty 检查列表是否为空
fn[T] Queue::is_empty(q : Queue[T]) -> Bool {
  match q {
    { front: Empty, back: Empty } => true
    _ => false
  }
}

///|
/// `list_rev[T](xs: @immut/list.T[T])`
///
/// Reverse a list with tail recursion 基于尾递归的列表反转
fn[T] list_rev(xs : List[T]) -> List[T] {
  fn go(acc, xs : List[T]) {
    match xs {
      Empty => acc
      More(x, tail~) => go((@list.cons(x, acc) : List[T]), tail)
    }
  }

  go(@list.empty(), xs)
}

///|
/// `norm[T](q: Queue[T])`
///
/// Feed `back` into `front` so that `front` always have something 反转队列结构；确保列表头始终有元素
fn[T] norm(q : Queue[T]) -> Queue[T] {
  match q {
    { front: Empty, back: b } => { front: list_rev(b), back: @list.empty() }
    q => q
  }
}

///|
/// `enqueue[T](q: Queue[T], x: T)`
///
/// Add an element to the end of the queue 向队尾添加一个元素
fn[T] enqueue(q : Queue[T], x : T) -> Queue[T] {
  match q {
    { front: f, back: b } => norm({ front: f, back: @list.cons(x, b) })
  }
}

///|
/// `pop[T](q: Queue[T])`
///
/// Remove the first element from the queue 取出队列中第一个元素
fn[T] pop(q : Queue[T]) -> (T?, Queue[T]) {
  match q {
    { front: Empty, back: _ } => (None, q)
    { front: More(x, tail=f), back: b } =>
      (Some(x), norm({ front: f, back: b }))
  }
}
