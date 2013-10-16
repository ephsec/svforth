function executeCallback(callback)
{
  if( typeof callback != 'undefined' ) {
    callback();
  }
}

function Word( name, fn )
{
    dictionary.register( name, fn );
}

byteArrayToHex = function(byteArray) {
    value = '\\x' + byteArray.toString('hex');
    return value;
}

