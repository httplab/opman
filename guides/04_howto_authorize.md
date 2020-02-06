# HOWTO authorize operation

You can define authorization step and check permissions inside it using plain ruby code 
or [pundit](https://github.com/varvet/pundit) for example

```ruby
# app/models/document.rb
class Document < ApplicationRecord
  belongs_to :author
end

# app/policies/document_policy.rb
class DocumentPolicy < ApplicationPolicy
  def destroy?
    document.user == user
  end
end

# app/operations/delete_document.rb
class DeleteDocument < Op::Operation
  operation_name :delete_document

  attr_reader :document

  step :prepare_document
  step :authorize

  def prepare_document(document_id)
    @document = Document.find(document_id)
  end

  def authorize(_document_id)
    return if DocumentPolicy.new(context.user, document).destroy?

    Op::Result::Forbidden.new('Current user cannot delete the document')
  end
  
  def perform(_document_id)
    document.destroy
  end
end
```

and then you can check result in controller and return error to user

```ruby

# app/controllers/documents_controller.rb
class DocumentsController < ApplicationController
  def destroy
    # You can add to context whatever you want to check authorization inside operation.
    ctx = OperationContext.new(current_user)
    operation = DeleteDocument.new(ctx)
    result = operation.call(params[:id])
    
    if result.fail? && result.error == :authorization
      render plain: result.message, status: :forbidden
      return
    end
    
    head 200
  end
end
```



