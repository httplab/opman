# Operations Framework

## Motivation

During the life cycle of almost every Ruby on Rails application I was dealing with, 
there were a number of typical problems that made it difficult to investigate and 
fix problems and develop new features. These problems can be divided into three categories: 
code organization and style problems, system control problems, and data consistency problems.

## Code organization and style problems

### Differently designed service classes

Some service classes return a value, some a reference to themselves, others are designed as 
modules with self-methods. As a result, looking at a call to a service class, it is difficult to 
understand what it will return and how to work with the result. It would be great to unify 
the interfaces.

### Lack of a single entry point

The application has a large number of namespaces of different levels of nesting, namespaces contain 
service classes that call each other in a different order. As a result, it is difficult to understand 
where the job begins, where it ends, which entities are involved in the process.

### Reusage of code inside controllers, workers, MQ consumers

Implementing the functionality is “nailed” to the controller, sidekick worker, or MQ consumer. 
As a result, attempts to reuse come down to instantiating the corresponding class somewhere deep 
in the call stack and manually executing it in weird way such as `MyAwesomeSidekiqWorker.new.perform`.

### Lack of context

In controllers, we usually have current_user, current_organization, but this data is not available in
service classes below the call stack. In sidekick workers, MK consumers, access to this data is completely
difficult. As a result, changes are occurring in the system and we have no way to determine which user
was the initiator of these changes and with which parameters and context they happened.


