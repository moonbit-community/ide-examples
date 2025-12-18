///|
struct Lexer[V]((StringView) -> (V, StringView)?)

///|
fn[V] Lexer::parse(self : Lexer[V], str : StringView) -> (V, String)? {
  (self.0)(str).map(val => (val.0, val.1.to_string()))
}

///|
fn pchar(predicate : (Char) -> Bool) -> Lexer[Char] {
  Lexer(fn(input) {
    match input {
      [ch, .. rest] if predicate(ch) => Some((ch, rest.to_string()))
      _ => None
    }
  })
}

///|
fn[I, O] Lexer::map(self : Lexer[I], f : (I) -> O) -> Lexer[O] {
  Lexer(fn(input) {
    match self.parse(input) {
      None => None
      Some((value, rest)) => Some((f(value), rest))
    }
  })
}

///|
fn[V1, V2] Lexer::and_(
  self : Lexer[V1],
  parser2 : Lexer[V2],
) -> Lexer[(V1, V2)] {
  Lexer(fn(input) {
    match self.parse(input) {
      None => None
      Some((value, rest)) =>
        match parser2.parse(rest) {
          None => None
          Some((value2, rest2)) => Some(((value, value2), rest2))
        }
    }
  })
}

///|
fn[Value] Lexer::or(
  self : Lexer[Value],
  parser2 : Lexer[Value],
) -> Lexer[Value] {
  Lexer(fn(input) {
    match self.parse(input) {
      None => parser2.parse(input).map(val => (val.0, val.1))
      Some(result) => Some((result.0, result.1))
    }
  })
}

///|
fn[Value] Lexer::many(self : Lexer[Value]) -> Lexer[List[Value]] {
  Lexer(fn(input) {
    let mut rest = input
    let mut cumul = List::empty()
    while true {
      match self.parse(rest) {
        None => break
        Some((value, new_rest)) => {
          rest = new_rest
          cumul = List::cons(value, cumul)
        }
      }
    }
    Some((cumul.rev(), rest))
  })
}

///|
/// Number = %x30 / (%x31-39) *(%x30-39)
/// LParen = "("
/// RParen = ")"
/// Plus = "+"
/// Minus = "-"
/// Multiply = "*"
/// Divide = "/"
/// Whitespace = " "
enum Token {
  Value(Int)
  LParen
  RParen
  Plus
  Minus
  Multiply
  Divide
} derive(Show)

///|
let symbol : Lexer[Token] = pchar(fn(ch) {
  match ch {
    '+' | '-' | '*' | '/' | '(' | ')' => true
    _ => false
  }
}).map(fn(ch) {
  match ch {
    '+' => Token::Plus
    '-' => Minus
    '*' => Multiply
    '/' => Divide
    '(' => LParen
    ')' => RParen
    _ => abort("unreachable")
  }
})

///|
let whitespace : Lexer[Char] = pchar(ch => ch == ' ')

///|
let zero : Lexer[Int] = pchar(ch => ch == '0').map(_ => 0)

///|
let one_to_nine : Lexer[Int] = pchar(fn(ch) {
  ch.to_int() >= 0x31 && ch.to_int() <= 0x39
}).map(ch => ch.to_int() - 0x30)

///|
let zero_to_nine : Lexer[Int] = pchar(ch => ch.to_int() >= 0x30 &&
  ch.to_int() <= 0x39).map(ch => ch.to_int() - 0x30)

///|
let value : Lexer[Token] = zero
  .or(
    one_to_nine
    .and_(zero_to_nine.many())
    .map(val => {
      let (i, ls) = val
      ls.fold((i, j) => i * 10 + j, init=i)
    }),
  )
  .map(Token::Value(_))

///|
let tokens : Lexer[List[Token]] = value
  .or(symbol)
  .and_(whitespace.many())
  .map(fn(val) {
    let (symbols, _) = val
    symbols
  })
  .many()

///|
test {
  println("===Lexing===")
  println(tokens.parse("-10123+-+523 103    ( 5) )  "))
  println(pchar(ch => ch == 'a').parse("asdf"))
  println(
    pchar(fn(ch) {
      match ch {
        'a' => true
        _ => false
      }
    }).parse("sdf"),
  )
}

///|
/// atomic = Value / LParen expression RParen
/// combine = atomic *( (Multiply / Divide) combine)
/// expression = combine *( (Plus / Minus) expression)
enum Expression {
  Number(Int)
  Plus(Expression, Expression)
  Minus(Expression, Expression)
  Multiply(Expression, Expression)
  Divide(Expression, Expression)
} derive(Show)

///|
struct Parser[V]((List[Token]) -> (V, List[Token])?)

///|
fn[V] Parser::parse(
  self : Parser[V],
  tokens : List[Token],
) -> (V, List[Token])? {
  (self.0)(tokens)
}

///|
fn ptoken(predicate : (Token) -> Bool) -> Parser[Token] {
  Parser(fn(tokens) {
    match tokens {
      Empty => None
      More(token, tail=rest) =>
        if predicate(token) {
          Some((token, rest))
        } else {
          None
        }
    }
  })
}

///|
fn[I, O] Parser::map(self : Parser[I], f : (I) -> O) -> Parser[O] {
  Parser(fn(input) {
    match self.parse(input) {
      None => None
      Some((value, rest)) => Some((f(value), rest))
    }
  })
}

///|
fn[V1, V2] Parser::and_(
  self : Parser[V1],
  parser2 : Parser[V2],
) -> Parser[(V1, V2)] {
  Parser(fn(input) {
    match self.parse(input) {
      None => None
      Some((value, rest)) =>
        match parser2.parse(rest) {
          None => None
          Some((value2, rest2)) => Some(((value, value2), rest2))
        }
    }
  })
}

///|
fn[Value] Parser::or(
  self : Parser[Value],
  parser2 : Parser[Value],
) -> Parser[Value] {
  Parser(fn(input) {
    match self.parse(input) {
      None => parser2.parse(input)
      Some(_) as result => result
    }
  })
}

///|
fn[Value] Parser::many(self : Parser[Value]) -> Parser[List[Value]] {
  Parser(fn(input) {
    let mut i = input
    let mut cumul = List::empty()
    while true {
      match self.parse(i) {
        None => break
        Some((value, rest)) => {
          i = rest
          cumul = List::cons(value, cumul)
        }
      }
    }
    Some((cumul.rev(), i))
  })
}

///|
fn[Value] Parser::ref_(ref_ : Ref[Parser[Value]]) -> Parser[Value] {
  Parser(fn(input) { ref_.val.parse(input) })
}

///|
let lparen : Parser[Token] = ptoken(fn(token) {
  match token {
    LParen => true
    _ => false
  }
})

///|
let rparen : Parser[Token] = ptoken(fn(token) {
  match token {
    RParen => true
    _ => false
  }
})

///|
let plus : Parser[Token] = ptoken(fn(input) {
  match input {
    Plus => true
    _ => false
  }
})

///|
let minus : Parser[Token] = ptoken(fn(input) {
  match input {
    Minus => true
    _ => false
  }
})

///|
let multiply : Parser[Token] = ptoken(fn(input) {
  match input {
    Multiply => true
    _ => false
  }
})

///|
let divide : Parser[Token] = ptoken(fn(input) {
  match input {
    Divide => true
    _ => false
  }
})

///|
fn parser() -> Parser[Expression] {
  let expression_ref : Ref[Parser[Expression]] = { val: Parser(_ => None) }
  let number : Parser[Expression] = ptoken(fn(input) {
    match input {
      Value(_) => true
      _ => false
    }
  }).map(fn(input) {
    match input {
      Value(i) => Number(i)
      _ => abort("unreachable")
    }
  })
  let automic = lparen
    .and_(Parser::ref_(expression_ref))
    .and_(rparen)
    .map(fn(val) {
      let ((_, expr), _) = val
      expr
    })
    .or(number)
  let combine = automic
    .and_(multiply.or(divide).and_(automic).many())
    .map(fn(val) {
      let (expr, list) = val
      List::fold(
        list,
        fn(e, list) {
          match (e, list) {
            (e, (Multiply, expr)) => Expression::Multiply(e, expr)
            (e, (_, expr)) => Expression::Divide(e, expr)
          }
        },
        init=expr,
      )
    })
  expression_ref.val = combine
    .and_(plus.or(minus).and_(combine).many())
    .map(fn(val) {
      let (expr, list) = val
      List::fold(
        list,
        fn(e, list) {
          match (e, list) {
            (e, (Plus, expr)) => Expression::Plus(e, expr)
            (e, (_, expr)) => Expression::Minus(e, expr)
          }
        },
        init=expr,
      )
    })
  Parser::ref_(expression_ref)
}

///|
trait Expr: Add + Sub + Mul + Div {
  number(Int) -> Self
}

// Semantic: create syntax tree 语义：构造语法树

///|
impl Expr for Expression with number(i) {
  Number(i)
}

///|
impl Add for Expression with add(a, b) {
  Plus(a, b)
}

///|
impl Sub for Expression with sub(a, b) {
  Minus(a, b)
}

///|
impl Mul for Expression with mul(a, b) {
  Multiply(a, b)
}

///|
impl Div for Expression with div(a, b) {
  Divide(a, b)
}

// Semantic: compute expression 语义：计算表达式

///|
struct BoxedInt(Int) derive(Show)

///|
// fn BoxedInt::number(i : Int) -> BoxedInt {
//   BoxedInt(i)
// }
impl Expr for BoxedInt with number(i) {
  BoxedInt(i)
}

///|
impl Add for BoxedInt with add(a, b) {
  BoxedInt(a.0 + b.0)
}

///|
impl Sub for BoxedInt with sub(a, b) {
  BoxedInt(a.0 - b.0)
}

///|
impl Mul for BoxedInt with mul(a, b) {
  BoxedInt(a.0 * b.0)
}

///|
impl Div for BoxedInt with div(a, b) {
  BoxedInt(a.0 / b.0)
}

// Semantic: print expression 语义：输出表达式

///|
struct BoxedString {
  str : String
  level : Int
} derive(Show)

///|
impl Expr for BoxedString with number(i) {
  { str: i.to_string(), level: 0 }
}

///|
impl Add for BoxedString with add(a, b) {
  let stra = a.str
  let strb = if b.level == 1 { "(" + b.str + ")" } else { b.str }
  { str: "\{stra} + \{strb}", level: 1 }
}

///|
impl Sub for BoxedString with sub(a, b) {
  let stra = a.str
  let strb = if b.level == 1 { "(" + b.str + ")" } else { b.str }
  { str: "\{stra} - \{strb}", level: 1 }
}

///|
impl Mul for BoxedString with mul(a, b) {
  let stra = if a.level == 1 { "(" + a.str + ")" } else { a.str }
  let strb = if b.level == 1 { "(" + b.str + ")" } else { b.str }
  { str: "\{stra} * \{strb}", level: 2 }
}

///|
impl Div for BoxedString with div(a, b) {
  let stra = if a.level == 1 { "(" + a.str + ")" } else { a.str }
  let strb = if b.level == 1 { "(" + b.str + ")" } else { b.str }
  { str: "\{stra} / \{strb}", level: 2 }
}

///|
fn[E : Expr] recursive_parser_with_tagless_final() -> Parser[E] {
  let number : Parser[E] = ptoken(fn(token) {
    match token {
      Value(_) => true
      _ => false
    }
  }).map(fn(token) {
    match token {
      Value(i) => E::number(i)
      _ => abort("unreachable")
    }
  })
  letrec atomic_ = fn(tokens : List[Token]) -> (E, List[Token])? {
    lparen
    .and_(Parser(expression))
    .and_(rparen)
    .map(fn(val) {
      let ((_, expr), _) = val
      expr
    })
    .or(number)
    .parse(tokens)
  }
  and combine = fn(tokens : List[Token]) -> (E, List[Token])? {
    (Parser(atomic_) : Parser[E])
    .and_(multiply.or(divide).and_(Parser(atomic_)).many())
    .map(fn(val) {
      let (e, list) = val
      List::fold(
        list,
        fn(e, list) {
          match (e, list) {
            (e, (Multiply, expr)) => e * expr
            (e, (_, expr)) => e / expr
          }
        },
        init=e,
      )
    })
    .parse(tokens)
  }
  and expression = fn(tokens : List[Token]) -> (E, List[Token])? {
    (Parser(combine) : Parser[E])
    .and_(plus.or(minus).and_(Parser(combine)).many())
    .map(fn(val) {
      let (e, list) = val
      List::fold(
        list,
        fn(e, list) {
          match (e, list) {
            (e, (Plus, expr)) => e + expr
            (e, (_, expr)) => e - expr
          }
        },
        init=e,
      )
    })
    .parse(tokens)
  }

  Parser(expression)
}

///|
fn parse_string(str : String) -> (Expression, String, List[Token])? {
  match tokens.parse(str) {
    None => None
    Some((token_list, rest_string)) =>
      match parser().parse(token_list) {
        None => None
        Some((expr, rest_token)) => Some((expr, rest_string, rest_token))
      }
  }
}

///|
fn[E : Expr] parse_string_tagless_final(
  str : String,
) -> (E, String, List[Token])? {
  match tokens.parse(str) {
    None => None
    Some((token_list, rest_string)) =>
      match recursive_parser_with_tagless_final().parse(token_list) {
        None => None
        Some((expr, rest_token)) => Some((expr, rest_string, rest_token))
      }
  }
}

///|
test {
  println("===Parsing===")
  println(parse_string("1 + 1 * (307 + 7) + 5 - 3 - 2"))
  println(
    (
      parse_string_tagless_final("1 + 1 * (307 + 7) + 5 - 3 - 2") :
      (Expression, String, List[Token])?),
  )
  println(
    (
      parse_string_tagless_final("1 + 1 * (307 + 7) + 5 - 3 - 2") :
      (BoxedInt, String, List[Token])?),
  )
  println(
    (
      parse_string_tagless_final("1 + 1 * (307 + 7) + 5 - 3 - 2") :
      (BoxedString, String, List[Token])?),
  )
}
