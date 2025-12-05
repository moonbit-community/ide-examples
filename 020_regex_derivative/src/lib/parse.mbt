///|
pub fn parse(src : String) -> Regex {
  let state = { src, offset: 0 }
  let r = parse_alt(state)
  if state.offset < state.src.length() {
    let char_str = match state.src.get_char(state.offset) {
      Some(c) => c.to_string()
      None => "EOF"
    }
    abort(
      "unexpected character " +
      char_str +
      " at index " +
      state.offset.to_string(),
    )
  }
  r
}

///|
priv struct ParseState {
  src : String
  mut offset : Int
}

///|
fn parse_alt(state : ParseState) -> Regex {
  let mut r = parse_postfix(state)
  while state.offset < state.src.length() {
    match state.src.get_char(state.offset) {
      Some('|') => {
        state.offset = state.offset + 1
        r = r + parse_postfix(state)
      }
      _ => break
    }
  }
  r
}

///|
fn parse_postfix(state : ParseState) -> Regex {
  let mut r = parse_atomic(state)
  while state.offset < state.src.length() {
    match state.src.get_char(state.offset) {
      Some('*') => {
        r = star(r)
        state.offset = state.offset + 1
      }
      Some('+') => {
        r = plus(r)
        state.offset = state.offset + 1
      }
      Some(')') | Some('|') => break
      _ => r = r * parse_postfix(state)
    }
  }
  r
}

///|
fn parse_atomic(state : ParseState) -> Regex {
  if state.offset >= state.src.length() {
    return empty()
  }
  match state.src.get_char(state.offset) {
    Some('(') => {
      let paren_pos = state.offset
      state.offset = state.offset + 1
      let r = parse_alt(state)
      if state.offset >= state.src.length() {
        abort("unmatched parenthesis at offset at index \{paren_pos}")
      }
      match state.src.get_char(state.offset) {
        Some(')') => state.offset = state.offset + 1
        _ => abort("unmatched parenthesis at offset at index \{paren_pos}")
      }
      r
    }
    Some('*') => abort("unexpected \"*\" at index " + state.offset.to_string())
    Some('+') => abort("unexpected \"+\" at index " + state.offset.to_string())
    Some('\\') => {
      state.offset = state.offset + 1
      if state.offset >= state.src.length() {
        abort("bad escape sequence at index " + state.offset.to_string())
      }
      match state.src.get_char(state.offset) {
        Some(c) => {
          state.offset = state.offset + 1
          chr(c)
        }
        None =>
          abort("bad escape sequence at index " + state.offset.to_string())
      }
    }
    Some('.') => {
      state.offset = state.offset + 1
      any()
    }
    Some(c) => {
      state.offset = state.offset + 1
      chr(c)
    }
    None => empty()
  }
}
