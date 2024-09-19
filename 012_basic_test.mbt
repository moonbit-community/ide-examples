// In MoonBit, it's easy to write a test. 
// No need for configuration, no frameworks or libraries. Just use the test block and 
// write the test code inside it.
// 
// Click on the "Run test" button below to run the test.
test {
  assert_eq!(1, 1 + 2)
  assert_false!(1 == 2)
  assert_true!([1,2,3] == [1,2,3])
}


// Writing test cases is nasty, use "inpect!" to make it easier.
// 
// Just inspect the return value of function, click on the "Run test" button.
// If the result value is expected, you can store the result by clicking on the "Update test" button.
// Next time you run the test, the stored result will be compared with the actual result.
test {
  inspect!(fib(5))
  inspect!([1,2,3,4].map(fib))
}

// Add test name to make it more descriptive.
test "fibonacci" {
  inspect!(fib(5), content="5")
  inspect!(fib(6), content="8")
}

fn fib(n : Int) -> Int {
  if n < 2 {
    n
  } else {
    fib(n - 1) + fib(n - 2)
  }
}

