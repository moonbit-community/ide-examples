// A simple hand-writter LL(1) parser

///|
priv enum Token {
  LET
  EQUAL
  IN
  FUN
  ARROW
  IDENT(String)
  CON(String)
  LPAREN
  RPAREN
  EOF
} derive(Show, Eq)

///|
struct Tokenizer {
  mut token_start : Int
  mut cursor : Int
  src : String
  mut cur_token : Token
}

///|
pub fn Tokenizer::make(src : String) -> Tokenizer {
  { token_start: 0, cursor: 0, src, cur_token: EOF }
}

///|
fn Tokenizer::peek_char(self : Tokenizer) -> Char? {
  if self.cursor >= self.src.length() {
    return None
  }
  self.src.get_char(self.cursor)
}

///|
fn Tokenizer::next_char(self : Tokenizer) -> Char? {
  let c = self.peek_char()
  match c {
    Some(_) => self.cursor = self.cursor + 1
    None => ()
  }
  c
}

///|
fn Tokenizer::lexeme(self : Tokenizer) -> String {
  try! self.src[self.token_start:self.cursor].to_string()
}

///|
fn Tokenizer::peek(self : Tokenizer) -> Token raise TokenError {
  if self.cursor == 0 {
    self.cur_token = self.do_next()
  }
  self.cur_token
}

///|
fn Tokenizer::next(self : Tokenizer) -> Token raise TokenError {
  let tok = self.peek()
  self.cur_token = self.do_next()
  tok
}

///|
suberror TokenError {
  BadTokenError(String)
  InvalidCharacterError(String)
  UnexpectedEofError
  UnexpectedTokenError(String)
} derive(Show)

///|
fn Tokenizer::do_next(self : Tokenizer) -> Token raise TokenError {
  self.token_start = self.cursor
  let c = match self.next_char() {
    None => return EOF
    Some(c) => c
  }
  match c {
    ' ' | '\n' | '\t' => return self.do_next()
    '(' => return LPAREN
    ')' => return RPAREN
    '=' => return EQUAL
    '-' =>
      match self.next_char() {
        Some('>') => return ARROW
        _ => raise BadTokenError("bad token \"" + self.lexeme() + "\"")
      }
    _ => ()
  }
  if ('a' <= c && c <= 'z') || c == '_' {
    match self.next_ident() {
      "let" => LET
      "in" => IN
      "fun" => FUN
      id => IDENT(id)
    }
  } else if 'A' <= c && c <= 'Z' {
    CON(self.next_ident())
  } else {
    raise InvalidCharacterError("invalid character " + c.to_string())
  }
}

///|
fn Tokenizer::next_ident(self : Tokenizer) -> String {
  match self.peek_char() {
    None => self.lexeme()
    Some(c) =>
      if ('a' <= c && c <= 'z') ||
        ('A' <= c && c <= 'Z') ||
        ('0' <= c && c <= '9') ||
        c == '_' {
        self.cursor = self.cursor + 1
        self.next_ident()
      } else {
        self.lexeme()
      }
  }
}

///|
pub fn Tokenizer::parse_whole_file(self : Tokenizer) -> Expr raise TokenError {
  let expr = self.parse_expr()
  self.expect_token(EOF)
  expr
}

///|
fn Tokenizer::parse_expr(self : Tokenizer) -> Expr raise TokenError {
  match self.peek() {
    EOF => raise UnexpectedEofError
    LET => {
      let _ = self.next()
      let id = self.expect_ident()
      self.expect_token(EQUAL)
      let rhs = self.parse_expr()
      self.expect_token(IN)
      let body = self.parse_expr()
      Let(id, rhs, body)
    }
    FUN => {
      let _ = self.next()
      let param = self.expect_ident()
      self.expect_token(ARROW)
      let body = self.parse_expr()
      Lam(param, body)
    }
    _ => {
      let mut head = self.parse_simple_expr()
      while true {
        match self.peek() {
          LPAREN | IDENT(_) | CON(_) => {
            let arg = self.parse_simple_expr()
            head = App(head, arg)
          }
          _ => break
        }
      }
      head
    }
  }
}

///|
fn Tokenizer::parse_simple_expr(self : Tokenizer) -> Expr raise TokenError {
  match self.next() {
    IDENT(id) => Var(id)
    CON(con) => Con(con)
    LPAREN => {
      let expr = self.parse_expr()
      self.expect_token(RPAREN)
      expr
    }
    token => {
      let tok = token.to_string()
      raise UnexpectedTokenError(
        "unexpected token \"\{tok}\", expecting simple expression",
      )
    }
  }
}

///|
fn Tokenizer::expect_ident(self : Tokenizer) -> String raise TokenError {
  match self.next() {
    IDENT(id) => id
    token => {
      let tok = token.to_string()
      raise UnexpectedTokenError(
        "unexpected token \"\{tok}\", expecting identifier",
      )
    }
  }
}

///|
fn Tokenizer::expect_token(
  self : Tokenizer,
  tok : Token,
) -> Unit raise TokenError {
  let next_tok = self.next()
  if next_tok == tok {

  } else {
    raise UnexpectedTokenError(
      "unexpected token \"\{next_tok}\", expecting \"\{tok}\"",
    )
  }
}
