pub fn Regex::parse(src : String) -> Regex {
  let state = { src, offset: 0 }
  let r = parse_alt(state)
  if state.offset < state.src.length() {
    abort(
      "unexpected character " + state.src[state.offset].to_string() + " at index " +
      state.offset.to_string(),
    )
  }
  r
}

struct ParseState {
  src : String
  mut offset : Int
}

fn parse_alt(state : ParseState) -> Regex {
  let mut r = parse_postfix(state)
  while state.offset < state.src.length() {
    match state.src[state.offset] {
      '|' => {
        state.offset = state.offset + 1
        r = r + parse_postfix(state)
      }
      _ => break
    }
  }
  r
}

fn parse_postfix(state : ParseState) -> Regex {
  let mut r = parse_atomic(state)
  while state.offset < state.src.length() {
    match state.src[state.offset] {
      '*' => {
        r = star(r)
        state.offset = state.offset + 1
      }
      '+' => {
        r = plus(r)
        state.offset = state.offset + 1
      }
      ')' | '|' => break
      _ => r = r * parse_postfix(state)
    }
  }
  r
}

fn parse_atomic(state : ParseState) -> Regex {
  if state.offset >= state.src.length() {
    return empty()
  }
  match state.src[state.offset] {
    '(' => {
      let paren_pos = state.offset
      state.offset = state.offset + 1
      let r = parse_alt(state)
      if state.offset >= state.src.length() {
        abort("unmatched parenthesis at offset at index \{paren_pos}")
      }
      match state.src[state.offset] {
        ')' => state.offset = state.offset + 1
        _ => abort("unmatched parenthesis at offset at index \{paren_pos}")
      }
      r
    }
    '*' => abort("unexpected \"*\" at index " + state.offset.to_string())
    '+' => abort("unexpected \"+\" at index " + state.offset.to_string())
    '\\' => {
      state.offset = state.offset + 1
      if state.offset >= state.src.length() {
        abort("bad escape sequence at index " + state.offset.to_string())
      }
      let c = state.src[state.offset]
      state.offset = state.offset + 1
      chr(c)
    }
    '.' => {
      state.offset = state.offset + 1
      any()
    }
    c => {
      state.offset = state.offset + 1
      chr(c)
    }
  }
}
