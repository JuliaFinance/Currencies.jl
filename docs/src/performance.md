# Notes on Performance

This package abstracts the currency as part of the type, and not part of this
value. This allows for increased performance, at some compile-time cost. For
each currency, each arithmetic operation used on that currency incurs some small
one-time cost.

Note that the the only overhead for most arithmetic operations is just an
indirection from the equivalent operation on integers:

```julia
julia> code_native(+, (typeof(USD), typeof(USD)))
  .text
Filename: ~/.julia/v0.5/Currencies/src/monetary.jl
Source line: 64
    pushq   %rbp
    movq    %rsp, %rbp
Source line: 64
    movq    (%rsi), %rax
    addq    (%rdi), %rax
    popq    %rbp
    ret

julia> code_native(+, (typeof(100), typeof(100)))
    .text
Filename: int.jl
Source line: 8
    pushq   %rbp
    movq    %rsp, %rbp
Source line: 8
    addq    %rsi, %rdi
    movq    %rdi, %rax
    popq    %rbp
    ret
```
