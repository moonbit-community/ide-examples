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

fn init {
  log("Get a UUID: ")
  log(fresh_uuid())
  log(", another UUID: ")
  log(fresh_uuid())
  println(context.log)
}

/// 2. use the `Ref`
pub let data : Ref[String] = @ref.ref("Data: ")

pub fn add_data[T : Show](x : T) -> Unit {
  data.update(fn { y => y + x.to_string() })
}

fn init {
  add_data("Hello, ")
  add_data("ref")
  println(data.val)
}
