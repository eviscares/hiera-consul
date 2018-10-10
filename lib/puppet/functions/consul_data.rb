# Hiera5 backend for Consul
require_relative 'consul'

Puppet::Functions.create_function(:consul_data) do

    dispatch :execute do 
      param 'String', :key
      param 'Hash', :options
      param 'Puppet::LookupContext', :context
    end


    def execute(key, options, context)
      key_dup = key.dup
      search_key = key_dup.split("::").last
      results =  Consul.query(search_key, options)
      if results.empty?
        context.not_found
      else  
        return results
      end
    end
end