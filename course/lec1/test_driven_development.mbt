// Question: You can exchange `num_exchange` empty bottles for a bottle of water from a shop.
// 问题：每`num_exchange`个空瓶子，可以从商店换来一瓶水
//
// You have `num_bottles` bottles of water at the beginning.  
// How many bottles of water can you drink at most?
// 你最初拥有`num_bottles`瓶水，最多能喝几瓶水？
fn num_water_bottles(num_bottles : Int, num_exchange : Int) -> Int {
  fn consume(num_bottles, num_drunk) {
    if num_bottles >= num_exchange {
      let num_bottles = num_bottles - num_exchange + 1
      let num_drunk = num_drunk + num_exchange
      consume(num_bottles, num_drunk)
    } else {
      num_bottles + num_drunk
    }
  }

  consume(num_bottles, 0)
}

// We recommend the test driven development
// 我们推荐测试驱动的开发
test "Expected behavior of num_water_bottles" {
  assert(num_water_bottles(9, 3) == 13)
  assert(num_water_bottles(15, 4) == 19)
}

fn assert(test1 : Bool) -> Unit {
  if test1.not() {
    abort("Test failed")
  }
}
