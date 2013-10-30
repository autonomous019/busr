require 'rubygems' #otherwise ,require 'json' will fail
require 'open-uri'
require 'json'
require 'redis'


redis = Redis.new(:timeout => 0)

# Optimized for writes, sort on read
 
# LVC
redis.hset("bonds|1", "bid_price", 96.01)
redis.hset("bonds|1", "ask_price", 97.53)
redis.hset("bonds|2", "bid_price", 95.50)
redis.hset("bonds|2", "ask_price", 98.25)
redis.sadd("bond_ids", 1)
redis.sadd("bond_ids", 2)
 
# different sorts
redis.sort("bond_ids", :by => "bonds|*->bid_price") # => ["2", "1"]
redis.sort("bond_ids", :by => "bonds|*->bid_price", :get => "bonds|*->bid_price") # => ["90.5", "96.01"]
redis.sort("bond_ids", :by => "bonds|*->bid_price", :get => ["bonds|*->bid_price", "#"]) # => ["90.5", "2", "96.01", "1"]
redis.sort("bond_ids", :by => "bonds|*->bid_price", :limit => [0, 1]) # => ["2"]
redis.sort("bond_ids", :by => "bonds|*->bid_price", :order => "desc") # => ["1", "2"]
redis.sort("bond_ids", :by => "bonds|*->ask_price") # => ["1", "2"]
redis.sort("bond_ids", :by => "bonds|*->ask_price", :store => "bond_ids_sorted_by_ask_price", :expire => 300) # => 2
 
# Matching results from index to DB
ids = redis_sort_results.map {|id| id.to_i}
bonds = Bond.find(ids)
bond_ids_to_bond = {}
 
bonds.each do |bond|
  bond_ids_to_bond[bond.id] = bond
end
 
ids.map do |id|
  bond_ids_to_bond[id]
end
 
# Or getting the results back is easy if you store the data
redis.hset("bonds|2", "values", data.to_json)
raw_json = redis.sort("bond_ids", :by => "bonds|*->bid_price", :get => "bonds|*->values")
results = raw_json.map do |json|
  DataObject.new(JSON.parse(json))
end