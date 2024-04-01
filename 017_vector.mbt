// This example implements an imperative vector data structure in MoonBit,
// which support `O(1)` random access and amortized `O(1)` `push`/`pop` operations

struct Vector[X] {
  mut data : Array[X]
  mut len : Int
}

/// `to_string[X : Show](self : Vector[X]) -> String`
///
/// convert a vector to string, type inside the vector must have method `to_string`
fn to_string[T : Show](self : Vector[T]) -> String {
  let mut str = "["
  for i = 0; i <= self.length(); i = i + 1 {
    str = str + (match self[i] {
      Some(x) => x.to_string()
      None => "]"
    })
  }
  str
}

/// `length[X](self : Vector[X])`
///
/// Get length of a vector
fn length[X](self : Vector[X]) -> Int {
  self.len
}

/// `capacity[X](self : Vector[X])`
///
/// Get capacity of a vector
fn capacity[X](self : Vector[X]) -> Int {
  self.data.length()
}

/// `Vector::new_with_default[X](len : Int, default : X)`
///
/// Create a vector with length `len`, filling with value `default`
fn Vector::new_with_default[X](len : Int, default : X) -> Vector[X] {
  { data: Array::make(len, default), len }
}

/// Vector::new[X : Default](len : Int)
///
/// Create a vector with length `len`, filling with default value of type `X`
fn Vector::new[X : Default](len : Int) -> Vector[X] {
  Vector::new_with_default(len, X::default())
}

/// `op_get[X](self : Vector[X], i : Int)`
///
/// Get the ith element of vector
fn op_get[X](self : Vector[X], i : Int) -> Option[X] {
  if i < self.len {
    Some(self.data[i])
  } else {
    None
  }
}

/// push_back_with_default[X](self : Vector[X], elem : X, default : X)
///
/// Push back `elem` to a vector, `default` will be used to fill the additional space
fn push_back_with_default[X](self : Vector[X], elem : X, default : X) -> Unit {
  if self.len < self.capacity() {
    self.data[self.len] = elem
    self.len = self.len + 1
  } else {
    let old_cap = self.capacity()
    let new_cap = if old_cap == 0 {
      10
    } else {
      old_cap * 2
    }
    let new_data = Array::make(new_cap, default)
    for i = 0; i < self.len; i = i + 1 {
      new_data[i] = self.data[i]
    }
    new_data[self.len] = elem
    self.data = new_data
    self.len = self.len + 1
  }
}

/// push_back[X : Default](self : Vector[X], elem : X)
///
/// Push back `elem` to a vector, default value of type `X` will be used to fill the additional space
fn push_back[X : Default](self : Vector[X], elem : X) -> Unit {
  self.push_back_with_default(elem, X::default())
}

struct T {
  x : Int
} derive(Debug, Show)

fn T::default() -> T {
  { x: 0 }
}

fn init {
  let v1 : Vector[Int] = Vector::new(5)
  println(v1)
  v1.push_back(42)
  println(v1)
  let v2 : Vector[T] = Vector::new(5)
  println(v2)
  v2.push_back({ x: 42 })
  println(v2)
}

