# Operations Framework

* [Motivation](#motivation)
* [Code organization and style issues](#code-organization-and-style-issues)
* [System control issues](#system-control-issues)
* [Data consistency issues](#data-consistency-issues)
* [Solution](#solution)

## Motivation

During the life cycle of almost every Ruby on Rails application I was dealing with, 
there were a number of typical issues that made it difficult to investigate and 
fix problems and develop new features. These problems can be divided into three categories: 
code organization and style issues, system control issues, and data consistency issues.

## Code organization and style issues

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

## System control issues

### Missing user actions log

It is difficult to understand when and what kind of actions the user initiated. As a result, the system changes 
state, but we do not know exactly how, why and who initiated the changes. A typical problem is the consequences 
of editing billing settings. The user claims that he did not change anything, but the invoices were generated 
at the wrong time with the wrong amount.

### Workers and MQ consumers are black holes

We don’t know (or getting this information is very difficult) what exactly happens inside the sidekick, what 
exactly do the message queue consumers do. It would be great to be able to get information about which processes 
are running in the background, which are completed (successfully, or not), by whom and with what parameters were 
started.

### No way to get process execution progress

It is not clear at what stage is the process that takes a long time to complete. As a result, if the developer 
did not prepare logging, the only way to find out if the process is working or not is top tool. It would be 
great to have a simple tool that would allow us to track the progress of the operation.

### Lack of logging

Logging is often absent, or insufficient to obtain the necessary information during debugging. It would be great 
to automate logging, to make a tool that would allow you to track the sequence of calls (ideally with parameters) 
in the context of the executable process. For example, if in the context of registering a new user we add him to the 
mailing lists, it would be great to automatically get log entries about this (even if the developer forgot to 
explicitly use logger).

### No way to audit changes

There is no way to trace the history of a change in one or another entity. The user edits the billing plan and 
it’s quite difficult for us to establish when it was done, what values were before editing, to see the list of 
versions. It would be great to be able to get a history of changes in the properties of entities.
Sending messages, launching workers, interacting with external APIs from open (incomplete) transactions. For example, we add money to the user's account, send an alert about this, after the message is sent, an error occurs and rollback transactions occur. As a result, the user thinks that he has money in his account, but in fact there is none. It would be great to have a tool that would allow transparently delaying communication with the outside world until the transaction is successfully completed.

## Data consistency issues

### Forgotten transactions

Often there are no transactions, as a result, data is not stored atomically, data integrity is violated. 
It would be great to have instruments that simplify transactional support at the operation definition level. 
For example, declaring an operation as transactional would allow us to not worry about transactions within 
nested service classes calls during execution of the operation.

### Interaction with external worlds from open transactions

Often there are no transactions, as a result, data is not stored atomically, data integrity is violated. 
It would be great to have tools that simplify transactional support at the operation definition level. 
For example, declaring an operation as transactional might help us to not worry about transactions within 
nested sservice classes calls during operation execution.

### Forgotten locks

An obvious problem. We work with the same resource from several threads (processes) forget about locking and turn resource into an inconsistent state. It would be great to be able to set blocking conditions at the operation definition level and make it impossible to simultaneously launch several operations that perform actions with the same resource.

### Running multiple singletones in parallel

Some operations such as data synchronization in its nature do not imply the possibility of parallel launch. Such 
operations must be declared accordingly, which will automatically prevent run multiple instances.

## Solution

Solution is to make Operations Framework which can help us to avoid described mistakes and issues. 
Development includes three milestones

1. Basic infrastructure, operations, unification of service classes, logging, contexts, tracking status of execution.
2. Transactional, blocking, tracking progress.
3. Audit
