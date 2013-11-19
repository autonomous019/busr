module.exports = Poster;

// Constructor
function Poster(req) {
  // always initialize all instance properties
  this.mode = req.body.mode;
  console.log(req.body.mode);
  this.greeting = "Posting"; 
  
}

// class methods
Poster.prototype.greetingText = function() {

	if(this.mode == "contact"){
		this.greeting = "Contact Request Submitted";
		//console.log(this.greeting);
		
	} 
	return this.greeting;
	
  
}


Poster.prototype.controlContext = function() {
	
	return this.mode;
	
}