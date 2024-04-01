let x: Int = 10
let a: Double = 3.14
let s: String = "Hello"

// the following code compiles 下方的代码可以编译
let 通过编译: Int = x + (a + 0.2).to_int() 

// code on line 10 does not compile, uncomment (remove the `//`) to see error 
// 第10行的代码无法通过编译，取消注释（删除行首的`//`）来查看错误提示
// let 不通过编译: String = s + (a + 0.2).to_int()

// The following codes are tested with assertions.
// If the assertion is failed, the program will fail
// 下方代码利用断言判断。如果断言未满足，程序将失败
test {
  // logical and 逻辑与
  assert_false_断言为假(true && false)
  // logical or 逻辑或
  assert_true_断言为真(false || true)
  // logical not 逻辑否
  assert_false_断言为假(not(true))

  // division between integers 整数相除
  assert_equals_断言相等(-1, -4 / 3)
  // integer overflow 整数溢出
  assert_equals_断言相等(-2147483648, 2147483647 + 1)
  // will not overflow if they were 64 bits integer 利用64位整数则不会溢出
  assert_equals_断言相等(2147483648L, 2147483647L + 1L)
  // will overflow if convert back to 32 bits integer 如果转回32位整数会溢出
  assert_equals_断言相等(-2147483648, 2147483648L.to_int())
  
  // addition of floating point numbers is not accurate 浮点数加法并不精准
  assert_not_equals_断言不相等(0.3, 0.1 + 0.2)
  assert_not_equals_断言不相等(0.1, 0.1 + 0.2 - 0.2)

  // convert char to/from charcode 字符与编码转换
  assert_equals_断言相等(65, 'A'.to_int())
  assert_equals_断言相等('A', Char::from_int(65))

  // accessing tuple 多元组访问
  assert_equals_断言相等(2023, (2023, 10, 24).0)
  assert_equals_断言相等(3, ("Bob", 3).1)
}

fn assert_true_断言为真(b : Bool) -> Unit {
  if b.not() { abort("") }
}

fn assert_false_断言为假(b : Bool) -> Unit {
  if b { abort("") }
}

fn assert_equals_断言相等[T : Eq](expected : T, actual : T) -> Unit {
  if (expected == actual).not() { abort("") }
}

fn assert_not_equals_断言不相等[T : Eq](expected : T, actual : T) -> Unit {
  if expected == actual { abort("") }
}
