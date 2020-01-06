**Polymorphism** is the ability of different objects to respond in different ways to the same message (i.e. method call.)

Polymorphism is the provision of a single interface to objects of different types.

Here is an example where we have two different objects, a `rover` object of the `Dog` class, and a `kitty` object of the `Cat` class. `rover` and `kitty` are completely different, but they both respond to the `speak` method call.

```ruby
class Dog
  def speak
    puts "arf!"
  end
end

class Cat
  def speak
    puts "meow"
  end
end

rover = Dog.new
kitty = Cat.new

rover.speak
=> arf!
kitty.speak
=> meow
```
