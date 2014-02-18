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
          yield parse_model(row.to_hash)
        end
      end
      
      
      def filter_list(model_name)
        #get list of attributes per model
        #agencies
          #   :name, :url, :timezone, :id, :lang, :phone, :fare_url
        
        #stops
          # :id, :name, :lat, :lon, :code, :desc, :zone_id, :url, :location_type, :parent_station, :timezone, :wheelchair_boarding
    
          modeler = model_name.to_s
          result = case modeler
             when 'agency_' then return "name url timezone id lang phone fare_url"
             when 'stops_' then return "id name lat lon code desc zone_id url location_type parent_station timezone wheelchair_boarding"
             
             else 
               return "Invalid Filter"
          end
        
      end
      

      def parse_model(attr_hash, options={})
         unprefixed_attr_hash = {}
         attr_hash.each do |key, val|
           #puts key
         
             #interrogate for what prefix is used to get list of attributes for given model
             model_name = self.class_variable_get('@@prefix')
             #puts model_name
             filter_list = self.filter_list(model_name)
             filter_list_arr = filter_list.split(" ")
         
             #then assign values to right keys, dynamic key interrogation and dynamic value assignment
             var_hash = Hash.new(  )
             
             filter_list_arr.each do |f|
                 #puts f
                 var_arr =  Array.new #change this to a hash array or map
                 
                 model_name_key = "#{model_name}#{f}"
                 
                 
                 if(key.to_s === model_name_key.to_s)
                   #puts model_name_key.to_s + " | " + key.to_s
                     #push to an key/value pair
                     model_name_key_val = val.to_s
                     var_arr.push(model_name_key_val)
                     var_hash[key.to_s] = val.to_s
                 end
                 #puts var_arr
                 
         
             end
             puts var_hash
             
         #handle writing to redis 
         #redis = Redis.new()
         #redis.hmset('agency_id:'+agency_id, 'agency_name', agency_name   )
         

          
          unprefixed_attr_hash[key.gsub(/^#{prefix}/, '')] = val
        end

        model = self.new(unprefixed_attr_hash)
      end #end filter method
      

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
