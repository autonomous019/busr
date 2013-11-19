describe('Creating a new Poster',function(){
    var post;

    before(function(done){
      Poster.create({ mode: 'test' , greeting: 'hello', function(err,p){
        post = p;
        done();        
      });
    });

    it('should have a mode',function(){
      post.should.have.property('mode','test');
    });
	
    it('should have a mode',function(){
      post.should.have.property('greeting','hello');
    });
  });
