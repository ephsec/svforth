var pg = require( 'pg' );

// database connection object, takes:
// { connParams:  connection parameters, usually a connection string
//   connType:    'pg' only for now
//   connObject:  we can use a previous connection object as a spec as well }
//
// This is intended to be inserted onto the stack and used by db query
// functions.  As these are objects, duplicating the object is effectively
// reuse of the same database connection.
function createDSObject(spec) {
	DSObject = {};

	if ( 'connParams' in spec ) { DSObject.connParams = spec.connParams } else
		{ throw( "No 'connParams' in createDSObject spec." ) };
  if ( 'connType' in spec ) { DSObject.connType = spec.connType } else 
    { DSObject.connType = 'pg' };
	if ( 'connObject' in spec ) { DSObject.connObject = spec.connObject } else
		{ DSObject.connObject = new pg.Client( DSObject.connParams );
      DSObject.connObject.connect(); };

  DSObject.query = function(context) {
    var currTime = new Date().getTime() / 1000;

    inParameters = context.stack.pop();
    inQuery = context.stack.pop();

    var currQuery = this.connObject.query(
      { text: inQuery,
        values: inParameters },
      function(err, result) {
      });

    // For each row, we insert into the stack.
    currQuery.on('row', function( row ) {
      // row.beginRowTime = new Date().getTime() / 1000;
      context.stack.push( row );
      // row.endRowTime = new Date().getTime() / 1000;
      // console.log( "Row processed in " + \ 
      //   ( row.endRowTime - row.beginRowTime ) + "s" );
    });

    // Once we're done, we close up and return execution to Forth.
    currQuery.on('end', function() {
      endTime = new Date().getTime() / 1000;
      console.log( "Query done in " +
        (endTime - currTime) + "seconds" )
      context.executeCallback( context );
    });
  }

  return( DSObject );
};

DatabaseFns = {
  // create-dbconn                       ( $connection-string -- dbConnObject )
  //
  // given a Postgres connection string such as 'postgres://user@dbhost/DB'
  // create a dbConnection object and insert it into the stack.
  "create-dbconn": function(context) {
    connParams = context.stack.pop();
    context.stack.push( createDSObject( { connParams: connParams } ) );
    context.executeCallback( context ); 
  },

  // query-db            ( $query [ parameters ] dbConnObject -- row0 .. rowN )
  // 
  // given a SQL query in a string, the parameters for the query in an array,
  // and a database connection object, execute the query and return rows.
  "query-db": function(context) {
    dbObject = context.stack.pop();
    dbObject.query(context);
  }
};

// direct SQL DB access from the browser? you're smoking crack.
//
// if (typeof initialDictionary !== 'undefined') {
//   initialDictionary.registerWords( DatabaseFns );
// }

if (typeof module != 'undefined' ) {
  module.exports.DatabaseFns = DatabaseFns; 
}

