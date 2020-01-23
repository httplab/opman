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
