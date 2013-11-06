var pg = require( 'pg' );

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
    inQuery = context.stack.pop().join(" ");

    console.log( "QUERY:", inQuery );
    console.log( "PARAMETERS:", inParameters );

    var currQuery = this.connObject.query( { text: inQuery, values: inParameters },
      function(err, result) {
        console.log(err, result);
      });

    // For each row, we insert into the stack.
    currQuery.on('row', function(row) {
      console.log( "ROW:", row );
      context.stack.push( row );
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
  "create-dbconn": function(context) {
    connParams = context.stack.pop();
    console.log( connParams );
    context.stack.push( createDSObject( { connParams: connParams } ) );
    context.executeCallback( context ); 
  },

  "query-db": function(context) {
    dbObject = context.stack.pop();
    dbObject.query(context);
  }
};

if (typeof initialDictionary !== 'undefined') {
  initialDictionary.registerWords( DatabaseFns );
}

if (typeof module != 'undefined' ) {
  module.exports.DatabaseFns = DatabaseFns; 
}

