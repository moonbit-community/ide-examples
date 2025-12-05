enum Color {
  Red
  Green
  Blue
  // RGB is an enum constructor that takes three Int arguments.
  // The enum in MoonBit is more powerful than traditional enums.
  // We will see more about this in pattern matching.
  RGB(Int,Int,Int)
  RGBA(Int,Int,Int,Int)
} 

fn print_color(color : Color) -> Unit {
  // Use a bit of pattern matching to distinguish different cases.
  // It's similar to switch-case in C-like languages in this example.  
  match color {
    Red => println("Red")
    Green => println("Green")
    Blue => println("Blue")
    // Take the three Int values from RGB and print them.
    RGB(r,g,b) => println("RGB: \{r}, \{g}, \{b}")
    RGBA(r,g,b,a) => println("RGBA: \{r}, \{g}, \{b}, \{a}")
  }
}

fn main {
  let red = Red
  // Just like the struct initialization, you can use "TypeName::" to make it more explicit.
  let green = Color::Green
  let blue_rgb = RGB(0, 0, 255)
  let blue_simple = Blue // Use Blue constructor to fix warning
  let rgba_color = RGBA(255, 0, 0, 128) // Use RGBA constructor to fix warning
  
  print_color(red)
  print_color(green)
  print_color(blue_rgb)
  print_color(blue_simple)
  print_color(rgba_color)
}