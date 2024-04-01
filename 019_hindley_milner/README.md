# Hindley-Milner type inference + higher kinded polymorphism

This is an implementation of the Hindley-Milner type inference algorithm for a tiny ML-like language.
In addition to classic ML polymorphism, it also supports higher kinded polymorphism.

To play with the implementation, checkout `main.mbt` where you can find some basic examples.
You can also try out other examples by editting `main.mbt` directly.

The source code of the main type inference algorithm is in `typecheck.mbt`.
`parser.mbt` contains a simple tokenizer & parser for the language.
