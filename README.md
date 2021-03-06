[![Puppet Forge](http://img.shields.io/puppetforge/v/lynxman/hiera_consul.svg)](https://forge.puppetlabs.com/lynxman/hiera_consul)

[consul](http://www.consul.io) is an orchestration mechanism with fault-tolerance based on the gossip protocol and a key/value store that is strongly consistent. Hiera-consul will allow hiera to write to the k/v store for metadata centralisation and harmonisation.

## Installation

For usage with puppet, install the module in your local environment, e.g.:

    puppet module install lynxman/hiera_consul
    
or using a Puppetfile:

    mod 'lynxman/hiera_consul'

Ensure the backend `consul_backend.rb` is available into your hiera environment. Depending on your hiera/puppet environment, you may need to install the backend manually (or with puppet) at the correct path, which may be puppets local ruby path, e.g. `$PUPPET_DIR/lib/ruby/vendor_ruby/hiera/backend/consul_backend.rb`

Puppet loads backends differently in some version, see [#SERVER-571](https://tickets.puppetlabs.com/si/jira.issueviews:issue-html/SERVER-571/SERVER-571.html) for more information.

## Configuration

The following hiera.yaml should get you started:

    :backends:
      - consul

    :consul:
      :host: 127.0.0.1
      :port: 8500
      :paths:
        - /v1/kv/configuration/%{fqdn}
        - /v1/kv/configuration/common

The array `:paths:` allows hiera to access the namespaces in it. As an example, you can query `/v1/kv/configuration/common/yourkey` using 

    hiera('yourkey', [])
    
This will return a consul array, which can further processed. See the helper function `consul_info` below for more information.

## Extra parameters

As this module uses http to talk with Consul API the following parameters are also valid and available

    :consul:
      :host: 127.0.0.1
      :port: 8500
      :use_ssl: false
      :ssl_verify: false
      :ssl_cert: /path/to/cert
      :ssl_key: /path/to/key
      :ssl_ca_cert: /path/to/ca/cert
      :failure: graceful
      :ignore_404: true
      :token: acl-uuid-token

## Query the catalog

You can also query the Consul catalog for values by adding catalog resources in your paths, the values will be returned as an array so you will need to parse accordingly.

    :backends:
      - consul

    :consul:
      :host: 127.0.0.1
      :port: 8500
      :paths:
        - /v1/kv/configuration/%{fqdn}
        - /v1/kv/configuration/common
        - /v1/catalog/service
        - /v1/catalog/node

## Helper function

### consul_info

This function will allow you to read information out of a consul Array returned by hiera, as an example here we recover node IPs based on a service:

    $consul_service_array = hiera('rabbitmq',[])
    $mq_cluster_nodes = consul_info($consul_service_array, 'Address')

In this example `$mq_cluster_nodes` will have an array with all the IP addresses related to that service

You can also call it more with than one field and a separator and it will generate a composed string for each element in the consul query result.

    $consul_service_array = hiera('rabbitmq',[])
    $mq_cluster_nodes = consul_info($consul_service_array, [ 'Address', 'Port' ], ':')

The result will return an array like this: [ AddressA:PortA, AddressB:PortB ]

If you want to flatten the output array you can always use [join](https://forge.puppetlabs.com/puppetlabs/stdlib) from the Puppet stdlib.

    $myresult = join($mq_cluster_nodes, ",")

## Thanks

Heavily based on [etcd-hiera](https://github.com/garethr/hiera-etcd) written by @garethr which was inspired by [hiera-http](https://github.com/crayfishx/hiera-http) from @crayfishx.

Thanks to @mitchellh for writing such wonderful tools and the [API Documentation](http://www.consul.io/docs/agent/http.html)

Thanks for their contributions to [Wei Tie](https://github.com/TieWei), [Derek Tracy](https://github.com/tracyde), [Michael Chapman](https://github.com/michaeltchapman), [Kyle O'Donnell](https://github.com/kyleodonnell), [AJ](https://github.com/aj-jester) and [lcrisci](https://github.com/lcrisci)
