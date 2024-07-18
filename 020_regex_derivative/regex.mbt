// see [https://www.khoury.northeastern.edu/home/turon/re-deriv.pdf] for more details

/// the type of regular expressions
enum Regex {
  Empty
  Impossible
  Sym(Symbol)
  Concat(Regex, Regex)
  Alternative(Regex, Regex)
  Star(Regex)
  // technically [Plus(r)] is just [Concat(r, Star(r))], but that would duplicate [r]
  Plus(Regex)
}

enum Symbol {
  Any
  Chr(Char)
} derive(Eq)

// smart constructors.
// Make the shape of regex more normalized, for easier equality test
pub fn Regex::empty() -> Regex {
  Empty
}

pub fn Regex::impossible() -> Regex {
  Impossible
}

pub fn Regex::chr(c : Char) -> Regex {
  Sym(Chr(c))
}

pub fn Regex::any() -> Regex {
  Sym(Any)
}

pub fn op_mul(self : Regex, r : Regex) -> Regex {
  match (self, r) {
    (Empty, r) | (r, Empty) => r
    (Impossible, _) | (_, Impossible) => Impossible
    (Concat(r1, r2), r) => Concat(r1, Concat(r2, r))
    (r1, r2) => Concat(r1, r2)
  }
}

pub fn op_add(self : Regex, r : Regex) -> Regex {
  match (self, r) {
    (Impossible, r) | (r, Impossible) => r
    (Alternative(r1, r2), r) => Alternative(r1, Alternative(r2, r))
    (r1, r2) =>
      // This is slow, but necessary for termination
      if r1 == r2 {
        r1
      } else {
        Alternative(r1, r2)
      }
  }
}

pub fn Regex::star(r : Regex) -> Regex {
  Star(r)
}

pub fn Regex::plus(r : Regex) -> Regex {
  Plus(r)
}

/// simple, approximated equality test on regular expression.
/// Input should be consturcted from smart constructors
fn op_equal(self : Regex, r : Regex) -> Bool {
  match (self, r) {
    (Empty, Empty) => true
    (Impossible, Impossible) => true
    (Sym(s1), Sym(s2)) => s1 == s2
    (Concat(r11, r12), Concat(r21, r22)) => r11 == r21 && r12 == r22
    (Alternative(r11, r12), Alternative(r21, r22)) => r11 == r21 && r12 == r22
    (Star(r1), Star(r2)) => r1 == r2
    _ => false
  }
}

/// check if a regular expression accepts the empty string
fn nullable(self : Regex) -> Bool {
  match self {
    Empty => true
    Impossible => false
    Sym(_) => false
    Concat(r1, r2) => r1.nullable() && r2.nullable()
    Alternative(r1, r2) => r1.nullable() || r2.nullable()
    Star(_) => true
    Plus(r) => r.nullable()
  }
}

/// `r.derivative(c)` returns a regular expression `r'`,
/// such that `r` matches `c ++ s` if and only if `r'` matches `s`
fn derivative(self : Regex, c : Symbol) -> Regex {
  match self {
    Empty => impossible()
    Impossible => impossible()
    Sym(c2) =>
      match (c, c2) {
        (Chr(c1), Chr(c2)) => if c1 == c2 { empty() } else { impossible() }
        (Any, Chr(_)) => impossible()
        (_, Any) => empty()
      }
    Concat(r1, r2) => {
      let dr1 = r1.derivative(c)
      if r1.nullable() {
        dr1 * r2 + r2.derivative(c)
      } else {
        dr1 * r2
      }
    }
    Alternative(r1, r2) => r1.derivative(c) + r2.derivative(c)
    Star(r) => r.derivative(c) * star(r)
    Plus(r) => r.derivative(c) * star(r)
  }
}

/// Decides if a string matches a regular expression.
///
/// This is a simple but slow implementation based on derivative, similar to an interpreter
pub fn matches(self : Regex, s : String) -> Bool {
  let mut r = self
  let mut i = 0
  while i < s.length() {
    match r {
      Impossible => return false
      _ => ()
    }
    r = match r.derivative(Chr(s[i])) {
      Impossible => r.derivative(Any)
      rd => rd
    }
    i = i + 1
  }
  return r.nullable()
}

/// A state machine, the compilation target regular expressions.
/// Represented as a graph
priv struct State {
  accepting : Bool
  mut transitions : List[(Symbol, State)]
}

/// checks whether `self` accepts the sub string of `s` starting from `offset`
fn accepts(self : State, s : String, offset : Int) -> Bool {
  if offset >= s.length() {
    return self.accepting
  }
  match List::assoc(self.transitions, Chr(s[offset])) {
    Some(next_state) => next_state.accepts(s, offset + 1)
    None =>
      match List::assoc(self.transitions, Any) {
        Some(next_state) => next_state.accepts(s, offset + 1)
        None => false
      }
  }
}

fn State::op_equal(s1 : State, s2 : State) -> Bool {
  physical_equal(s1, s2)
}

/// a compiled representation of regular expression.
/// Allows efficient matching.
type CompiledRegex State

pub fn matches(self : CompiledRegex, s : String) -> Bool {
  self.0.accepts(s, 0)
}

pub fn dump(self : CompiledRegex) -> Unit {
  let mut states : List[(State, Int)] = Nil
  let mut counter : Int = 0
  fn collect_states(s : State) {
    match List::assoc(states, s) {
      None => {
        let id = counter
        states = Cons((s, id), states)
        counter = counter + 1
        s.transitions.iter(fn { (_, s2) => collect_states(s2) })
      }
      Some(_) => ()
    }
  }

  collect_states(self.0)
  fn state_to_string(s : State) -> String {
    match List::assoc(states, s) {
      None => abort("impossible")
      Some(id) => id.to_string()
    }
  }

  states.iter(
    fn(entry) {
      let ({ accepting, transitions }, id) = entry
      let accepting = if accepting { " (accepting)" } else { "" }
      println("state #\(id)\(accepting):")
      fn output_transitions(any_trans : State?, transitions) {
        match (transitions : List[(Symbol, State)]) {
          Nil =>
            match any_trans {
              None => ()
              Some(s) => println("  _ => #" + state_to_string(s))
            }
          Cons((Chr(c), next_state), rest) => {
            println("  \(c) => #" + state_to_string(next_state))
            output_transitions(any_trans, rest)
          }
          Cons((Any, next_state), rest) =>
            output_transitions(Some(next_state), rest)
        }
      }

      output_transitions(None, transitions)
    },
  )
  println("initial state: #" + state_to_string(self.0))
}

/// compile a regular expression to a state machine
pub fn compile(self : Regex) -> CompiledRegex {
  let mut current_states : List[(Regex, State)] = Nil
  fn go(r : Regex) {
    match List::assoc(current_states, r) {
      Some(state) => state
      None => {
        let state = { accepting: r.nullable(), transitions: Nil }
        current_states = Cons((r, state), current_states)
        // for every possible head character, create a transition
        r.head_symbols().iter(
          fn(s) {
            state.transitions = Cons(
              (s, go(r.derivative(s))),
              state.transitions,
            )
          },
        )
        state
      }
    }
  }

  CompiledRegex(go(self))
}

// helper functions

// calculate the list of characters that may appear in the front of a regular expression
fn head_symbols(self : Regex) -> List[Symbol] {
  fn go(acc : List[Symbol], r : Regex) {
    match r {
      Empty | Impossible => acc
      Sym(s) => if acc.contains(s) { acc } else { Cons(s, acc) }
      Concat(r1, r2) => {
        let acc = go(acc, r1)
        if r1.nullable() {
          go(acc, r2)
        } else {
          acc
        }
      }
      Alternative(r1, r2) => go(go(acc, r1), r2)
      Star(r) | Plus(r) => go(acc, r)
    }
  }

  go(Nil, self)
}

// some list operations
fn List::assoc[K : Eq, V](lst : List[(K, V)], key : K) -> V? {
  match lst {
    Nil => None
    Cons((key1, value), rest) =>
      if key == key1 {
        Some(value)
      } else {
        List::assoc(rest, key)
      }
  }
}

fn iter[X](self : List[X], f : (X) -> Unit) -> Unit {
  match self {
    Nil => ()
    Cons(hd, tl) => {
      f(hd)
      tl.iter(f)
    }
  }
}

fn contains[X : Eq](self : List[X], elem : X) -> Bool {
  match self {
    Nil => false
    Cons(hd, tl) => hd == elem || tl.contains(elem)
  }
}

enum List[X] {
  Nil
  Cons(X, List[X])
}
