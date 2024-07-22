// This example is an implemention of Hash Array Mapped Trie (HAMT) in MoonBit
// HAMT is an efficient, memory saving, functional hash map data structure.
//
// Some references:
// - <https://handwiki.org/wiki/Hash%20array%20mapped%20trie>
// - <https://lampwww.epfl.ch/papers/idealhashtrees.pdf>

/// `ctpop(n: Int)`
///
/// Count the number of set bits (1s) in a 32-bit integer.
fn ctpop(n : Int) -> Int {
  // extract the lower bit of every 2-bit group
  let low_of_2bits = 0x55555555
  // count the number of "1"s in every 2-bit group
  // store the result in the same 2-bit group
  let c2 = n.land(low_of_2bits) + n.lsr(1).land(low_of_2bits)
  // count the number of "1"s in every 4-bit group (i.e. two 2-bit groups),
  // store the result in the same 4-bit group
  let low_of_4bits = 0x33333333
  let c4 = c2.land(low_of_4bits) + c2.lsr(2).land(low_of_4bits)
  // similarly for every 8-bit group
  let low_of_8bits = 0x0f0f0f0f
  let c8 = c4.land(low_of_8bits) + c4.lsr(4).land(low_of_8bits)
  // 16-bit group.
  // there will be only two groups left, without rist of overlapping,
  // so there's no need to clean the unused higher bits
  let c16 = c8 + c8.lsr(8)
  // the final 32-bit group
  // [ctpop(x) <= 32], so only the last 6 bits are meaningful
  let lower_6bits = 63 // 0x3f
  (c16 + c16.lsr(16)).land(lower_6bits)
}

/// a simple bit set to store a set of integers less than 32
struct Bitset {
  rep : Int
}

let empty_bitset : Bitset = { rep: 0 }

/// `has(self: Bitset, idx: Int)`
///
/// Check if the given index is present in the bitset.
fn has(self : Bitset, idx : Int) -> Bool {
  self.rep.land((1).lsl(idx)) != 0
}

/// `index_of(self: Bitset, idx: Int)`
///
/// Get the index of the bit in the bitset.
fn index_of(self : Bitset, idx : Int) -> Int {
  let items_below_idx = self.rep.land((1).lsl(idx) - 1)
  ctpop(items_below_idx)
}

/// `add(self: Bitset, idx: Int)`
///
/// Add a new index to the bitset.
fn add(self : Bitset, idx : Int) -> Bitset {
  { rep: self.rep.lor((1).lsl(idx)) }
}

/// `remove(self: Bitset, idx: Int)`
///
/// Remove an index from the bitset.
pub fn remove(self : Bitset, idx : Int) -> Bitset {
  { rep: self.rep.lxor((1).lsl(idx)) }
}

/// A sparse array with at most 32 elements, where elements are not required to have contiguous index.
/// Empty elements don't waste any space, without losing constant-time access
struct Sparse_Array[X] {
  // record which elements are present
  elem_info : Bitset
  data : Array[X]
}

/// `make_sparse_array[X](idx: Int, value: X)`
///
/// Create a new sparse array with a single element.
fn make_sparse_array[X](idx : Int, value : X) -> Sparse_Array[X] {
  { elem_info: empty_bitset.add(idx), data: [value] }
}

/// `has(self: Sparse_Array[X], idx: Int)`
///
/// Check if an element exists at the given index in the sparse array.
pub fn has[X](self : Sparse_Array[X], idx : Int) -> Bool {
  self.elem_info.has(idx)
}

/// `op_get(self: Sparse_Array[X], idx: Int)`
///
/// Get an element at the given index in the sparse array.
fn op_get[X](self : Sparse_Array[X], idx : Int) -> X? {
  if self.elem_info.has(idx) {
    Some(self.data[self.elem_info.index_of(idx)])
  } else {
    None
  }
}

/// `add[X](self: Sparse_Array[X], idx: Int, value: X)`
///
/// Add a new element into the sparse array.
fn add[X](self : Sparse_Array[X], idx : Int, value : X) -> Sparse_Array[X] {
  let new_len = self.data.length() + 1
  let pos_of_new_item = self.elem_info.index_of(idx)
  let new_data = Array::make(new_len, value)
  let mut i = 0
  while i < pos_of_new_item {
    new_data[i] = self.data[i]
    i = i + 1
  }
  new_data[i] = value
  i = i + 1
  while i < new_len {
    new_data[i] = self.data[i - 1]
    i = i + 1
  }
  { elem_info: self.elem_info.add(idx), data: new_data }
}

/// `replace[X](self: Sparse_Array[X], idx: Int, value: X)`
///
/// Replace an existing element in the sparse array.
fn replace[X](self : Sparse_Array[X], idx : Int, value : X) -> Sparse_Array[X] {
  let len = self.data.length()
  let pos_of_new_item = self.elem_info.index_of(idx)
  let new_data = Array::make(len, value)
  for i = 0; i < len; i = i + 1 {
    new_data[i] = if i == pos_of_new_item { value } else { self.data[i] }
  }
  { elem_info: self.elem_info, data: new_data }
}

/// Hash-Array-Mapped-Trie (HAMT) is a persistent hash-table data structure.
/// It is a trie over the hash of keys (i.e. strings of binary digits)
///
/// Every level in a HAMT can have up to 32 branches (5 digits),
/// so HAMT has a tree height of at most 7,
/// and is more efficient compared to most other tree data structures.
///
/// HAMT uses the bitmap-based sparse array above to avoid space waste
enum HAMT[K, V] {
  Empty
  Leaf(K, V) // optimize for the case of no collision
  Collision(Bucket[K, V]) // use a list of buckets to resolve collision
  Branch(Sparse_Array[HAMT[K, V]])
}

enum Bucket[K, V] {
  Just_One(K, V) // must be non-empty
  More(K, V, Bucket[K, V])
}

/// The number of bits consumed at every [Branch] node
let segment_length : Int = 5

/// `make[K, V]()`
///
/// Make an empty HAMT.
fn make[K, V]() -> HAMT[K, V] {
  Empty
}

/// `find_with_hash[K: Eq, V](self: HAMT[K, V], key: K, hash: Int)`
///
/// Find a value associated with the given key in the Hash Array Mapped Trie (HAMT).
fn find[K : Eq + Hash, V](self : HAMT[K, V], key : K) -> V? {
  loop self, key.hash() {
    Empty, _ => None
    Leaf(key1, value), _ => if key == key1 { Some(value) } else { None }
    Collision(bucket), _ => bucket.find(key)
    Branch(children), hash => {
      // get the first segment (lower 5 bits) of the hash value
      let idx = hash.land((1).lsl(segment_length) - 1)
      match children[idx] {
        Some(child) =>
          // when searching recursively, drop the segment just used
          continue child, hash.lsr(segment_length)
        None => None
      }
    }
  }
}

/// `add_with_hash[K: Eq, V](self: HAMT[K, V], key: K, depth: Int, hash: Int, value: V)`
///
/// Add a key-value pair to the Hash Array Mapped Trie (HAMT).
/// # Arguments
/// * `self` - The HAMT to add the key-value pair to.
/// * `key` - The key to add.
/// * `depth` - The current depth within the trie.
/// * `hash` - The precomputed hash value of the key.
/// * `value` - The value to associate with the key.
fn add_with_hash[K : Eq, V](
  self : HAMT[K, V],
  key : K,
  depth : Int,
  hash : Int,
  value : V
) -> HAMT[K, V] {
  // make sure leaf nodes always appear at the bottom of the tree
  fn make_leaf(depth : Int, key : K, hash : Int, value : V) {
    if depth >= 32 {
      HAMT::Leaf(key, value)
    } else {
      let idx = hash.land((1).lsl(segment_length) - 1)
      let child = make_leaf(
        depth + segment_length,
        key,
        hash.lsr(segment_length),
        value,
      )
      HAMT::Branch(make_sparse_array(idx, child))
    }
  }

  match self {
    Empty => make_leaf(depth, key, hash, value)
    Leaf(key1, value1) =>
      if key == key1 {
        Leaf(key, value)
      } else {
        Collision(More(key, value, Just_One(key1, value1)))
      }
    Collision(bucket) => Collision(bucket.add(key, value))
    Branch(children) => {
      let idx = hash.land((1).lsl(segment_length) - 1)
      match children[idx] {
        Some(child) => {
          let child = child.add_with_hash(
            key,
            depth + segment_length,
            hash.lsr(segment_length),
            value,
          )
          Branch(children.replace(idx, child))
        }
        None => {
          let child = make_leaf(
            depth + segment_length,
            key,
            hash.lsr(segment_length),
            value,
          )
          Branch(children.add(idx, child))
        }
      }
    }
  }
}

/// `add[K: Eq + Hash, V](self: HAMT[K, V], key: K, value: V)`
///
/// Add a key-value pair to the Hash Array Mapped Trie (HAMT).
fn add[K : Eq + Hash, V](self : HAMT[K, V], key : K, value : V) -> HAMT[K, V] {
  self.add_with_hash(key, 0, key.hash(), value)
}

/// `size[K, V](self: HAMT[K, V])`
///
/// Calculate the size (number of elements) of the Hash Array Mapped Trie (HAMT).
pub fn size[K, V](self : HAMT[K, V]) -> Int {
  match self {
    Empty => 0
    Leaf(_) => 1
    Collision(bucket) => bucket.size()
    Branch(children) => {
      let mut total_size = 0
      for i = 0; i < children.data.length(); i = i + 1 {
        total_size = total_size + children.data[i].size()
      }
      total_size
    }
  }
}

/// `count_collision[K, V](self: HAMT[K, V])`
///
/// Count the number of collision nodes in the Hash Array Mapped Trie (HAMT).
fn count_collision[K, V](self : HAMT[K, V]) -> Int {
  match self {
    Empty | Leaf(_) => 0
    Collision(bucket) => bucket.size()
    Branch(children) => {
      let mut total_count = 0
      for i = 0; i < children.data.length(); i = i + 1 {
        total_count = total_count + children.data[i].count_collision()
      }
      total_count
    }
  }
}

/// `println[K: Show, V: Show](self: HAMT[K, V], indent: Int)`
///
/// Print the contents of the Hash Array Mapped Trie (HAMT) with indentation.
pub fn print_hamt[K : Show, V : Show](self : HAMT[K, V], indent : Int) -> Unit {
  match self {
    Empty => println("Empty")
    Leaf(k, v) => println("\(k) => \(v)")
    Collision(bucket) => print_bucket(bucket)
    Branch(children) =>
      if children.data.length() == 0 {
        println("Empty")
      } else {
        println("Branch")
        for i = 0; i < 32; i = i + 1 {
          match children[i] {
            Some(child) => {
              for n = 0; n < indent; n = n + 1 {
                println(' ')
              }
              println("#\(i)")
              for n = 0; n < indent; n = n + 1 {
                println(' ')
              }
              println("- ")
              child.print_hamt(indent + 2)
            }
            None => ()
          }
        }
      }
  }
}

/// `find[K: Eq, V](self: Bucket[K, V], key: K)`
///
/// Find a value associated with the given key in a Bucket.
fn find[K : Eq, V](self : Bucket[K, V], key : K) -> V? {
  match self {
    Just_One(key1, value) => if key == key1 { Some(value) } else { None }
    More(key1, value, rest) =>
      if key == key1 {
        Some(value)
      } else {
        rest.find(key)
      }
  }
}

/// `add[K: Eq, V](self: Bucket[K, V], key: K, value: V)`
///
/// Add a key-value pair to a Bucket.
fn add[K : Eq, V](self : Bucket[K, V], key : K, value : V) -> Bucket[K, V] {
  match self {
    Just_One(key1, _) =>
      if key == key1 {
        Just_One(key, value)
      } else {
        More(key, value, self)
      }
    More(key1, value1, rest) =>
      if key == key1 {
        More(key, value, rest)
      } else {
        More(key1, value1, rest.add(key, value))
      }
  }
}

/// `size[K, V](self: Bucket[K, V])`
///
/// Calculate the size (number of elements) of a Bucket.
fn size[K, V](self : Bucket[K, V]) -> Int {
  match self {
    Just_One(_) => 1
    More(_, _, rest) => rest.size() + 1
  }
}

/// `println[K: Show, V: Show](self: Bucket[K, V])`
///
/// Print the contents of a Bucket.
fn print_bucket[K : Show, V : Show](self : Bucket[K, V]) -> Unit {
  match self {
    Just_One(k, v) => println("\(k) => \(v)")
    More(k, v, rest) => {
      println("\(k) => \(v); ")
      print_bucket(rest)
    }
  }
}

fn main {
  let n = 100000
  let mut hamt = make()
  for i = 0; i < n; i = i + 1 {
    hamt = hamt.add(i, i)
  }
  let collision_count = hamt.count_collision()
  println("number of collision: \(collision_count)")
  // uncomment this to see the tree (large trees may not display properly)
  // hamt.println(0)

  let mut is_ok = true
  for i = 0; i < n; i = i + 1 {
    match hamt.find(i) {
      Some(v) =>
        if v != i {
          is_ok = false
          println("\(i): wrong value")
        }
      None => {
        is_ok = false
        println("\(i): not found")
      }
    }
  }
  if is_ok {
    println("OK!")
  }
}
