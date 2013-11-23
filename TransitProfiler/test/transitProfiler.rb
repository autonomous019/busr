# in shell in /TransitProfiler/test dir:   >rspec transitProfiler.rb 

#Test method called in rspec
def test
  "testing"
end
 
#Method we want to test with rspec
def get_first_last_letter(word_list)
 
  first_last_letter = [] #array initialization
 
  #extract the first and last letter from each word
  word_list.each { |x| first_last_letter << "#{x[0]}#{x[-1]}" }
 
  return first_last_letter
end
 
#Executing the script without rspec testing
  if (File.basename($0)) == File.basename(__FILE__)
 
    word_list = ["cocoa", "animal", "felt", "fertile"]
    puts get_first_last_letter(word_list)
    exit 0
end
 
#testing with rspec
describe "testDev" do
  it "testing" do
 
  word_list = ["cocoa", "animal", "felt", "fertile"]
 
  #testing expected outcome
  get_first_last_letter(word_list).should eql (["ca","al","ft", "fe"])
 
  end
end