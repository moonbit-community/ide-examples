struct Point {
  x : Int
  y : Int
} derive(Show)

struct MutPoint {
  mut mx : Int
  mut my : Int
} derive(Show)

fn main {
  // Create a new Point, MoonBit will infer the type from the field.
  let point = { x: 3, y: 4 }
  // You can also add more type infomation for struct initialization.
  let point2 = Point::{ x: 3, y: 4 }
  println("point:")
  println(point)
  println(point2)

  // Functional update syntax. 
  // It creates a new Point with the same values as point, except for x.
  println({ ..point, x: 20 })


  // Create a MutPoint. 
  let point3 = { mx: 3, my: 4 }
  // Make the point4 point to the same MutPoint as point3.
  let point4 = point3
  // As the field of MutPoint is defined with mut keyword, 
  // you can change the value inside.
  point3.mx = 5
  point3.my = 6
  println("mutable point: ")
  println(point3)
  println(point4)
}

