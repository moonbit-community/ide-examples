///|
pub(all) enum Type {
  T_Var(Ref[Tvar])
  T_Lam(Type, Type)
  T_Con(String)
  T_App(Type, Type)
} derive(Show)

///|
enum Tvar {
  Free(Int, Int)
  Generic(Int)
  Solved(Type)
} derive(Show)

///|
enum Expr {
  Var(String)
  Con(String)
  Lam(String, Expr)
  App(Expr, Expr)
  Let(String, Expr, Expr)
} derive(Show)

// type operations

///|
let counter : Ref[Int] = { val: 0 }

///|
fn fresh(lvl : Int) -> Type {
  let tag = counter.val
  counter.val = tag + 1
  T_Var({ val: Free(tag, lvl) })
}

///|
pub fn fresh_generic() -> Type {
  let tag = counter.val
  counter.val = tag + 1
  T_Var({ val: Generic(tag) })
}

///|
fn repr(self : Type) -> Type {
  match self {
    T_Var({ val: Solved(ty) } as tvar) => {
      let ty = ty.repr()
      tvar.val = Solved(ty)
      ty
    }
    ty => ty
  }
}

///|
type! TypeCheckError {
  OccursError
  TypeMismatchError
  VariableNotFoundError(String)
}

///|
fn check_occurs(self : Type, tag : Int, lvl : Int) -> Unit!TypeCheckError {
  match self.repr() {
    T_Var({ val: Free(my_tag, my_lvl) } as tvar) =>
      if tag == my_tag {
        raise OccursError
      } else if lvl < my_lvl {
        tvar.val = Free(my_tag, lvl)
      }
    T_Var(_) => abort("impossible")
    T_Lam(t1, t2) | T_App(t1, t2) => {
      t1.check_occurs!(tag, lvl)
      t2.check_occurs!(tag, lvl)
    }
    T_Con(_) => ()
  }
}

///|
fn unify(t1 : Type, t2 : Type) -> Unit!TypeCheckError {
  match (t1.repr(), t2.repr()) {
    (T_Var({ val: Free(tag, lvl) } as tv), ty)
    | (ty, T_Var({ val: Free(tag, lvl) } as tv)) => {
      match ty {
        T_Var({ val: Free(alt_tag, _) }) => if tag == alt_tag { return }
        _ => ()
      }
      ty.check_occurs!(tag, lvl)
      tv.val = Solved(ty)
    }
    (T_Lam(t11, t12), T_Lam(t21, t22)) => {
      unify!(t11, t21)
      unify!(t12, t22)
    }
    (T_Con(con1), T_Con(con2)) => if con1 != con2 { raise TypeMismatchError }
    (T_App(f1, a1), T_App(f2, a2)) => {
      unify!(f1, f2)
      unify!(a1, a2)
    }
    _ => raise TypeMismatchError
  }
}

///|
pub fn generalize(self : Type, lvl : Int) -> Type {
  match self.repr() {
    T_Var({ val: Free(tag, my_lvl) } as tv) as ty => {
      if my_lvl >= lvl {
        tv.val = Generic(tag)
      }
      ty
    }
    T_Lam(t1, t2) => T_Lam(t1.generalize(lvl), t2.generalize(lvl))
    T_App(f, a) => T_App(f.generalize(lvl), a.generalize(lvl))
    ty => ty
  }
}

///|
fn instantiate(self : Type) -> Type {
  let mut subst = Map::Empty
  fn go(ty : Type) {
    match ty.repr() {
      T_Var({ val: Generic(id) }) =>
        match subst.find(id) {
          Some(ty) => ty
          None => {
            let ty = fresh(1000000)
            subst = Extend(id, ty, subst)
            ty
          }
        }
      T_Lam(t1, t2) => T_Lam(go(t1), go(t2))
      T_App(f, a) => T_App(go(f), go(a))
      ty => ty
    }
  }

  go(self)
}

///|
pub fn infer(ctx : Map[String, Type], expr : Expr) -> Type!TypeCheckError {
  match expr {
    Var(name) =>
      match ctx.find(name) {
        None => raise VariableNotFoundError("variable not found: \{name}")
        Some(ty) => ty.instantiate()
      }
    Con(con) => T_Con(con)
    Lam(param, body) => {
      let tparam = fresh(ctx.length())
      let tret = infer!(Extend(param, tparam, ctx), body)
      T_Lam(tparam, tret)
    }
    App(func, arg) => {
      let tfunc = infer!(ctx, func)
      let targ = infer!(ctx, arg)
      let tret = fresh(10000000)
      unify!(tfunc, T_Lam(targ, tret))
      tret.repr()
    }
    Let(name, rhs, body) => {
      let trhs = infer!(ctx, rhs).generalize(ctx.length())
      infer!(Extend(name, trhs, ctx), body)
    }
  }
}

///|
enum Map[K, V] {
  Empty
  Extend(K, V, Map[K, V])
}

///|
fn[K : Eq, V] find(self : Map[K, V], key : K) -> V? {
  match self {
    Empty => None
    Extend(my_key, my_value, rest) =>
      if my_key == key {
        Some(my_value)
      } else {
        rest.find(key)
      }
  }
}

///|
fn[K, V] length(self : Map[K, V]) -> Int {
  match self {
    Empty => 0
    Extend(_, _, rest) => rest.length() + 1
  }
}

///|
pub fn[K, V] Map::of_array(xs : Array[(K, V)]) -> Map[K, V] {
  let mut result : Map[_] = Empty
  for i = xs.length() - 1; i >= 0; i = i - 1 {
    let (k, v) = xs[i]
    result = Extend(k, v, result)
  }
  result
}

///|
/// pretty printer for type
pub fn pretty(self : Type) -> Unit {
  let mut subst : Map[Int, String] = Empty
  let buf = @buffer.new(size_hint=100)
  fn show_var(tag : Int) -> String {
    match subst.find(tag) {
      Some(name) => name
      None => {
        let name = "abcdefghijklmnopqrstuvwxyz"
          .char_at(subst.length())
          .to_string()
        subst = Extend(tag, name, subst)
        name
      }
    }
  }

  fn go(ctx : Int, ty : Type) {
    match ty.repr() {
      T_Var({ val: Free(tag, _) }) => buf.write_string("?" + show_var(tag))
      T_Var({ val: Generic(tag) }) => buf.write_string(show_var(tag))
      T_Var(_) => abort("impossible")
      T_Lam(t1, t2) =>
        if ctx == 0 {
          go(1, t1)
          buf.write_string(" -> ")
          go(0, t2)
        } else {
          buf.write_string("(")
          go(0, ty)
          buf.write_string(")")
        }
      T_Con(con) => buf.write_string(con)
      T_App(f, a) =>
        if ctx == 2 {
          buf.write_string("(")
          go(0, ty)
          buf.write_string(")")
        } else {
          go(1, f)
          buf.write_string(" ")
          go(2, a)
        }
    }
  }

  go(0, self)
  println(buf.to_string())
}
