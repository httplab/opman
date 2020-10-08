# Service class

Service class is thing which does minimal amount of work and follows SRP principle. You can call
service classes everywhere in application. Service class follows simple interface it returns
`success` by default if user does not return another result explicitly.

```ruby
# /app/services/say_hello.rb
class SayHello < Op::Service
  def perform(name)
    # First parameter of result is boolean specifies if call is successful or not.
    # Second parameter is value, return whatever you want.
    success("Hello, #{name}!")
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
    return failure(:user_not_found) unless user

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

## Raising and rescuing errors

Service class does not deal with errors. You need to raise and rescue errors by your own. Do it whatever
you want but keep in mind that it is not recommended to catch errors inside service classes without
subsequent re raising them.

## Custom result

You can define and return custom result

```ruby
# /app/services/notify_by_sms.rb
class NotifyBySMS < Op::Service
  class Result < Op::Result
    attr_reader :notified_count, :skipped_count

    def initialize(notified_count, skipped_count)
      @notified_count = notified_count
      @skipped_count = skipped_count

      # Let's say that we always have successful result
      super(true)
    end
  end

  def perform
    notified_count = 0
    skipped_count = 0

    User.find_each do |user|
      if notify(user)
        notified_count += 1
      else
        skipped_count += 1
      end
    end

    Result.new(notified_count, skipped_count)
  end
end
```

In application code you can check custom result similar as you can check regular result

```ruby
# ...somewhere in your code...

result = NotifyBySMS.call

return if result.fail?

puts "#{result.notified_count} users notified successfully, #{result.skipped_count} skipped"
# => "28 users notified successfully, 0 skipped"
```
