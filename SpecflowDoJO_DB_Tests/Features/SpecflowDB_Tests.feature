Feature: SpecflowDojo_DB example tests to test data load to table dbo.Customer and derivations in table dbo.CustomerProfile

 We will test simple database solution which is currently deployed on PLLWINMXCMFM1\DOJO,24212, Database name SpecFlowDojo_DB_X (X - number of your designated database).
 Solution has 3 load procedures (for loading data from Staging tables to base tables) and 2 data derivation procedures. 
 More information on database solution can be found in document "Specflow Dojo Database description.doc"

@exampleScenario
Scenario: Procedure dbo.usp_CustomerLoad - Test load data from staging to base table
	Given below tables are clean 
	| TableName            |
	| dbo.Staging_Customer |
	| dbo.Customer         |
	And I insert data into table dbo.Staging_Customer
	| CustomerID | FirstName | LastName  | PhoneNumber | RegistrationDate |
	| 1          | John      | Smith     |             | 2017-09-12       |
	| 2          | Sara      | Smith     |             | 2017-09-13       |
	| 2          | Sara      | Wilkinson |             | 2017-09-11       |
	When I execute procedure dbo.usp_CustomerLoad 
	Then the count in table dbo.Customer should be equal to 2

@exampleScenario
Scenario: Procedure dbo.usp_CustomerProfile - Test CustomerProfile TotalOrderCount derivation
	Given below tables are clean
    | TableName           |
    | dbo.Customer        |
    | dbo.Orders          |
    | dbo.CustomerProfile |
	And I insert data into table dbo.Customer
	| CustomerID | FirstName | LastName  | PhoneNumber | RegistrationDate |
	| 1          | John      | Smith     |             | 2017-09-12       |
	| 2          | Sara      | Wilkinson |             | 2017-09-12       |
	And insert data into table dbo.Orders
	| OrderID | CustomerID | OrderDate  | OrderStatus | ShippedDate |
	| 11      | 1          | 2017-09-12 | Complete    | 2017-09-13  |
	| 12      | 2          | 2017-09-12 | Ready       |             |
	| 13      | 1          | 2017-09-13 | Ready       |             |
	When I execute procedure dbo.usp_CustomerProfile
	Then TotalOrderCount in table dbo.CustomerProfile should be equal to 2 where CustomerID is 1

