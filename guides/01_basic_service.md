# Service class

Service class is thing which does minimal amount of work and follows SRP principle. You can call service classes everywhere in
application. Service class follows simple interface and always must return result.

```ruby
# /app/services/say_hello.rb
class SayHello < Op::Service
  def perform(name)
    # First parameter of result is boolean specifies if call is successfull or not. Second parameter is 
    # value, return whatever you want.
    Result.new(true, "Hello, #{name}!")
  end
end
```

You can call service class and get result using method `.call`.

```ruby
# ...somewhere in your code...
result = SayHello.call("Alice")

if result.success?
  puts result.value # => "Hello, Alice!"

  # and do something else
end
```

## Failures

You can return failure in case if something is wrong

```ruby
# /app/services/say_hello.rb
class SayHello < Op::Service
  def perform(email)
    user = User.find_by(email: email)
    
    # Return result with false as the first parameter and error as the second.
    return Result.new(false, :user_not_found) unless user

    # Do something if user found    
  end
end

```

And check result

```ruby
# ...somewhere in your code...
result = SayHello.call("alice@example.com")

if result.fail?
  puts "Cannot greet user because of #{result.error}."

  # and do something else
end
```

Service class does not handle errors. You need to handle errors himself but keep im mind 
that it is not recommended to catch errors inside service classes without subsequent re raising them. 

## Custom result
