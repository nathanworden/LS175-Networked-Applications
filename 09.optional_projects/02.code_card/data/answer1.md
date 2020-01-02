Polymorphism is the ability of different objects to respond in different ways to the same message (i.e. method call.)

Polymorphism is the provision of a single interface to objects of different types.



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
# => arf!
kitty.speak
# => meow
```

