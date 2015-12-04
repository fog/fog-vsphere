module Fog
  module Compute
    class Vsphere
      class Real
        def list_rules(filters = {})
          cluster = get_raw_cluster(filters[:cluster], filters[:datacenter])
          cluster.configurationEx.rule.map {|r| rule_attributes r, filters}
        end

        protected
      
        def rule_attributes(rule, filters)
          {
            datacenter: filters[:datacenter],
            cluster:    filters[:cluster],
            key:        rule[:key],
            name:       rule[:name],
            enabled:    rule[:enabled],
            type:       rule.class,
            vm_ids:     rule[:vm].map {|vm| vm.config.instanceUuid }
          }
        end
      end
      class Mock
        def list_rules(filters = {})
          self.data[:rules].values.select {|r| r[:datacenter] == filters[:datacenter] && r[:cluster] == filters[:cluster]}
        end
      end
    end
  end
end
