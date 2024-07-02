struct Map[K, V] {
  get : (K) -> Option[V]
  put : (K, V) -> Unit
  remove : (K) -> Unit
  size : () -> Int
  debug_map : () -> Unit
}

pub fn Map::get[K, V](map : Map[K, V], key : K) -> Option[V] {
  (map.get)(key)
}

pub fn Map::put[K, V](map : Map[K, V], key : K, value : V) -> Unit {
  (map.put)(key, value)
}

pub fn Map::remove[K, V](map : Map[K, V], key : K) -> Unit {
  (map.remove)(key)
}

pub fn Map::size[K, V](map : Map[K, V]) -> Int {
  (map.size)()
}

pub fn Map::is_empty[K, V](map : Map[K, V]) -> Bool {
  (map.size)() == 0
}

pub fn Map::contains[K, V](map : Map[K, V], key : K) -> Bool {
  match (map.get)(key) {
    Some(_) => true
    None => false
  }
}

priv struct Entry[K, V] {
  key : K
  mut value : V
} derive(Default, Debug)

priv struct HT_open[K, V] {
  mut values : Array[Entry[K, V]]
  mut occupied : Array[Status]
  mut length : Int
  mut size : Int
} derive(Debug)

enum Status {
  Empty
  Deleted
  Occupied
} derive(Debug)

/// HashMap based on open addressing 哈希表：开放地址实现
/// 
/// Invariant : there's no empty slots between where a key should be stored and where it is stored
/// 条件：从键的哈希值开始直到键的实际存储位置之间没有任何的空槽
pub fn Map::hash_open_address[K : Hash + Eq + Default + Debug, V : Default + Debug]() ->
     Map[K, V] {
  let initial_length = 10
  // load of the hash map 哈希表的负载
  let load = 0.75
  let map : HT_open[K, V] = {
    values: Array::make(initial_length, Entry::default()),
    occupied: Array::make(initial_length, Empty),
    length: initial_length,
    size: 0,
  }

  // search to the right from where the key should be stored
  // return where it is stored (key encountered) or where it can be stored (the first empty slot encountered)
  // 从键的哈希值向右查找，返回键或第一个找到的空槽位置的索引
  fn find_slot(key : K) -> Int {
    let hash = key.hash()
    loop hash.mod_u(map.length) {
      i =>
        if physical_equal(map.occupied[i], Occupied) {
          if map.values[i].key == key {
            break i
          } else {
            continue (i + 1).mod_u(map.length)
          }
        } else {
          break i
        }
    }
  }

  fn resize() {
    let { values, occupied, length, .. } = map
    map.length = length * 2
    map.values = Array::make(map.length, Entry::default())
    map.occupied = Array::make(map.length, Empty)
    map.size = 0
    for i = 0; i < length; i = i + 1 {
      if physical_equal(occupied[i], Occupied) {
        put(values[i].key, values[i].value)
      }
    }
  }

  fn get(key : K) -> Option[V] {
    let index = find_slot(key)
    if physical_equal(map.occupied[index], Occupied) {
      Some(map.values[index].value)
    } else {
      None
    }
  }

  fn put(key : K, value : V) -> Unit {
    let index = find_slot(key)
    if physical_equal(map.occupied[index], Occupied) {
      map.values[index].value = value
    } else {
      map.occupied[index] = Occupied
      map.values[index] = { key, value }
      map.size = map.size + 1
    }
    if map.size.to_double() / map.length.to_double() >= load {
      resize()
    }
  }

  fn remove(key : K) -> Unit {
    let index = find_slot(key)
    if physical_equal(map.occupied[index], Occupied) {
      map.values[index] = default()
      map.occupied[index] = Deleted
      map.size = map.size - 1
    }
  }

  fn size() -> Int {
    map.size
  }

  fn debug_map() -> Unit {
    debug(map)
  }

  { get, put, remove, size, debug_map }
}

priv struct HT_bucket[K, V] {
  mut values : Array[@immut/list.List[Entry[K, V]]]
  mut length : Int
  mut size : Int
} derive(Debug)

/// HashMap based on linked list 哈希表：链表实现
pub fn Map::hash_bucket[K : Hash + Eq + Debug, V : Debug]() -> Map[K, V] {
  let initial_length = 10
  let load = 0.75
  let map : HT_bucket[K, V] = {
    values: Array::make(initial_length, Nil),
    size: 0,
    length: initial_length,
  }
  fn resize() {
    let { values, length, .. } = map
    map.length = length * 2
    map.values = Array::make(map.length, Nil)
    map.size = 0
    for i = 0; i < length; i = i + 1 {
      loop values[i] {
        Cons(entry, rest) => {
          put(entry.key, entry.value)
          continue rest
        }
        Nil => ()
      }
    }
  }

  fn get(key : K) -> Option[V] {
    let hash = key.hash()
    loop map.values[hash.mod_u(map.length)] {
      Cons(entry, rest) =>
        if entry.key == key {
          break Some(entry.value)
        } else {
          continue rest
        }
      Nil => break None
    }
  }

  fn put(key : K, value : V) -> Unit {
    let hash = key.hash()
    let index = hash.mod_u(map.length)
    loop map.values[index] {
      Nil =>
        map.values[index] = {
          map.size = map.size + 1
          Cons({ key, value }, map.values[index])
        }
      Cons(entry, rest) => {
        if entry.key != key {
          continue rest
        }
        entry.value = value
      }
    }
    if map.size.to_double() / map.length.to_double() >= load {
      resize()
    }
  }

  fn remove(key : K) -> Unit {
    let hash = key.hash()
    let index = hash.mod_u(map.length)
    loop map.values[index], @immut/list.List::Nil {
      Cons(entry, rest), cumul => {
        if entry.key != key {
          continue rest,
            Cons(entry, cumul)
        }
        map.values[index] = loop cumul, rest {
          Nil, rest => break rest
          Cons(hd, tl), rest => continue tl, Cons(hd, rest)
        }
        map.size = map.size - 1
      }
      Nil, _ => ()
    }
  }

  fn size() -> Int {
    map.size
  }

  fn debug_map() -> Unit {
    debug(map)
  }

  { get, put, remove, size, debug_map }
}

test "open addressing" {
  let map : Map[Int, Int] = Map::hash_open_address()
  test1(map)
}

test "bucket" {
  let map : Map[Int, Int] = Map::hash_bucket()
  test1(map)
}

fn test1(map : Map[Int, Int]) -> Unit {
  let start = 0
  let end = 200
  for i = start; i < end; i = i + 1 {
    map.put(i, i)
  }
  assert_true(map.size() == end)
  for i = start; i < end; i = i + 1 {
    assert_true(map.contains(i))
    assert_true(map.get(i) == Some(i))
  }
  for i = start; i < end; i = i + 2 {
    map.remove(i)
  }
  // (map.debug_map)()
  for i = start + 1; i < end; i = i + 2 {
    assert_true(map.contains(i))
    map.remove(i)
  }
  assert_true(map.is_empty())
}

fn assert_true(b : Bool) -> Unit {
  if b.not() {
    abort("")
  }
}
