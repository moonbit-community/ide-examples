///|
fn main {
  println("===")
  test1(@lib.chr('A') * @lib.star(@lib.chr('a') + @lib.chr('A')), [
    "AaAAa", "A", "a", "Aab",
  ])
  println("===")
  test1(@lib.parse("A(a|A)*"), ["AaAAa", "A", "a", "Aab"])
  println("===")
  test1(@lib.parse("let|in|fun"), ["let", "in", "fun", "ley", "fit"])
  println("===")
  test1(@lib.parse("A(aa|b)*"), ["Aaabaa", "Aba"])
  println("===")
  test1(@lib.parse(".*abcab.*"), [
    "xxxabcabxxx", "xxababcabxx", "xxababca", "abcab", "xxabab",
  ])
}

///|
fn test1(r : @lib.Regex, tests : Array[String]) -> Unit {
  let c = r.compile()
  // uncomment this line to see the compiled state machine
  // c.dump()
  for i = 0; i < tests.length(); i = i + 1 {
    println((r.matches(tests[i]), c.matches(tests[i])))
  }
}
