// This example demonstrate how to calculate the nth Fibonacci number in various ways in MoonBit.

/// Calculate the nth Fibonacci number using recursion and pattern matching.
fn fib(n : Int) -> Int {
  match n {
    0 => 0
    1 => 1
    _ => fib(n - 1) + fib(n - 2)
  }
}

/// Calculate the nth Fibonacci number using **loop** and pattern matching.
fn fib2(n : Int) -> Int {
  // Moonbit will convert recursion to loop automatically
  fn aux(n, acc1, acc2) {
    match n {
      0 => acc1
      1 => acc2
      _ => aux(n - 1, acc2, acc1 + acc2)
    }
  }

  aux(n, 0, 1)
}

/// Calculate the nth Fibonacci number using MoonBit's "loop" construct
fn fib3(n : Int) -> Int {
  loop n, 0, 1 {
    0, acc2, _ => acc2
    n, acc2, acc1 => continue n - 1, acc1, acc1 + acc2
  }
}

/// Calculate the nth Fibonacci number using MoonBit's for-loop
fn fib4(n : Int) -> Int {
  for i = 0, acc2 = 0, acc1 = 1 // initialize loop variables
      i < n // loop condition
      i = i + 1, acc2 = acc1, acc1 = acc1 + acc2 {
    // update loop variables
  } else {
    acc2
  }
}

fn main {
  println(fib(3))
  println(fib2(46))
  println(fib3(46))
  println(fib4(46))
}
