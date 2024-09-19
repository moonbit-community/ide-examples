struct Point {
  x : Int
  y : Int
} derive(Show)

enum Color {
  Red
  Blue
  Green
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
  let (a, b, c) = tuple
  let [d, e, f] = array
  let { x, y } = record
}

/// We mentioned that these use cases are just basic examples of pattern matching.
/// In MoonBit, almost every type you can construct has a form to "destruct", 
/// which we call a pattern.
/// 
/// There are two common place to use pattern: let and match statement.
fn use_pattern_in_let_and_match(color : Color) -> Unit {
  // In let statement, on the left side of the "=" is a pattern. 
  // If the pattern doesn't match the value on the right side, it will abort the program.
  let Blue = color

  // In match statement, after the "match" keyword, every case has a form like "pattern => expression".
  // The first pattern that matches the value will execute the corresponding expression.
  // if no pattern matches, it will abort the program.
  match color {
    Blue => println("Blue")
    Green => println("Green")
    Red => println("Red")
  }
}

/// Here are some useful patterns for arrays and structs.
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
  let [d, e, ..] = array
  let [.., f, g] = array
  let [h,  ..,  i] = array
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

}

/// Patterns can be nested, give an alias, or use "|" to write multiple alternative patterns.
fn complex_pattern_match(
  num : Int,
  array : Array[Color],
  color : Color,
  color2 : Color
) -> Unit {
  // Use or pattern "|" to compose multiple patterns.
  match (color, color2) {
    (Red, Red) | (Blue, Blue) | (Green, Green) => println("both are red, blue or green")
    _ => println("others")
  }

  // Give an alias to the pattern by "pattern as name" so we can print the matched value.
  match array {
    // ignore the first element, and bind the rest to "rest".
    [_, .. as rest] => println(rest)
    _ => println("others")
  }

  // Match the enum constructor with variable patterns inside.
  // The r, g, b are the variable patterns inside.
  match color {
    RGB(r, g, b) => println("RGB: \{r}, \{g}, \{b}")
  }

  // If two patterns introduce the same binding (same name and types), 
  // they can be combined with the or pattern.
  match color {
    RGB(r, g, b) | RGBA(r, g, b, _) =>
      println("red, green and blue: \{r}, \{g}, \{b}")
  }
}

/// More pattern matching: map pattern
/// 
fn map_pattern(map : Map[String, Point]) -> Unit {
  match map {
    { "guest": { x, y } } => println("guest's position: \{x}, \{y}")
    { "alice": alice_pos, "bob": bob_pos } => {
      println("alice's position: \{alice_pos}")
      println("bob's position: \{bob_pos}")
    }
  }
}
