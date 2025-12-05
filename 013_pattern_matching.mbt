struct Point {
  x : Int
  y : Int
} derive(Show)

///|
enum Color {
  Red
  Green
  Blue
  RGB(Int, Int, Int)
  RGBA(Int, Int, Int, Int)
} derive(Show)

/// We have seen pattern matching in the previous example. 
/// It's a powerful feature in MoonBit that can be used in many places.
/// Some other language call it "destructuring", a way to 
/// extract values from a complex data structure:     
fn destructing(
  tuple : (Int, Bool, Double),
  array : Array[Int],
  record : Point
) -> Unit {
  guard tuple is (a, b, c)
  guard array is [d, e, f]
  guard record is {x, y}
  // Use the variables to fix unused warnings
  println("Tuple: \{a}, \{b}, \{c}")
  println("Array: \{d}, \{e}, \{f}")
  println("Point: \{x}, \{y}")
}





///| We mentioned that these use cases are just basic examples of pattern matching.
/// In MoonBit, almost every type you can construct has a form to "destruct", 
/// which we call a pattern.
/// 
/// There are two common place to use pattern: let and match statement.
fn use_pattern_in_let_and_match(color : Color) -> Unit {
  // In match statement, after the "match" keyword, every case has a form like "pattern => expression".
  // The first pattern that matches the value will execute the corresponding expression.
  // if no pattern matches, it will abort the program.
  match color {
    Red => println("Red")
    Green => println("Green")
    Blue => println("Blue")
    RGB(r, g, b) => println("RGB: \{r}, \{g}, \{b}")
    RGBA(r, g, b, a) => println("RGBA: \{r}, \{g}, \{b}, \{a}")
  }
}

///| Here are some useful patterns for arrays and structs.
fn basic_pattern_match(num : Int, color : Color) -> Unit {
  // 1. constant pattern
  match true {
    true => println("true")
    false => println("false")
  }

  // 2. any pattern
  match num {
    1 => println("one")
    // use "_" to match any value and ignore it.
    _ => println("others")
  }

  // 3. more array pattern 
  // Use ".." in array pattern to match the rest of the array.
  let array = [1, 2, 3, 4, 5]
  guard array is [d, e, ..]
  guard array is [.., f, g]
  guard array is [h, .., i]
  
  println("first two element of array: \{d}, \{e}")
  println("last two element of array: \{f}, \{g}")
  println("first and last element of array: \{h}, \{i}")

  // 4. more struct pattern
  // Use ".." in struct pattern to match the rest of the fields.
  let { x, .. } = { x: 1, y: 2 }
  println("field x of point: \{x}")
  // Match the field x of Point struct and bind it with another name.
  let { x: pos_x, .. } = { x: 1, y: 2 }
  println("field x of point: \{pos_x}")

  // 5. variable pattern
  // You already know that `let x = 10` means create a variable x with initail value of 10.
  // The "x" is also a pattern, which means match any value and bind it to x.
  let x = 10
  println("x is: \{x}") // Use x to fix unused warning
  
  // Use color to fix unused warning
  println("Color: \{color}")
}

///| Patterns can be nested, give an alias, or use "|" to write multiple alternative patterns.
fn complex_pattern_match(
  num : Int,
  array : Array[Color],
  color : Color,
  color2 : Color
) -> Unit {
  // Use or pattern "|" to compose multiple patterns.
  match (color, color2) {
    (Red, Red) | (Green, Green) | (Blue, Blue) =>
      println("both are red, green or blue")
    _ => println("others")
  }

  // Give an alias to the pattern by "pattern as name" so we can print the matched value.
  match array {
    // ignore the first element, and bind the rest to "rest".
    [_, .. rest] => println(rest)
    _ => println("others")
  }

  // Match the enum constructor with variable patterns inside.
  // The r, g, b are the variable patterns inside.
  match color {
    Blue => println("Blue")
    Green => println("Green")
    Red => println("Red")
    RGB(r, g, b) => println("RGB: \{r}, \{g}, \{b}")
    RGBA(r, g, b, a) => println("RGBA: \{r}, \{g}, \{b}, \{a}")
  }

  // If two patterns introduce the same binding (same name and types), 
  // they can be combined with the or pattern.
  match color {
    Blue => println("Blue")
    Green => println("Green")
    Red => println("Red")
    RGB(r, g, b) | RGBA(r, g, b, _) =>
      println("red, green and blue: \{r}, \{g}, \{b}")
  }
  
  // Use num to fix unused warning
  println("Number: \{num}")
}

///| More pattern matching: map pattern
/// 
fn map_pattern(map : Map[String, Point]) -> Unit {
  match map {
    { "guest": { x, y }, .. } => println("guest's position: \{x}, \{y}")
    { "alice": alice_pos, "bob": bob_pos, .. } => {
      println("alice's position: \{alice_pos}")
      println("bob's position: \{bob_pos}")
    }
    _ => println("Parsing Error")
  }
}

///| Main function to demonstrate all the pattern matching features
fn main {
  // Use all the functions to fix unused warnings
  destructing((42, true, 3.14), [1, 2, 3], {x: 10, y: 20})
  
  let red = Red
  let green = Green  
  let blue = Blue
  let rgb_color = RGB(255, 128, 0)
  let rgba_color = RGBA(255, 0, 0, 128)
  
  use_pattern_in_let_and_match(red)
  use_pattern_in_let_and_match(green)
  use_pattern_in_let_and_match(blue)
  use_pattern_in_let_and_match(rgb_color)
  use_pattern_in_let_and_match(rgba_color)
  
  basic_pattern_match(5, red)
  
  complex_pattern_match(10, [red, green, blue], rgb_color, rgba_color)
  
  let sample_map : Map[String, Point] = { "guest": {x: 5, y: 10}, "alice": {x: 1, y: 2}, "bob": {x: 3, y: 4} }
  map_pattern(sample_map)
}