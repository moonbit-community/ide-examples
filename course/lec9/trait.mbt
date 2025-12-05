///|
using @list {type List}

// Self stands for the type that implements the trait
// Self代表实现该接口的类型

// These two traits are builtin 下方两个接口是内置接口
// trait Compare {
//   compare(Self, Self) -> Int 
// }

// trait Default {
//   default() -> Self
// }

///|
enum Tree[T] {
  Empty
  Node(T, Tree[T], Tree[T])
}

// T : Compare -> T should fulfill the trait Compare
// T : Compare -> 类型参数T应当满足比较接口

///|
fn[T : Compare] insert(tree : Tree[T], value : T) -> Tree[T] {
  match tree {
    Empty => Node(value, Empty, Empty)
    Node(v, left, right) =>
      if T::compare(value, v) == 0 { // compare can be used 可以使用比较方法
        tree
      } else if T::compare(value, v) < 0 { // compare can be used 可以使用比较方法
        Node(v, insert(left, value), right)
      } else {
        Node(v, left, insert(right, value))
      }
  }
}

///|
struct Queue[T] {
  array : Array[T]
  start : Int
  end : Int
  length : Int
}

// T : Default -> T should fulfill the trait Default
// T : Default -> 类型参数T应当满足Default接口

///|
fn[T : Default] Queue::make() -> Queue[T] {
  {
    array: Array::make(5, T::default()), // default can be used and returns Self (T) 我们可以利用接口中的方法，返回类型为Self，即T
    start: 0,
    end: 0,
    length: 0,
  }
}

///|
struct BoxedInt {
  value : Int
} derive(Compare, Show, Eq) // derive builtin traits 派生内建接口

///|
impl Default for BoxedInt with default() { // defining method is implementing trait 定义方法即实现Default接口
  { value: Int::default() } // using the default of Int 0 使用整数的默认值 0
}

///|
fn init {
  let array : Queue[BoxedInt] = Queue::make()

}

///|
fn BoxedInt::plus_one(b : BoxedInt) -> BoxedInt {
  { value: b.value + 1 }
}

// <Type>:: can be omitted if the first parameter is called self
// 参数名称为self时可省略 <类型>::

///|
fn BoxedInt::plus_two(self : BoxedInt) -> BoxedInt {
  { value: self.value + 2 }
}

///|
fn init {
  let _five = { value: 1 }.plus_one().plus_one().plus_two()
  // uniform function call can be easier to understand
  // 无需进行深层嵌套，方便理解
  let _five = BoxedInt::plus_two(
    BoxedInt::plus_one(BoxedInt::plus_one({ value: 1 })),
  )

}

// defining == operator / implementing trait Eq
// 同时定义比较运算符、实现Eq接口

///|
fn BoxedInt::op_equal(i : BoxedInt, j : BoxedInt) -> Bool {
  i.value == j.value
}

// defining + operator
// 定义加法运算符

///|
impl Add for BoxedInt with add(lhs, rhs) {
  BoxedInt::{ value: lhs.value + rhs.value }
}

///|
fn init {
  let _ = { value: 10 } == { value: 100 } // false
  let _ = { value: 10 } + { value: 100 }
  // { value: 110 }
}

// We define a type Map[Key, Value], which is actually List[(Key, Value)] inside
// 我们定义一个类型Map，其实际值为List[(Key, Value)]

///|
struct Map[Key, Value](List[(Key, Value)])

// Create Map 创建表

///|
fn[Key, Value] Map::make() -> Map[Key, Value] {
  Map(@list.empty())
}

// Put a key-value pair or update the corresponding value 添加键值对，或更新键对应值

///|
fn[Key, Value] put(
  map : Map[Key, Value],
  key : Key,
  value : Value,
) -> Map[Key, Value] {
  let Map(original_map) = map
  Map(@list.cons((key, value), original_map))
}

// Get the value corresponding the given key 获取键对应值

///|
fn[Key : Eq, Value] get(map : Map[Key, Value], key : Key) -> Value? {
  fn aux(list : List[(Key, Value)]) -> Value? {
    match list {
      Empty => None
      More((k, v), tail=tl) =>
        if k == key { // Key implements Eq so == can be used Key实现了Eq接口，因此可以利用==比较
          Some(v)
        } else {
          aux(tl)
        }
    }
  }

  aux(map.0) // Use .0 to get the actual value 利用 .0 取出实际的值
}

// map [ key ]

///|
fn[Key : Eq, Value] Map::op_get(map : Map[Key, Value], key : Key) -> Value? {
  get(map, key)
}

// map [ key ] = value

///|
fn[Key : Eq, Value] Map::op_set(
  map : Map[Key, Value],
  key : Key,
  value : Value,
) -> Map[Key, Value] {
  put(map, key, value)
}

///|
fn init {
  let empty : Map[Int, Int] = Map::make()
  let one = {
    empty[1] = 1
  } // Same as 等价于 let one = Map::op_set(empty, 1, 1)
  let _ = one[1]
  // Same as 等价于 let _ = Map::op_get(one, 1)
}
