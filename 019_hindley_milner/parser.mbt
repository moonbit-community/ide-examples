// A simple hand-writter LL(1) parser

enum Token {
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
} derive(Debug, Eq)

struct Tokenizer {
  mut token_start: Int
  mut cursor: Int
  src: String
  mut cur_token: Token
}

fn Tokenizer::make(src: String) -> Tokenizer {
  { token_start: 0, cursor: 0, src, cur_token: EOF }
}

fn peek_char(self: Tokenizer) -> Option[Char] {
  if self.cursor >= self.src.length() {
    return None
  }

  Some(self.src[self.cursor])
}

fn next_char(self: Tokenizer) -> Option[Char] {
  let c = self.peek_char()
  match c {
    Some(_) => { self.cursor = self.cursor + 1 }
    None => ()
  }
  c
}

fn lexeme(self: Tokenizer) -> String {
  let len = self.cursor - self.token_start
  if len <= 0 {
    return ""
  }

  let b = Bytes::make(len, 0)
  for i = 0; i < len; i = i + 1 {
    b[i] = self.src[self.token_start + i].to_int()
  }
  b.to_string()
}

fn peek(self: Tokenizer) -> Result[Token, String] {
  if self.cursor == 0 {
    self.cur_token = self.do_next()?
  }
  Ok(self.cur_token)
}

fn next(self: Tokenizer) -> Result[Token, String] {
  let tok = self.peek()?
  self.cur_token = self.do_next()?
  Ok(tok)
}

fn do_next(self: Tokenizer) -> Result[Token, String] {
  self.token_start = self.cursor
  let c =
    match self.next_char() {
      None => { return Ok(EOF) }
      Some(c) => c
    }
  
  match c {
    ' ' | '\n' | '\t' => { return self.do_next() }
    '(' => { return Ok(LPAREN) }
    ')' => { return Ok(RPAREN) }
    '=' => { return Ok(EQUAL) }
    '-' =>
      match self.next_char() {
        Some('>') => { return Ok(ARROW) }
        _ => { return Err("bad token \"" + self.lexeme() + "\"") }
      }
    _ => ()
  }
  if 'a' <= c && c <= 'z' || c == '_' {
    match self.next_ident() {
      "let" => Ok(LET)
      "in" => Ok(IN)
      "fun" => Ok(FUN)
      id => Ok(IDENT(id))
    }
  } else if 'A' <= c && c <= 'Z' {
    Ok(CON(self.next_ident()))
  } else {
    Err("invalid character " + c.to_string())
  }
}

fn next_ident(self: Tokenizer) -> String {
  match self.peek_char() {
    None => self.lexeme()
    Some(c) => {
      if 'a' <= c && c <= 'z' || 'A' <= c && c <= 'Z' || '0' <= c && c <= '9' || c == '_' {
        self.cursor = self.cursor + 1
        self.next_ident()
      } else {
        self.lexeme()
      }
    }
  }
}


fn parse_whole_file(self: Tokenizer) -> Result[Expr, String] {
  let expr = self.parse_expr()?
  self.expect_token(EOF)?
  Ok(expr)
}

fn parse_expr(self: Tokenizer) -> Result[Expr, String] {
  match self.peek()? {
    EOF => Err("unexpected EOF, expected expr")
    LET => {
      let _ = self.next()?
      let id = self.expect_ident()?
      self.expect_token(EQUAL)?
      let rhs = self.parse_expr()?
      self.expect_token(IN)?
      let body = self.parse_expr()?
      Ok(Let(id, rhs, body))
    }
    FUN => {
      let _ = self.next()?
      let param = self.expect_ident()?
      self.expect_token(ARROW)?
      let body = self.parse_expr()?
      Ok(Lam(param, body))
    }
    _ => {
      let mut head = self.parse_simple_expr()?
      while true {
        match self.peek()? {
          LPAREN | IDENT(_) | CON(_) => {
            let arg = self.parse_simple_expr()?
            head = App(head, arg)
          }
          _ => { break }
        }
      }
      Ok(head)
    }
  }
}

fn parse_simple_expr(self: Tokenizer) -> Result[Expr, String] {
  match self.next()? {
    IDENT(id) => Ok(Var(id))
    CON(con) => Ok(Con(con))
    LPAREN => {
      let expr = self.parse_expr()?
      self.expect_token(RPAREN)?
      Ok(expr)
    }
    token => {
      let b = Buffer::make(17)
      b.write_string("unexpected token \"")
      token.debug_write(b)
      b.write_string("\", expecting simple expression")
      Err(b.to_string())
    }
  }
}


fn expect_ident(self: Tokenizer) -> Result[String, String] {
  match self.next()? {
    IDENT(id) => Ok(id)
    token => {
      let b = Buffer::make(17)
      b.write_string("unexpected token \"")
      token.debug_write(b)
      b.write_string("\", expecting identifier")
      Err(b.to_string())
    }
  }
}

fn expect_token(self: Tokenizer, tok: Token) -> Result[Unit, String] {
  let next_tok = self.next()?
  if next_tok == tok {
    Ok(())
  } else {
    let b = Buffer::make(17)
    b.write_string("unexpected token \"")
    next_tok.debug_write(b)
    b.write_string("\", expecting \"")
    tok.debug_write(b)
    b.write_string("\"")
    Err(b.to_string())
  }
}


