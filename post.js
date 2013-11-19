

// Constructor
function Poster(req) {
  // always initialize all instance properties
  this.mode = req.mode;
  this.greeting = "Posting"; 
  
}
// class methods
Poster.prototype.greetingText = function() {
	
	if(this.mode == "contact"){
		this.greeting = "Contact Request Submitted";
		console.log(this.greeting);
	}
};
// export the class
module.exports = Poster;