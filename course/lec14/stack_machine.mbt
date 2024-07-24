enum Value {
  I32(Int)
}

enum Instruction {
  Const(Value)
  Add
  Sub
  Modulo
  Equal
  Call(String)
  Local_Get(String)
  Local_Set(String)
  If(Int, @immut/list.List[Instruction], @immut/list.List[Instruction])
}

struct Function {
  name : String
  params : @immut/list.List[String]
  result : Int
  locals : @immut/list.List[String]
  instructions : @immut/list.List[Instruction]
}

struct Program {
  functions : @immut/list.List[Function]
  start : Option[String]
}

fn Instruction::to_wasm(self : Instruction, buffer : Buffer) -> Unit {
  match self {
    Const(I32(i)) => buffer.write_string("i32.const \(i) ")
    Add => buffer.write_string("i32.add ")
    Sub => buffer.write_string("i32.sub ")
    Modulo => buffer.write_string("i32.rem_s ")
    Equal => buffer.write_string("i32.eq ")
    Call(val) => buffer.write_string("call $\(val) ")
    Local_Get(val) => buffer.write_string("local.get $\(val) ")
    Local_Set(val) => buffer.write_string("local.set $\(val) ")
    If(n, then, else_) => {
      buffer.write_string("if (result ")
      for i = 0; i < n; i = i + 1 {
        buffer.write_string("i32 ")
      }
      buffer.write_string(") ")
      then.each(fn { instruction => instruction.to_wasm(buffer) })
      buffer.write_string("else ")
      else_.each(fn { instruction => instruction.to_wasm(buffer) })
      buffer.write_string("end ")
    }
  }
}

fn Function::to_wasm(self : Function, buffer : Buffer) -> Unit {
  let { name, params, result, locals, instructions } = self
  buffer.write_string("(func $\(name) (export \"\(name)\")")
  params.each(fn { param => buffer.write_string("(param $\(param) i32) ") })
  buffer.write_string("(result ")
  for i = 0; i < result; i = i + 1 {
    buffer.write_string("i32 ")
  }
  buffer.write_string(") ")
  locals.each(fn { local => buffer.write_string("(local $\(local) i32)") })
  instructions.each(fn { instruction => instruction.to_wasm(buffer) })
  buffer.write_string(")\n")
}

fn Program::to_wasm(self : Program, buffer : Buffer) -> Unit {
  let { functions, start } = self
  buffer.write_string(

    #|(module (func $print_int (import "spectest" "print_int") (param i32))
    #|
    ,
  )
  functions.each(fn { func => func.to_wasm(buffer) })
  match start {
    Some(start) => buffer.write_string("(start $\(start)))")
    None => buffer.write_string(")")
  }
}

test "add" {
  let program = Program::{
    start: None,
    functions: @immut/list.of(
      [
        Function::{
          name: "add",
          params: @immut/list.of(["a", "b"]),
          result: 1,
          locals: @immut/list.of([]),
          instructions: @immut/list.of([Local_Get("a"), Local_Get("b"), Add]),
        },
      ],
    ),
  }
  let buffer = Buffer::new(size_hint=100)
  program.to_wasm(buffer)
  @test.eq(
    buffer.to_string(),

    #|(module (func $print_int (import "spectest" "print_int") (param i32))
    #|(func $add (export "add")(param $a i32) (param $b i32) (result i32 ) local.get $a local.get $b i32.add )
    #|)
    ,
  )!
}

enum StackValue {
  Val(Value)
  Func(@immut/sorted_map.Map[String, Value])
}

enum AdministrativeInstruction {
  Plain(Instruction)
  EndOfFrame(Int)
}

struct State {
  program : Program
  stack : @immut/list.List[StackValue]
  locals : @immut/sorted_map.Map[String, Value]
  instructions : @immut/list.List[AdministrativeInstruction]
}

fn execute(program : Program) -> Option[String] {
  let start = program.start?
  let function = program.functions.filter(fn { f => f.name == start }).head()?
  let stdout = Buffer::new(size_hint=10)
  loop
    Option::Some(
      State::{
        program,
        stack: Nil,
        locals: function.locals.fold_left(
          init=@immut/sorted_map.empty(),
          fn { map, name => map.insert(name, I32(0)) },
        ),
        instructions: function.instructions.map(
          AdministrativeInstruction::Plain,
        ),
      },
    ) {
    None => Some(stdout.to_string())
    Some(state) => continue evaluate(state, stdout)
  }
}

fn evaluate(state : State, stdout : Buffer) -> Option[State] {
  match state.instructions {
    Nil => None
    Cons(Plain(instr), tl) =>
      match instr {
        Const(value) =>
          Some(
            State::{
              ..state,
              instructions: tl,
              stack: Cons(Val(value), state.stack),
            },
          )
        Add =>
          match state.stack {
            Cons(Val(I32(b)), Cons(Val(I32(a)), rest)) =>
              Some(
                State::{
                  ..state,
                  instructions: tl,
                  stack: Cons(Val(I32(a + b)), rest),
                },
              )
            _ => None
          }
        Sub =>
          match state.stack {
            Cons(Val(I32(b)), Cons(Val(I32(a)), rest)) =>
              Some(
                State::{
                  ..state,
                  instructions: tl,
                  stack: Cons(Val(I32(a - b)), rest),
                },
              )
            _ => None
          }
        Modulo =>
          match state.stack {
            Cons(Val(I32(b)), Cons(Val(I32(a)), rest)) =>
              Some(
                State::{
                  ..state,
                  instructions: tl,
                  stack: Cons(Val(I32(a % b)), rest),
                },
              )
            _ => None
          }
        Equal =>
          match state.stack {
            Cons(Val(I32(b)), Cons(Val(I32(a)), rest)) =>
              Some(
                State::{
                  ..state,
                  instructions: tl,
                  stack: Cons(Val(I32(if a == b { 1 } else { 0 })), rest),
                },
              )
            _ => None
          }
        Local_Get(var) => {
          let value = state.locals.lookup(var)?
          Some(
            State::{
              ..state,
              instructions: tl,
              stack: Cons(Val(value), state.stack),
            },
          )
        }
        Local_Set(var) =>
          match state.stack {
            Cons(Val(value), rest) =>
              Some(
                State::{
                  ..state,
                  locals: state.locals.insert(var, value),
                  instructions: tl,
                  stack: rest,
                },
              )
            _ => None
          }
        Call(var) =>
          if var == "print_int" {
            match state.stack {
              Cons(Val(I32(i)), rest) => {
                stdout.write_string(i.to_string())
                Some(State::{ ..state, stack: rest, instructions: tl })
              }
              _ => None
            }
          } else {
            let function : Function = state.program.functions.filter(
              fn { f => f.name == var },
            ).head()?
            let params = state.stack.take(function.params.length())
            Some(
              State::{
                ..state,
                stack: Cons(
                  Func(state.locals),
                  state.stack.drop(function.params.length()),
                ),
                locals: function.locals.fold_left(
                  init=function.params.zip(params.rev()).fold_left(
                    init=@immut/sorted_map.empty(),
                    fn {
                      map, (name, Val(value)) => map.insert(name, value)
                      _, _ => abort("Expected a value")
                    },
                  ),
                  fn { map, name => map.insert(name, I32(0)) },
                ),
                instructions: function.instructions.map(
                  AdministrativeInstruction::Plain,
                ).concat(@immut/list.of([EndOfFrame(function.result)])).concat(tl),
              },
            )
          }
        If(_, then, else_) =>
          match state.stack {
            Cons(Val(I32(i)), rest) =>
              Some(
                State::{
                  ..state,
                  stack: rest,
                  instructions: (if i != 0 { then } else { else_ }).map(
                    AdministrativeInstruction::Plain,
                  ).concat(tl),
                },
              )
            _ => None
          }
      }
    Cons(EndOfFrame(arity), tl) => {
      let params = state.stack.take(arity)
      let stack = state.stack.drop_while(
        fn {
          Func(_) => false
          _ => true
        },
      )
      match stack {
        Cons(Func(locals), rest) =>
          Some(
            State::{ ..state, stack: params.concat(rest), locals, instructions: tl },
          )
        _ => None
      }
    }
  }
}

test "eval" {
  let functions : @immut/list.List[Function] = @immut/list.of([
    Function::{
      name: "gcd",
      params: @immut/list.of(["a", "b"]),
      result: 1,
      locals: @immut/list.of([]),
      instructions: @immut/list.of([
        Local_Get("a"),
        Const(I32(0)),
        Equal,
        If(
          1,
          @immut/list.of([Local_Get("b")]),
          @immut/list.of([
            Local_Get("b"),
            Local_Get("a"),
            Modulo,
            Local_Get("a"),
            Call("gcd"),
          ]),
        ),
      ]),
    },
    Function::{
      name: "fib_aux",
      params: @immut/list.of(["a", "b", "n"]),
      result: 1,
      locals: @immut/list.of([]),
      instructions: @immut/list.of([
        Local_Get("n"),
        Const(I32(0)),
        Equal,
        If(
          1,
          @immut/list.of([Local_Get("b")]),
          @immut/list.of([
            Local_Get("b"),
            Local_Get("a"),
            Local_Get("b"),
            Add,
            Local_Get("n"),
            Const(I32(1)),
            Sub,
            Call("fib_aux"),
          ]),
        ),
      ]),
    },
    Function::{
      name: "fib",
      params: @immut/list.of(["n"]),
      result: 1,
      locals: @immut/list.of([]),
      instructions: @immut/list.of([
        Const(I32(0)),
        Const(I32(1)),
        Local_Get("n"),
        Call("fib_aux"),
      ]),
    },
    Function::{
      name: "test_fib",
      params: @immut/list.of([]),
      result: 0,
      locals: @immut/list.of([]),
      instructions: @immut/list.of([Const(I32(5)), Call("fib"), Call("print_int")]),
    },
    Function::{
      name: "test_gcd",
      params: @immut/list.of([]),
      result: 0,
      locals: @immut/list.of([]),
      instructions: @immut/list.of([
        Const(I32(10)),
        Const(I32(100)),
        Call("gcd"),
        Call("print_int"),
      ]),
    },
  ])
  let test_gcd = Program::{ start: Some("test_gcd"), functions }
  @test.eq(execute(test_gcd), Some("10"))!
  let test_fib = Program::{ start: Some("test_fib"), functions }
  @test.eq(execute(test_fib), Some("8"))!
}

fn compile_expression(expression : Expression) -> @immut/list.List[Instruction] {
  match expression {
    Number(i) => @immut/list.of([Const(I32(i))])
    Plus(a, b) =>
      compile_expression(a).concat(compile_expression(b)).concat(@immut/list.of([Add]))
    Minus(a, b) =>
      compile_expression(a).concat(compile_expression(b)).concat(@immut/list.of([Sub]))
    _ => @immut/list.of([])
  }
}

fn compile(expression : Expression) -> Program {
  Program::{
    start: Some("main"),
    functions: @immut/list.of([
      Function::{
        name: "main",
        params: @immut/list.of([]),
        result: 0,
        locals: @immut/list.of([]),
        instructions: compile_expression(expression).concat(
          @immut/list.of([Call("print_int")]),
        ),
      },
    ]),
  }
}

test "compile" {
  let input = "1 + 2 - 3"
  let expression = parse_string(input)
  let program = expression.map(fn { (expression, _, _) => compile(expression) })
  @test.eq(
    program.bind(execute),
    parse_string_tagless_final(input).map(
      fn { (BoxedInt::BoxedInt(i), _, _) => i.to_string() },
    ),
  )!
}