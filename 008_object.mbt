// This example demonstrates trait objects in MoonBit
// Trait object turn static polymorphism of traits into dynamic polymorphism,
// and allows different data types implementing the same trait to be stored in the same data structure

trait Animal {
  speak(Self) -> Unit
}

struct Duck {
  name : String
}

fn speak(self : Duck) -> Unit {
  let name = self.name
  println("\(name): Quak!")
}

struct Fox {
  name : String
}

fn speak(self : Fox) -> Unit {
  let name = self.name
  println("\(name): What does the fox say?")
}

// trait [Animal], when used as type directly,
// represent trait objects of [Animal]
fn speak_together(xs : Array[Animal]) -> Unit {
  for i = 0; i < xs.length(); i = i + 1 {
    xs[i].speak()
  }
}

fn main {
  let duck1 = Duck::{ name: "duck1" }
  let fox1 = Fox::{ name: "fox1" }
  let duck2 = Duck::{ name: "duck2" }
  // use [expr as Trait] to explicitly create trait objects
  let duck1_animal : Animal = duck1 as Animal
  let fox1_animal : Animal = fox1 as Animal
  let duck2_animal : Animal = duck2 as Animal
  speak_together([duck1_animal, fox1_animal, duck2_animal])
  println("===")
  // MoonBit can automatically insert [as] using type information
  speak_together([duck1, fox1, duck2])
}
