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

## op() method

Operations framework defines factory method `op()`. We have to use it to instantiate entities to be called during
operation execution. This magic method is the glue which connects all entities involved to operation execution into
solid structure, propagate context, takes care on nested transactions and so on. We will provide more details in
following guides.

```ruby
# app/services/bar.rb
class Bar < Op::Service
  self.operation_name = 'bar'

  # some code
end

# app/operations/foo.rb
class Foo < Op::Operation
  self.operation_name = 'foo'
  
  def perform
    # Good. Use factory method op() to get instance of Bar service class and then call it.
    result = op(Bar).call
    
    # some dode
    
    # Bad. Just call Bar service class. It is working but this call lost all Operations Framework magic, 
    # context will be missing inside this call, audit and logging will be lost as well as other things 
    # like locks, transactional execution and so on.
    result = Bar.call
    
    # some code
  end
end
```

Do not execute service classes, Sidekiq workers, do not use mailers and do not publish messages without using `op()`
method to get instance of corresponding class. 

PLEASE NOTE that method `op()` is available not only directly inside operation but inside all involved service classes too. 
We collect and manage calls tree using method `op()`.

## Operation context propagation

When we use method `op()` to call service classes (and other parties) we automatically get operation context 
inside nested calls.


```ruby
# app/operations/baz.rb
class Baz < Op::Operation
  def perform
    op(Bar).call
  end
end

# app/services/foo.rb
class Bar < Op::Service
  def perform
    op(Foo).call
  end
end

# app/services/foo.rb
class Foo < Op::Service
  def perform
    # Get user from context and print email
    puts context.user.email # => "alice@domain.com"
  end
end

# some code

user = User.new('alice@domain.com')
ctx = OperationContext.new(user)

operation = Baz.new(ctx)

# Context is popagated down to call tree and available even inside `Bar#perform`
operation.call
```

## Operation names chaining


## Operation state
