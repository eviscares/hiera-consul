require 'net/http'
require 'json'
    module Consul
        def self.get_nodes(key, options)
            service_path = "/service/" + key
            service_endpoint = "/v1/catalog" + service_path

            uri = URI.parse(options['server'] + service_endpoint)
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            request = Net::HTTP::Get.new(uri.request_uri)
            response = JSON.parse(http.request(request).body)

            response
        end

        def self.get_health(key, node, options)
            
            health_endpoint = "/v1/health/node/" + node

            uri = URI.parse(options['server'] + health_endpoint)
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            request = Net::HTTP::Get.new(uri.request_uri)
            response = JSON.parse(http.request(request).body)
            response.each do |service|
                if service["ServiceName"] == key
                    return service["Status"]                
                end
            end
        end

        def self.query(key, options)
            nodes = Array.new
            response = get_nodes(key, options)

            response.each do |node|
                health = get_health(key, node["Node"], options)
                nodes.push({"Node"=>node["Node"], "Address"=>node["Address"], "Health"=>health})
            end
            nodes
        end
    end
