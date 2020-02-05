# HOWTO validate user input

Sometimes it requires to validate user input and perform operation only if input is valid. It can be achieved by using
steps.

```ruby
# app/operations/save_client.rb
class SaveClient < Op::Operation
  operation_name :save_client

  attr_reader :client

  step :prepare_client
  step :validate, discard_state_on_fail: true

  def prepare_client(email)
    @client = Client.new(email: email)
  end

  def validate(_email)
    Op::Result::ValidationFail.new(client) unless client.valid?
  end
  
  def perform(_email)
    client.save!
  end
end
```

You can inspect validation errors from result

```ruby
operation = SaveClient.new(context)
result = operation.call('wrong.email')

result.fail? # => true
result.error # => :validation

error = result.details[0]
error.source  # => :email
error.error   # => :invalid
error.details # => "is invalid"
error.value   # => "wrong.email"
```

You also can easily get ActiveModel::Validation errors (in case if you target supports it)

```ruby
result.value.errors
```
