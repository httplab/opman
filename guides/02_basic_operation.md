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
