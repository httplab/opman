# Transactional services and operations

You can declare operation or service as transactional and then `#perform` method will be wrapped into ActiveRecord transaction.

```ruby
# app/operations/delete_document.rb
class DeleteDocument < Op::Operation
  operation_name :delete_document
  
  # declare operation as transactional
  transactional

  def perform(document_id)
    # Everything you do here will be wrapped in ActiveRecord transaction
  end
end
```

You can declare service as transactional and use it outside operation

```ruby
class CacheDocumentsCounter < Op::Service
  operation_name :cache_documents_counter

  # declare service as transactional
  transactional

  def perform
    # Everything you do here will be wrapped in ActiveRecord transaction
  end
end

# It works outside operation, #perform will be wrapped in transaction.
CacheDocumentsCounter.call
```

But if you use such service inside operation then only top level call will cause transaction

```ruby
# app/operations/delete_document.rb
class DeleteDocument < Op::Operation
  operation_name :delete_document
  transactional

  # There is top level transaction starts
  def perform(document_id)
    # Do something and then update counter
    
    # This call doesn't produce nested transaction.
    op(CacheDocumentsCounter).call
  end
end
```

Why not to use regular ActiveRecord transactions? We can not prohibit regular transactions it still work, 
but we need more control. We need to know when transaction starts whether rollback happens or not and so on to 
handle sending emails, running workers and publishing messages from inside #perform. 


