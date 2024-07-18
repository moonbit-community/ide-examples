# Derivative based regular expression implementation

This is a simple, elegant yet efficient implementation of regular expressions,
using the concept of "derivatives".
The derivative of a regular expression `r` relative to some character `c` is another regular expression `r'`,
such that `r` matches `c . s` if and only if `r'` matches `s`, where `s` is an arbitary string and `.` is concatenation of string.

Derivatives can be used two implement in two ways:

- Derivatives can be used to build an interpreter for regular expression, which repeatedly compute derivatives using characters in input string.
This is very simple but inefficient. See `Regex::matches` in `regex.mbt` for more details

- Derivatives can also be used to compile regular expressions to state machines.
Compare to the classic `Regex -> NFA -> DFA` algorithm without DFA minimalisation,
derivative based compiler usually produces smaller state machine.
See `Regex::compile` in `regex.mbt` for more details

You can find some examples and play with the implementation in `regex_test.mbt`.
The main code is in `regex.mbt`, and `parser.mbt` contains a simple parser for regular expressions.

## References

<https://www.khoury.northeastern.edu/home/turon/re-deriv.pdf>
