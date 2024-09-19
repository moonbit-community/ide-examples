fn main {
  // Define an integer variable with a value of 10.
  let a : Int = 10 

  // Type annotation in local is optional, MoonBit can infer the type.  
  let b = 20 

  // Variables are immutable by default, You can use mut keyword to make it mutable.
  let mut c = 0

  // Assign the sum of a and b to c.
  c = a + b
  println(c)
  
  // We also refer to an immutable variable as a binding to the value 10 with the type Int.  
  // Define a new binding named `b` and shadow the previous `b`.  
  let b = false
  println(b)
}