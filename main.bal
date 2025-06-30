import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;

mysql:Client dbClient = check new mysql:Client(
    "localhost", 
    "root", 
    "", 
    "eesconnectedenergy", 
    3307
);

type Anstalld record {
    int? id;
    string firstName;
    string lastName;
    string titel;
};

service /anstalld on new http:Listener(9090) {

    // GET: Hämta alla anställda
    resource function get .() returns json|error {
        sql:ParameterizedQuery query = `SELECT * FROM anstalld`;

        stream<Anstalld, error?> resultStream = dbClient->query(query);

       Anstalld[] resultList = [];

        error? e = resultStream.forEach(function(Anstalld row) {
            resultList.push(row);
        });

        check e;

        return <json>resultList;
    }

    // GET: Hämta en anställd via id
    resource function get [int id]() returns json|error {
        sql:ParameterizedQuery query = `SELECT * FROM anstalld WHERE id = ${id}`;

        stream<Anstalld, error?> resultStream = dbClient->query(query);

        Anstalld[] resultList = [];
        error? e = resultStream.forEach(function(Anstalld row) {
            resultList.push(row);
        });

        check e;

        if resultList.length() > 0 {
            return <json>resultList[0];
        } else {
            return {"message": "Ingen anställd hittades med angivet ID."};
        }
    }

    // POST: Lägg till ny anställd
    resource function post .(Anstalld newEmployee) returns json|error {
        sql:ParameterizedQuery query = `INSERT INTO anstalld (firstName, lastName, titel) 
                                        VALUES (${newEmployee.firstName}, ${newEmployee.lastName}, ${newEmployee.titel})`;

        sql:ExecutionResult result = check dbClient->execute(query);

        return {"message": "Ny anställd tillagd", "affectedRows": result.affectedRowCount};
    }

    // PUT: Uppdatera anställd
    resource function put [int id](Anstalld updatedEmployee) returns json|error {
        sql:ParameterizedQuery query = `UPDATE anstalld 
                                        SET firstName = ${updatedEmployee.firstName}, 
                                            lastName = ${updatedEmployee.lastName},
                                            titel = ${updatedEmployee.titel} 
                                        WHERE id = ${id}`;

        sql:ExecutionResult result = check dbClient->execute(query);

        return {"message": "Anställd uppdaterad", "affectedRows": result.affectedRowCount};
    } 

    // DELETE: Ta bort anställd
    resource function delete [int id]() returns json|error {
        sql:ParameterizedQuery query = `DELETE FROM anstalld WHERE id = ${id}`;

        sql:ExecutionResult result = check dbClient->execute(query);

        return {"message": "Anställd borttagen", "affectedRows": result.affectedRowCount};
    }  

}