// This example is a MoonBit implementation of skew binary list,
// an efficient functional list-like data structure with `O(1)` push/pop and `O(log(N))` random access
//
// See Chris Okasaki's book "Purely functional data structure" for more details

fn main {
  let xs = BList::from_array([1, 2, 3, 4, 5])
  debug(xs)
  loop xs.pop() {
    None => ()
    Some((x, xs)) => {
      debug(x)
      continue xs.pop()
    }
  }
  // note that [xs] is untouched since [BList] is functional
  let xs = xs.push(6).push(7)
  debug(xs)
  for i = 0; i < xs.length(); i = i + 1 {
    debug(xs[i])
  }
}

/// The type of a non-empty *complete* binary tree.
enum Tree[X] {
  Leaf(X)
  Branch(X, Tree[X], Tree[X])
}

/// get the in-order nth element in a binary tree.
///
/// `tree_size` is the size of the tree,
/// which must be `2^tree_height - 1` since the tree is complete
///
/// This operation is `O(log(N))` thanks to completeness of the tree
fn nth[X](self : Tree[X], tree_size : Int, idx : Int) -> X {
  match self {
    Leaf(x) => x // [idx] must be 0
    Branch(first, left, right) =>
      if idx == 0 {
        first
      } else {
        let subtree_size = (tree_size - 1) / 2
        if idx - 1 < subtree_size {
          left.nth(subtree_size, idx - 1)
        } else {
          right.nth(subtree_size, idx - 1 - subtree_size)
        }
      }
  }
}

/// The type of a skew binary list
///
/// `BList[X]` is basically a linked list of `(Int, Tree[X])`, with the constraints that:
/// - the trees are in increasing order of size
/// - there can be two trees with the smallest size,
/// for all other sizes, there can be only one tree in a skew binary list
enum BList[X] {
  Empty
  Tree(Int, Tree[X], BList[X])
}

/// push a new element to the head of a skew binary list
///
/// This operation is `O(1)`
fn push[X](self : BList[X], elem : X) -> BList[X] {
  match self {
    Tree(1, left, Tree(1, right, rest)) =>
      // Since 1 is the smallest size in [self],
      // we know that there can be at most one tree of size 3 in [rest].
      // So in the resulting tree, there can be at most two trees of size 3.
      // Since 3 is the smallest tree size in the new tree, the invariant is maintained
      Tree(3, Branch(elem, left, right), rest)
    _ =>
      // There is at most one tree of size 1 in [self]
      Tree(1, Leaf(elem), self)
  }
}

/// pops an element from a skew binary list, returns that element and the remaining list
///
/// This operation is `O(1)`
fn pop[X](self : BList[X]) -> (X, BList[X])? {
  match self {
    Empty => None
    Tree(_, Leaf(x), rest) => Some((x, rest))
    Tree(tree_size, Branch(x, left, right), rest) => {
      let subtree_size = (tree_size - 1) / 2
      // [tree_size] is the smallest size in the original tree,
      // So [rest] contain no tree of size [subtree_size],
      // and [subtree_size] is the smallest tree size in the result.
      // Hence the invariant is maintained here
      Some((x, Tree(subtree_size, left, Tree(subtree_size, right, rest))))
    }
  }
}

/// get the nth element in a skew binary list.
///
/// This operation is `O(log(N))`
fn op_get[X](self : BList[X], idx : Int) -> X? {
  match self {
    Empty => None
    Tree(tree_size, tree, rest) =>
      // Since the tree are all complete and of increasing size,
      // every tree we skip, [idx] must be exponentially larger.
      // So we will skip only [O(log(N))] trees
      if idx < tree_size {
        // ... and [tree.nth] is also [O(log(N))].
        // So [BList::op_get]'s complexity is [O(log(N))]
        Some(tree.nth(tree_size, idx))
      } else {
        rest[idx - tree_size]
      }
  }
}

/// compute the length of a skew binary list in `O(log(N))` time
fn length[X](self : BList[X]) -> Int {
  loop self, 0 {
    Empty, len => len
    Tree(tree_size, _, rest), len => continue rest, tree_size + len
  }
}

fn BList::from_array[X](xs : Array[X]) -> BList[X] {
  loop xs.length(), BList::Empty {
    0, acc => acc
    i, acc => continue i - 1, acc.push(xs[i - 1])
  }
}

fn to_array[X](self : BList[X]) -> Array[X] {
  let arr = match self {
    Empty => return []
    Tree(_, Leaf(x), _) | Tree(_, Branch(x, _, _), _) =>
      Array::make(self.length(), x)
  }
  fn push_tree(base_index : Int, tree : Tree[X]) {
    match tree {
      Leaf(x) => {
        arr[base_index] = x
        base_index + 1
      }
      Branch(x, left, right) => {
        arr[base_index] = x
        push_tree(base_index + 1, left) |> push_tree(right)
      }
    }
  }

  loop self, 0 {
    Empty, _ => arr
    Tree(_, tree, rest), base_index => {
      let new_index = push_tree(base_index, tree)
      continue rest, new_index
    }
  }
}

fn debug_write[X : Debug](self : BList[X], buf : Buffer) -> Unit {
  buf.write_string("BList::")
  self.to_array().debug_write(buf)
}
