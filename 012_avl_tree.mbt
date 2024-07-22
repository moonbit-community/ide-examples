// This example is an functional implementation of AVL tree,
// an efficient, balanced binary search tree.

/// The type of an AVL tree storing elements of type `U`
///
/// `Empty` represents an empty node in the AVL tree
/// `Node` represents a node in the AVL tree with left child, value, right child, and height
enum T[U] {
  Empty
  Node(~left : T[U], ~elem : U, ~right : T[U], ~height : Int)
}

/// `height[U](self: T[U])`
///
/// Calculate the height of a tree-like structure.
fn height[U](self : T[U]) -> Int {
  match self {
    Empty => 0
    Node(~height, ..) => height
  }
}

/// `create[U](left: T[U], elem: U, right: T[U])`
///
/// Create a new node with the given left and right subtrees, along with a value of type `U`.
fn create[U](left : T[U], elem : U, right : T[U]) -> T[U] {
  let hl = left.height()
  let hr = right.height()
  Node(~left, ~right, ~elem, height=if hl >= hr { hl + 1 } else { hr + 1 })
}

/// `bal[U](l: T[U], v: U, r: T[U])`
///
/// Perform balancing operation on a avl tree node.
///
/// This function performs a balancing operation on a avl tree node based on the heights
/// of its left and right subtrees. It ensures that the heights of the subtrees are balanced
/// and returns a new avl tree node with appropriate restructuring if necessary.
fn bal[U](l : T[U], v : U, r : T[U]) -> T[U] {
  let hl = l.height()
  let hr = r.height()

  // Left subtree is taller by more than 2 level
  if hl > hr + 2 {
    match l {
      Empty => Empty // impossible
      Node(left=ll, elem=lv, right=lr, ..) =>
        if ll.height() >= lr.height() {
          create(ll, lv, create(lr, v, r))
        } else {
          match lr {
            Empty => Empty // impossible
            Node(left=lrl, elem=lrv, right=lrr, ..) =>
              create(create(ll, lv, lrl), lrv, create(lrr, v, r))
          }
        }
    }
  } else if hr > hl + 2 {
    // Right subtree is taller by more than 2 level
    match r {
      Empty => Empty // impossible
      Node(left=rl, elem=rv, right=rr, ..) =>
        if rr.height() >= rl.height() {
          create(create(l, v, rl), rv, rr)
        } else {
          match rl {
            Empty => Empty // impossible
            Node(left=rll, elem=rlv, right=rlr, ..) =>
              create(create(l, v, rll), rlv, create(rlr, rv, rr))
          }
        }
    }
  } else {
    Node(left=l, elem=v, right=r, height=if hl >= hr { hl + 1 } else { hr + 1 })
  }
}

/// `add[U:Compare](self: T[U], x: U)`
///
/// Add a value to a tree-like structure.
fn add[U : Compare](self : T[U], x : U) -> T[U] {
  match self {
    Empty => Node(left=Empty, elem=x, right=Empty, height=1)
    Node(left=l, elem=v, right=r, ..) as t => {
      let c = x.compare(v)
      if c == 0 {
        t
      } else if c < 0 {
        bal(l.add(x), v, r)
      } else {
        bal(l, v, r.add(x))
      }
    }
  }
}

/// `min_elt[U](self: T[U], default: U)`
///
/// Find the minimum element in a tree-like data structure.
fn min_elt[U](self : T[U], default : U) -> U {
  match self {
    Empty => default
    Node(left=Empty, elem=v, ..) => v
    Node(left=l, elem=v, ..) => l.min_elt(v)
  }
}

/// `remove_min_elt[U](l: T[U], v: U, r: T[U])`
///
/// Remove the minimum element from a avl tree and rebalance the tree.
fn remove_min_elt[U](l : T[U], v : U, r : T[U]) -> T[U] {
  match l {
    Empty => r
    Node(left=ll, elem=lv, right=lr, ..) =>
      bal(remove_min_elt(ll, lv, lr), v, r)
  }
}

/// `internal_merge[U](self: T[U], other: T[U])`
///
/// Merge two AVL trees of the same user-defined type `U` into a new AVL tree.
fn internal_merge[U](self : T[U], other : T[U]) -> T[U] {
  match (self, other) {
    (Empty, t) => t
    (t, Empty) => t
    (_, Node(left=rl, elem=rv, right=rr, ..)) =>
      bal(self, other.min_elt(rv), remove_min_elt(rl, rv, rr))
  }
}

/// `remove[U:Compare](self: T[U], x: U)`
///
/// Removes a value from the AVL tree while maintaining balance
fn remove[U : Compare](self : T[U], x : U) -> T[U] {
  match self {
    Empty => Empty
    Node(left=l, elem=v, right=r, ..) => {
      let c = x.compare(v)
      if c == 0 {
        l.internal_merge(r)
      } else if c < 0 {
        bal(l.remove(x), v, r)
      } else {
        bal(l, v, r.remove(x))
      }
    }
  }
}

/// `to_string[U:Show](self: T[U]) -> String`
///
/// convert the AVL tree to string.
pub fn to_string[U : Show](self : T[U]) -> String {
  match self {
    Empty => "()"
    Node(left=Empty, elem=v, right=Empty, ..) => v.to_string()
    Node(left=l, elem=v, right=r, ..) => "(\(l), \(v), \(r))"
  }
}

/// `mem[U:Compare](self: T[U], x: U)`
///
/// Check if a given element exists in an AVL tree.
fn mem[U : Compare](self : T[U], x : U) -> Bool {
  match self {
    Empty => false
    Node(left=l, elem=v, right=r, ..) => {
      let c = x.compare(v)
      let tree = if c < 0 { l } else { r }
      c == 0 || tree.mem(x)
    }
  }
}

fn main {
  let mut v : T[Int] = Empty // Create an empty AVL tree with Int type
  let iter = 100

  // Add values from 0 to iter-1 to the AVL tree
  let mut i = 0
  while i < iter {
    v = v.add(i)
    i = i + 1
  }
  let height = v.height()
  println("height of the tree: \(height)")

  // you can uncomment it and run it from terminal using moon
  // https://www.moonbitlang.com/en/download/
  // v.print_tree()

  // Check values from 0 to iter-1 in the AVL tree
  let mut j = 0
  while j < iter {
    if not(v.mem(j)) {
      println("impossible")
    }
    j = j + 1
  }

  // Remove values from 0 to iter-1 from the AVL tree
  let mut k = 0
  while k < iter {
    v = v.remove(k)
    k = k + 1
  }
  println("")

  // Tree is empty, removal successful
  match v {
    Empty => println("success")
    Node(_) => println("impossible")
  }
}
