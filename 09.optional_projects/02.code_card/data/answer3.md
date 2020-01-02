The block is an argument to the method call passed in at method invocation time. In other words, our familiar method, `[1, 2, 3].each { |num| puts num }`, is actually passing in the block of code to the `Array#each` method.

Blocks can take arguments, just like normal methods. But unlike normal methods, it won't complain about wrong number of arguments passed to it.

Blocks return a value, just like normal methods.

Blocks are a way to defer some implementation decisions to method invocation time. It allows method callers to refine a method at invocation time for a specific use case. It allows method implementors to build generic methods that can be used in a variety of ways.