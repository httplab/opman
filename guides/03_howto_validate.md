# HOWTO validate user input

Sometimes it requires to validate user input and perform operation only if input is valid. It can be achieved by using
steps.

```
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

