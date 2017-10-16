using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using TechTalk.SpecFlow;
using TechTalk.SpecFlow.Assist;

namespace SpecflowDoJO_DB_Tests
{

    [Binding]

    public class SpecflowDB_TestsSteps
    {
        SpecFlowDojo_DBEntities _db;
      

        [BeforeScenario]
        public void InitializeScenario()
        {
            ScenarioContext.Current["DB"] = _db = new SpecFlowDojo_DBEntities();

        }

        [Given(@"below tables are clean")]
        public void GivenBelowTablesAreClean(Table table)
        {
            var db = (DbContext)ScenarioContext.Current["DB"];

            foreach (var row in table.Rows)
            {
                foreach (var property in row.Keys)
                {
                    string query = "TRUNCATE TABLE " + row[property];
                    db.Database.ExecuteSqlCommand(query);
                }

            }
        }
        
        [Given(@"I insert data into table dbo.Staging_Customer")]
        public void GivenIInsertDataIntoTableDbo_Staging_Customer(Table table)
        {
            IEnumerable<Staging_Customer> listOfData = table.CreateSet<Staging_Customer>();
            _db.Staging_Customer.AddRange(listOfData);
            _db.SaveChanges();
        }
        
        [When(@"I execute procedure (.*)")]
        public void WhenIExecuteProcedure(string procedureName)
        {
            _db.Database.ExecuteSqlCommand(procedureName);
        }
        
        [Then(@"the count in table (.*) should be equal to (.*)")]
        public void ThenTheCountInTableShouldBeEqualTo(string tableName, int count)
        {
            string query = "select count(*) from " + tableName;
            int result = _db.Database.SqlQuery<int>(query).SingleAsync().Result;
            Assert.AreEqual(count, result);
        }

        [Given(@"I insert data into table dbo.Customer")]
        public void GivenIInsertDataIntoTableDbo_Customer(Table table)
        {
            IEnumerable<Customer> listOfData = table.CreateSet<Customer>();

            _db.Customer.AddRange(listOfData);
            _db.SaveChanges();
        }

        [Given(@"insert data into table dbo.Orders")]
        public void GivenInsertDataIntoTableDbo_Orders(Table table)
        {
            IEnumerable<Orders> listOfData = table.CreateSet<Orders>();

            _db.Orders.AddRange(listOfData);
            _db.SaveChanges();
        }

        [Then(@"(.*) in table (.*) should be equal to (.*) where (.*) is (.*)")]
        public void ThenInTableShouldBeEqualTo(string columnName, string tableName, string expValue, string idColumn, string idValue)
        {
            string query = "select " + columnName + " from " + tableName + " WHERE " + idColumn + " = " + idValue;
            
            var result = _db.Database.SqlQuery<string>("select cast((" + query + ")as nvarchar)").SingleAsync().Result;
            Assert.AreEqual(expValue, result);
        }

    }
}
