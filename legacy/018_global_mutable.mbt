/// Since MoonBit considers global mutable variables harmful,
/// declaring a mutable variable directly in the global scope is not allowed.
///
/// In some cases where global mutable state is necessary,
/// we can use a struct with mutable fields or use the `Ref` instead.

/// 1. use a struct with mutable fields
pub struct Context {
  mut uuid : Int
  mut log : String
}

pub let context : Context = { uuid: 0, log: "" }

pub fn fresh_uuid() -> Int {
  context.uuid += 1
  context.uuid
}

pub fn log[T : Show](x : T) -> Unit {
  context.log += x.to_string()
}

test {
  log("Get a UUID: ")
  log(fresh_uuid())
  log(", another UUID: ")
  log(fresh_uuid())
  inspect!(context.log, content="Get a UUID: 1, another UUID: 2")
}

/// 2. use the `Ref`
pub let data : Ref[String] = @ref.new("Data: ")

pub fn add_data[T : Show](x : T) -> Unit {
  data.update(fn { y => y + x.to_string() })
}

test {
  add_data("Hello, ")
  add_data("ref")
  inspect!(data.val, content="Data: Hello, ref")
}

fn main {
  
}
