// syntax:
// - lambda: [fun param -> body] (only single parameter)
// - application: [func arg1 ...]
// - variable: start with lowercase letter
// - constructor: start with uppercase letter, [Bool] is a term of type [Bool] itself,
//   and [List] is a term of type [List] itself
// - let expr: [let name = expr in expr]
//
// The type checker supports higher kinded polymorphism via constructor classes.
// You can play with more complex examples by adding more primitives to [prelude] below.

fn init {
  run(
    #| let id = fun x -> x in
    #| id id
    ,
  )
  run(
    #| let apply = fun f -> fun x -> f x in
    #| apply
    ,
  )
  run(
    #| let apply = fun f -> fun x -> f x in
    #| let id = fun x -> x in
    #| (id apply) id apply Int
    ,
  )
  run(
    #| fun f ->
    #|   let x = f Int in
    #|   f Bool
    ,
  )
  run("cons Int (cons Int nil)")
  run(
    #| let map = fun f -> fun lst ->
    #|   fold (fun x -> fun l -> cons (f x) l) lst nil
    #| in
    #| let xs = map (fun x -> cons x nil) (cons Int (cons Int nil)) in
    #| map (fun l -> map (fun x -> Bool) l) xs
    ,
  )
  run("fun x -> x x")
}

fn run(src : String) -> Unit {
  match parse_and_check(src) {
    Err(err) => println(err)
    Ok(typ) => typ.pretty()
  }
}

fn parse_and_check(src : String) -> Result[Type, String] {
  let t = Tokenizer::make(src)
  let expr = t.parse_whole_file()?
  Ok(infer(prelude, expr)?.generalize(0))
}

let prelude : Map[String, Type] = Map::of_array(
  [
    ("nil", forall(fn(a) { list(a) })),
    ("cons", forall(fn(a) { lam([a, list(a)], list(a)) })),
    ("fold", forall2(fn(a, b) { lam([lam([a, b], b), list(a), b], b) })),
  ],
)

fn forall(f : (Type) -> Type) -> Type {
  f(fresh_generic())
}

fn forall2(f : (Type, Type) -> Type) -> Type {
  f(fresh_generic(), fresh_generic())
}

fn list(a : Type) -> Type {
  T_App(T_Con("List"), a)
}

fn lam(args : Array[Type], ret : Type) -> Type {
  let mut result = ret
  for i = args.length() - 1; i >= 0; i = i - 1 {
    result = T_Lam(args[i], result)
  }
  result
}
