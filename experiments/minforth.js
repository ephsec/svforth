ctx = {
	d: {
		"dup": function() {
			s.push( s.pop(), s.pop() );
		},
		"rot": function() {
			s.push( s.shift() );
		},
		"-rot": function() {
			s = [ s.pop() ].concat(s);
		},
		"swap": function() {
			s.push( s.pop(), s.pop() );
		},
		"+": function() {
			s.push( ( s.pop() + s.pop() ) );
		},
		"-": function() {
			d.swap();
			s.push( s.pop() - s.pop() );
		},
		'*': function() {
			s.push( s.pop() * s.pop() );
		},
		'/': function() {
			d.swap();
			s.push( s.pop() / s.pop() );
		},
		'.s': function() {
			console.log( s );
		}
	},
	s: []
};

e = function(t) {
	s = this.s;
	d = this.d;

	if ( t.constructor === String ) {
		t = t.split(/\s/);
	}
	while ( t.length ) {
		w = t.shift();
		if ( w in d ) {
			d[w]();
		} else if ( !( isNaN( w ) ) ) {
			s.push( parseFloat( w ) );
		} else if ( w !== '' ) {
			s.push( w );
		};
	}
}

e.apply(ctx, ['1 2 3 .s rot .s + .s 1 - 2 * 2 / 1 .s -rot .s']);