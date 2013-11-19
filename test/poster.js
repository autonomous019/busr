var should = require('should');
var Poster = require('../poster');
//run '>npm test' to start tests, auto watching is on

describe('addition', function () {
 it('should add 1+1 correctly', function (done) {
   var onePlusOne = 1 + 1;
   onePlusOne.should.equal(2);
   // must call done() so that mocha know that we are... done.
   // Useful for async tests.
   done();
 });
});


describe("Poster", function(){  
  it("processes post requests for app", function(done){ 
	  Poster.greeting = "hello";
	  Poster.mode="contact";
	  Poster.controlContext(function(doc){
		  doc.mode.should.equal('Posting');
		  done();
		
	  });
  
  });
});