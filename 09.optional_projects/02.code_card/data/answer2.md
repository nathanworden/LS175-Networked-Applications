**Encapsulation** is hiding pieces of functionality and making it unavailable to the rest of the code base. It is a form of data protection, so that data cannot be manipulated or changed without obvious intention. It is what defines the boundaries in your application and allows your code to achieve new levels of complexity. Ruby, like many other OO languages, accomplishes this task by creating objects, and exposing interfaces (i.e., methods) to interact with those objects.

```ruby
class Rino
  def initialize(name)
    @name = name
  end

  def change_name(new_name)
      @name = new_name
  end
end
```

---