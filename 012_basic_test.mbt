/// This feature is not available on the web. 
/// You can install the Moon toolchain from https://www.moonbitlang.com/download/
/// and try it in your terminal.


/// In MoonBit, it's easy to write a test. 
/// Just use the test block and write the test code inside it.
test {
  assert_eq(1, 1 + 2)
  assert_false(1 == 2)
  assert_true([1, 2, 3] == [1, 2, 3])
}


/// MoonBit supports snapshot testing.
/// 
/// Pass the value you want to test to the `inspect!` function, and run the test with `moon test`.
/// If the output is as expected, you can store the result with `moon test --update`.
/// The next time you run the test, the stored result will be compared with the actual result.
test {
  inspect(fib(5))
  inspect([1, 2, 3, 4].map(fib))
}

/// Add test name to make it more descriptive.
test "fibonacci" {
  inspect(fib(5), content="5")
  inspect(fib(6), content="8")
}

fn fib(n : Int) -> Int {
  if n < 2 {
    n
  } else {
    fib(n - 1) + fib(n - 2)
  }
}

