require 'csv'
require 'rubygems' #otherwise ,require 'json' will fail
require 'open-uri'
require 'json'
require 'redis'

module GTFS
  module Model
    def self.included(base)
      base.extend ClassMethods

      base.class_variable_set('@@prefix', '')
      base.class_variable_set('@@optional_attrs', [])
      base.class_variable_set('@@required_attrs', [])

      def valid?
        !self.class.required_attrs.any?{|f| self.send(f.to_sym).nil?}
      end

      def initialize(attrs)
        attrs.each do |key, val|
          instance_variable_set("@#{key}", val)
          
        end
        
      end
    end

    module ClassMethods

      #####################################
      # Getters for class variables
      #####################################

      def prefix
        self.class_variable_get('@@prefix')
      end
      

      def optional_attrs
        self.class_variable_get('@@optional_attrs')
      end

      def required_attrs
        self.class_variable_get('@@required_attrs')
      end

      def attrs
       required_attrs + optional_attrs
      end

      #####################################
      # Helper methods for setting up class variables
      #####################################

      def has_required_attrs(*attrs)
        self.class_variable_set('@@required_attrs', attrs)
      end

      def has_optional_attrs(*attrs)
        self.class_variable_set('@@optional_attrs', attrs)
      end

      def column_prefix(prefix)
        self.class_variable_set('@@prefix', prefix)
      end

      def required_file(required)
        self.define_singleton_method(:required_file?) {required}
      end

      def collection_name(collection_name)
        self.define_singleton_method(:name) {collection_name}

        self.define_singleton_method(:singular_name) {
          self.to_s.split('::').last.
            gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
            gsub(/([a-z\d])([A-Z])/,'\1_\2').
            tr("-", "_").downcase
        }
      end

      def uses_filename(filename)
        self.define_singleton_method(:filename) {filename}
      end

      def each(filename)
        
        CSV.foreach(filename, :headers => true) do |row|
          require 'json'
          # => true
       
          yield parse_model(row.to_hash)
        end
        
      end
      
      ##### filter_list() #####################
      # 
      #
      #
      ########################################
      def filter_list(model_name)
        #get list of attributes per model
          modeler = model_name.to_s
          result = case modeler
             when 'agency_' then return "name url timezone id lang phone fare_url"
             when 'stops_' then return "id name lat lon code desc zone_id url location_type parent_station timezone wheelchair_boarding"
             when 'calendar_date_' then return "service_id date exception_type"
             when 'calendar_' then return "service_id monday tuesday wednesday thursday friday saturday sunday start_date end_date"
             when 'fare_attribute_' then return "fare_id price currency_type payment_method transfer_duration transfers"
             when 'fare_rule_' then return "fare_id route_id origin_id destination_id contains_id"
             when 'frequency_' then return "trip_id start_time end_time headway_secs exact_times"
             when 'route_' then return "id short_name long_name type agency_id desc url color text_color"
             when 'shape_' then return "id pt_lat pt_lon pt_sequence dist_traveled"
             when 'stop_time_' then return "trip_id arrival_time departure_time stop_id stop_sequence stop_headsign pickup_type drop_off_type shape_dist_traveled"
             when 'stop_' then return "id name lat lon code desc zone_id url location_type parent_station timezone wheelchair_boarding"
             when 'transfer_' then return "from_stop_id to_stop_id type min_transfer_time"
             when 'trip_' then return "route_id service_id id headsign short_name direction_id block_id shape_id wheelchair_accessible"
             
             
             else 
               return "Invalid Filter"
          end
        
      end
      
      ##### parse_model() #####################
      # 
      #
      #
      ########################################
      def parse_model(attr_hash, options={})
       
        
        
         file_text = attr_hash.to_json
         $model_data = Array.new
         unprefixed_attr_hash = {}
         $var_hash = Hash.new( self.class_variable_get('@@prefix') )
         $filter_list_arr = Array.new
         f_title_list = Array.new
         
         attr_hash.each do |key, val|
           #interrogate for what prefix is used to get list of attributes for given model
             $model_name = self.class_variable_get('@@prefix')
             filter_list = self.filter_list($model_name)
             $filter_list_arr = filter_list.split(" ")
             #then assign values to right keys, dynamic key interrogation and dynamic value assignment
             $filter_list_arr.each do |f|
               #some models have in the txt files headings "agency_id" some have no agency_ it may be trip_id with no agency_trip_id in those cases whe don't want the full model name just the header
               if($model_name.to_s === 'stop_time_' || $model_name.to_s === 'calendar_' || $model_name.to_s === 'calendar_date_'  || $model_name.to_s === 'fare_attribute_' || $model_name.to_s === 'fare_rule_'  || $model_name.to_s === 'frequency_'  || $model_name.to_s === 'transfer_' )
                 #for cases when you just need a generic "trip_id" without a model qualifier in the gtfs text file header
                   f_title = f.to_s
                   model_name_key = "#{f}"
               else
                 #for cases like "agency_id" for agency_ model where headers are like "agency_id, agency_name, etc"
                   f_title = $model_name.to_s+f.to_s
                   model_name_key = "#{$model_name}#{f}"
               end
               
               if(!f_title_list.include?(f_title))
                   f_title_list.push(f_title)
               end
               $model_name_key_arr = Array.new
               $model_name_key_arr.push(model_name_key)
                 
               if(key.to_s === model_name_key.to_s)
                     #push to an key/value pair
                     $var_hash[key.to_s] = val.to_s
                
               end
                
             end
               
         unprefixed_attr_hash[key.gsub(/^#{prefix}/, '')] = val
        end

        
        filled_keys_arr = $var_hash.keys
        #puts "hash keys "+filled_keys_arr.to_s
        #puts "f_title list "+f_title_list.to_s
        
        findings = f_title_list - filled_keys_arr 
        #puts "findings "+findings.to_s
        
        #take array from findings and add to $var_hash with value = nil
        findings.each do |x|
          $var_hash[x] = ""
        end
        #puts "final hash to redis" + $var_hash.to_s
        
        #handle writing to redis create a redis handler function different models will need different redis structs
        #redis = Redis.new()
        redis = Redis.new(:host => "localhost", :port => 6379)
        
        #TODO: need to empty the redis hash for each row if it exists before updating it.  
        
        $var_hash.each do |key, val|
          if (key === 'agency_name'  && $model_name.to_s === 'agency_' )
            
            agency_name = val
            r_hasher = redis_hasher($var_hash)
            #file_text = redis.hmset('agency:'+agency_name, 'data', $var_hash   )
            file_text = "hmset(\"agency:"+agency_name+"\", "+r_hasher+"   ) \n"
            puts "AGENCY "+redis.hgetall('agency:'+agency_name).to_s
            $agency_id = agency_name
            #cache_writer($agency_id, 'all', $model_name.to_s, file_text)
            #empty the cache file before group batch write to txt file only call once in agency condition
            file_emptier($agency_id)
            rr = rdb_writer($agency_id, 'rdb', '', file_text)
            exit
          end
          
          if (key === 'route_id'   && $model_name.to_s === 'route_')
            route_id = val
            #file_text = redis.hmset($agency_id+':route_'+route_id, 'data', $var_hash   )
            file_text = "hmset("+$agency_id+"':route_'"+route_id+", 'data', "+$var_hash.to_s+"   ) \n"
            #puts "ROUTE "+redis.hgetall($agency_id+':route_'+route_id).to_s
            #puts $var_hash
            #cache_writer($agency_id, 'all', $model_name.to_s, file_text)
            #puts $model_data
            rr = rdb_writer($agency_id, 'rdb', '', file_text)
          end
          
          
          if (key === 'stop_id'   && $model_name.to_s === 'stop_')
            stop_id = val
            #file_text = redis.hmset($agency_id+':stop_'+stop_id, 'data', $var_hash   )
            file_text = "hmset("+$agency_id+"':stop_'"+stop_id+", 'data', "+$var_hash.to_s+"   ) \n"
             #puts "STOP "+redis.hgetall($agency_id+':stop_'+stop_id).to_s
            #cache_writer($agency_id, stop_id, $model_name.to_s, file_text)
            rr = rdb_writer($agency_id, 'rdb', '', file_text)
          end
          
          if (key === 'trip_id'   && $model_name.to_s === 'trip_')
            trip_id = val
            #file_text = redis.hmset($agency_id+':trip_'+trip_id, 'data', $var_hash   )
            file_text = "hmset("+$agency_id+"':trip_'"+trip_id+", 'data', "+$var_hash.to_s+"   ) \n"
             #puts "TRIP "+redis.hgetall($agency_id+':trip_'+trip_id).to_s
            #cache_writer($agency_id, 'trip_id', $model_name.to_s, file_text)
            rr = rdb_writer($agency_id, 'rdb', '', file_text)
          end
          

          if (key === 'stop_time_trip_id' && $model_name.to_s === 'stop_time_')
            stop_time_trip_id = val
            #file_text = redis.hmset($agency_id+':stop_times_'+stop_time_trip_id, 'data', $var_hash   )
            file_text = "hmset("+$agency_id+"':stop_times_'"+stop_time_trip_id+", 'data', "+$var_hash.to_s+"   ) \n"
            #puts redis.hgetall($agency_id+':stop_times_'+stop_time_trip_id)
            #cache_writer($agency_id, stop_time_trip_id, $model_name.to_s, file_text)
            rr = rdb_writer($agency_id, 'rdb', '', file_text)
          end
          

          if (key === 'service_id' && $model_name.to_s === 'calendar_')
            service_id = val
            #file_text = redis.hmset($agency_id+':calendar_'+service_id, 'data', $var_hash   )
            file_text = "hmset("+$agency_id+"':calendar_'"+service_id+", 'data', "+$var_hash.to_s+"   ) \n"
            #puts redis.hgetall($agency_id+':calendar_'+service_id)
            rr = rdb_writer($agency_id, 'rdb', '', file_text)
            #cache_writer($agency_id, service_id, $model_name.to_s, file_text)
           
          end
          
          if (key === 'service_id' && $model_name.to_s === 'calendar_date_')
            service_id = val
            #file_text = redis.hmset($agency_id+':calendar_date_'+service_id, 'data', $var_hash   )
            file_text = "hmset("+$agency_id+"':calendar_date_'"+service_id+", 'data', "+$var_hash.to_s+"   ) \n"
            #puts redis.hgetall($agency_id+':calendar_date_'+service_id)
            rr = rdb_writer($agency_id, 'rdb', '', file_text)
            #cache_writer($agency_id, 'all', $model_name.to_s, file_text)
          end
          
          if (key === 'fare_id' && $model_name.to_s === 'fare_attribute_')
            fare_id = val
            #file_text = redis.hmset($agency_id+':fare_attribute_'+fare_id, 'data', $var_hash   )
            file_text = "hmset("+$agency_id+"':fare_attribute_'"+fare_id+", 'data', "+$var_hash.to_s+"   ) \n"
            #puts redis.hgetall($agency_id+':fare_attribute_'+fare_id)
            rr = rdb_writer($agency_id, 'rdb', '', file_text)
            #cache_writer($agency_id, fare_id, $model_name.to_s, file_text)
          end
          
          if (key === 'fare_id' && $model_name.to_s === 'fare_rule_')
            fare_id = val
            #file_text = redis.hmset($agency_id+':fare_rule_'+fare_id, 'data', $var_hash   )
            file_text = "hmset("+$agency_id+"':fare_rule_'"+fare_id+", 'data', "+$var_hash.to_s+"   ) \n"
            #puts redis.hgetall($agency_id+':fare_rule_'+fare_id)
            rr = rdb_writer($agency_id, 'rdb', '', file_text)
            #cache_writer($agency_id, fare_id, $model_name.to_s, file_text)
          end
          
          if (key === 'trip_id' && $model_name.to_s === 'frequency_')
            trip_id = val
            #file_text = redis.hmset($agency_id+':frequency_'+trip_id, 'data', $var_hash   )
            file_text = "hmset("+$agency_id+"':frequency_'"+trip_id+", 'data', "+$var_hash.to_s+"   ) \n"
            #puts redis.hgetall($agency_id+':frequency_'+trip_id)
            #cache_writer($agency_id, trip_id, $model_name.to_s, file_text)
            rr = rdb_writer($agency_id, 'rdb', '', file_text)
          end
          
          if (key === 'from_stop_id' && $model_name.to_s === 'transfer_')
            from_stop_id = val
            #file_text = redis.hmset($agency_id+':transfer_'+from_stop_id, 'data', $var_hash   )
            file_text = "hmset("+$agency_id+"':transfer_'"+from_stop_id+", 'data', "+$var_hash.to_s+"   ) \n"
            #puts redis.hgetall($agency_id+':transfer_'+from_stop_id)
            #cache_writer($agency_id, from_stop_id, $model_name.to_s, file_text)
            rr = rdb_writer($agency_id, 'rdb', '', file_text)
          end
          
          if (key === 'shape_id'  && $model_name.to_s === 'shape_')
            $shape_id = val
          end
          
          if (key === 'shape_pt_sequence'  && $model_name.to_s === 'shape_')
            shape_pt_sequence = val
            #file_text = redis.hmset($agency_id+':shapes_'+$shape_id.to_s+'_'+shape_pt_sequence.to_s, 'data', $var_hash   )
            file_text = "hmset("+$agency_id+"':shapes_'"+$shape_id.to_s+"'_'"+shape_pt_sequence.to_s+", 'data', "+$var_hash.to_s+")"
            #puts redis.hgetall($agency_id+':shapes_'+shape_pt_sequence)
            #cache_writer($agency_id, shape_id+"_"+shape_pt_sequence, $model_name.to_s, file_text)
            rr = rdb_writer($agency_id, 'rdb', '', file_text)
          end
           
       end
      
        model = self.new(unprefixed_attr_hash)
        
      end #end filter method
      
      
      
      ##### merge_data() #####################
      # merges data to send to cache_writer which writes a js file of data for node.js to handle
      # context can be either 'all' or 'atomic' ergo 'all' for all routes, or 'atomic' for an individual route 
      #
      ########################################
      def merge_data(data, context, model_name)
        
        context = 'all'
        
            all_collection = Array.new
        
        
            file_text_arr = Array.new
            file_text_arr = data
        
            file_text_arr_length = file_text_arr.length
            f_counter = 0
        
            merged_data = "var "+$model_name.to_s+ " = ["
            
            file_text_arr.each do |key, val|
                 merged_text = ""
                 if f_counter == 0
                    merged_text += "{"
                 end
                 
                 merged_text += "\""+key.to_s+"\":\""+val.to_s+"\""
                 if f_counter == file_text_arr_length-1
                   merged_text += ""
                 else
                   merged_text += ","
                 end
         
                 if f_counter == file_text_arr_length-1
                   merged_text +=  "},"
                 end
                 f_counter = f_counter+1
                 #puts merged_text
                 merged_data += merged_text
                 
                 
                 if(context == 'all')
                   all_collection.push(merged_text)
                 end
                 
             end
             merged_data += "]"
            
             if(context == 'all')
               merged_data = "var "+$model_name.to_s+ " = ["
               merged_data += all_collection.to_s
               merged_data += "]"
             end
             
             #puts merged_data
             
             return merged_data
         
       
         
         #push merged_data to a super array when needing multiple rows returned, need a mode: one_off, multiple rows
       
        
      end #ends merge_data()

      ##### redis_hasher() #####################
      # 
      #
      #
      ########################################
      def redis_hasher(rhash)        
        puts rhash.length
        counter = 1;
        r_str = ""
        rhash.each do |key,val|
          if counter == rhash.length 
            my_redis_setter = " \""+key+"\", \""+val+"\" "
          else 
            my_redis_setter = " \""+key+"\", \""+val+"\", "
          end
          counter = counter + 1
          r_str += my_redis_setter
            
        end
        return  r_str
      end

      ##### file_emptier() #####################
      # 
      #
      #
      ########################################
      def file_emptier(agency_id)        
        agency_id.gsub! ' ', '_'
        
        if (File.exist?("../../../cache/"+agency_id+".txt"))
             empty = File.open("../../../cache/"+agency_id+".txt", "w") {|file| file.truncate(0) }
        end
        
        
        
      end
      ##### rdb_writer() #####################
      # 
      #
      #
      ########################################
      def rdb_writer(agency_id, id, model, file_text)
        #id here should be some unique id per item row in a given model struct
        
        agency_id.gsub! ' ', '_'
        id.gsub! ' ', '_'
           
        begin
          file = File.open("../../../cache/"+agency_id+".txt", "a+")
          file.write(file_text) 
        rescue IOError => e
          #some error occur, dir not writable etc.
        ensure
          file.close unless file == nil
        end
        
        
      end

      ##### cache_writer() #####################
      # 
      #
      #
      ########################################
      def cache_writer(agency_id, id, model, file_text)
        #id here should be some unique id per item row in a given model struct
        
        agency_id.gsub! ' ', '_'
        id.gsub! ' ', '_'
        
        if (File.exist?("../../../cache/"+agency_id+"_"+model+""+id+".js"))
             empty = File.open("../../../cache/"+agency_id+"_"+model+""+id+".js", "w") {|file| file.truncate(0) }
        end
           
        begin
          file = File.open("../../../cache/"+agency_id+"_"+model+""+id+".js", "a+")
          file.write(file_text) 
        rescue IOError => e
          #some error occur, dir not writable etc.
        ensure
          file.close unless file == nil
        end
        
        
      end


      ##### parse_models() #####################
      # 
      #
      #
      ########################################
      def parse_models(data, options={})
        return [] if data.nil? || data.empty?

        models = []
        CSV.parse(data, :headers => true) do |row|
          model = parse_model(row.to_hash, options)
          models << model if options[:strict] == false || model.valid?
        end
        models
      end
    end
  end
end
