# Operation

Operation is an entry point to application business logic. Operations define what and how and application does. 
All actions initiated by external world which change state of system should be defined as operations. All actions
state and progress of which have to be tracked should be defined as operations. 

Operation can be responsible and can do many things connected to each other. For example operation can create 
entities in database communicate with external API persist results and send notifications then. Operation defines 
workflow which should be fulfilled to get thing done.

`InviteUser`, `PublishPost`, `EditBillingSettings` have to be an operation. `SaveReportToPDF`, `CheckAvailableCredits`, 
`FetchQuestionsList` might not be operation because it does not seem that they change system state but we can declare they 
as operations in case if we want to track their progress or execution state.

## Operation context

Operation context is one of the most important things. Operation context defines environment in which operation executes.
In controllers we usually have `current_user` and `current_organization` in case of operations we have to define
context containing this (and maybe additional) data.

```ruby
# app/models/operation_context.rb
class OperationContext < Op::Context
  attr_reader :user

  def initialize(user)
    @user = user
  end

  # Check OperationState model to get full list of available emitters.
  def emitter_type
    :user
  end

  def emitter_id
    user.id
  end

  def to_s
    [:user, user.id, user.email].join(',')
  end

  def to_h
    {
      user_id: user.id,
      user_email: user.email
    }
  end
end
```

`emitter_type` and `emitter_id` define who is initiator of execution of operation. It might be `:user`, `:system` or someone else.

## Howto define and run operation

We have to put operations under `app/operations` directory. Technically operation inherits service class. It means that operation has the same interface as service class. Operation should define method `.perform` and return `Op::Result` similar to service class. 

```ruby
# app/operations/foo.rb
class Foo < Op::Operation
  self.operation_name = 'foo'

  def perform(name, greeting:)
    Op::Result.new(true, "#{greeting}, #{name}!")
  end
end
```

There are several important differences from service class. Since operation is entry point to application business logic it

1. CAN BE executed ONLY from controller, Sidekiq worker, message queue consumer, rails runner or console. 
2. CANNOT call another operation.
2. CANNOT BE called from inside service class.

It is easy to execute operation

```ruby
# ...somewhere in controller...

user = User.find(params[:user_id])
ctx = OperationContext.new(user) 

# just use .call shortcut
result = Foo.call(ctx, 'Alice', greeting: 'Hello')
if result.success?
  puts result.value # => "Hello, Alice!"
  
  # do something else here
end
```

Instead of use `.call` you can use get instance and call it

```ruby
operation = Foo.new(ctx)
result = operation.call('Alice', greeting: 'Hello')

# some code
```

## Operation name

Operation name is pretty important. It helps us to identify events related to operation execution in logs and audit records. 

```ruby
# app/operations/foo.rb
class Foo < Op::Operation
  self.operation_name = 'foo'
  
  # some code
end
```

If service class can be executed inside operation you must define its `operation_name` too

```ruby
# app/operations/foo.rb
class NotifyUser < Op::Service
  self.operation_name = 'notify_user'
  
  # some code
end
```