fn square(x : Int) -> Int {
  x * x
}

fn init {
  let x = {
    println("hello moonbit")
    1 + 1
  }
  let z : Int = square(x)

}

fn init {
  println("==============")
}

fn init {
  let z : Int = {
      println("hello moonbit")
      1 + 1
    } *
    {
      println("hello moonbit")
      1 + 1
    }

}

struct Ref[T] {
  mut val : T
}

fn init {
  let ref_ : Ref[Int] = { val: 1 } // ref is just a binding ref 本身只是一个数据绑定
  ref_.val = 10 // the field of the struct can be modified 我们可以修改结构体的字段
  println(ref_.val.to_string()) // output 10 输出 10
}

fn init {
  println("===============")
}

fn alter(a : Ref[Int], b : Ref[Int]) -> Unit {
  a.val = 10
  b.val = 20
}

fn init {
  let x : Ref[Int] = { val: 1 }
  alter(x, x)
  println(x.val.to_string()) // x.val will be updated twice x.val的值将会被改变两次
}

fn init {
  for i = 0; i < 2; i = i + 1 {
    println("Output")
  } // print twice 重复输出2次
  println("======")
  fn loop_(i : Int) {
    if i < 2 {
      println("Hello!")
      loop_(i + 1)
    } else {
      ()
    }
  }

  loop_(0) // print twice 重复输出2次
  println("======")
  fn print_first_3() {
    for i = 0; i < 10; i = i + 1 {
      if i == 3 {
        break // skip all cases larger than 3 跳过从3开始的情况
      } else {
        println(i.to_string())
      }
    }
  }

  print_first_3()
  println("======")
  fn print_skip_3() {
    for i = 0; i < 10; i = i + 1 {
      if i == 3 {
        continue // skip 3 跳过 3
      } else {
        ()
      }
      println(i.to_string())
    }
  }

  print_skip_3()
  println("======")
  fn fib_mut(n : Int) -> Int { // same output for the same input 对于相同输入，总是有相同输出
    let mut acc1 = 0
    let mut acc2 = 1
    for i = 0; i < n; i = i + 1 {
      let t = acc1 + acc2
      acc1 = acc2
      acc2 = t
    }
    acc1
  }

  println(fib_mut(10))
}
