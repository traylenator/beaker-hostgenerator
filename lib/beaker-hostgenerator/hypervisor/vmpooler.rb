require 'beaker-hostgenerator/data'
require 'beaker-hostgenerator/hypervisor'
require 'deep_merge/rails_compat'

module BeakerHostGenerator
  module Hypervisor
    class Vmpooler < BeakerHostGenerator::Hypervisor::Interface
      include BeakerHostGenerator::Data

      # default global configuration keys
      def global_config
        {
          'pooling_api' => 'http://vmpooler.delivery.puppetlabs.net/'
        }
      end

      def generate_node(node_info, base_config, bhg_version)
        base_config = base_generate_node(node_info, base_config, bhg_version, :vmpooler)

        case node_info['ostype']
        when /^centos/
          base_config['template'] = base_config['platform'].gsub(/^el/, 'centos')
        when /^fedora/
          base_config['template'] = base_config['platform']
        when /^ubuntu/
          arch = case node_info['bits']
                 when '64'
                   'x86_64'
                 when '32'
                   'i386'
                 when 'AARCH64'
                   'arm64'
                 when 'POWER'
                   base_template = node_info['ostype'].sub(/ubuntu(\d\d)/, 'ubuntu-\1.')
                   'power8'
                 else
                   raise "Unknown bits '#{node_info['bits']}' for '#{node_info['ostype']}'"
                 end
          base_config['template'] = "#{node_info['ostype'].sub('ubuntu', 'ubuntu-')}-#{arch}"
        end

        # Some vmpooler/vsphere platforms have special requirements.
        # We munge the node host config here if that is necessary.
        fixup_node base_config

        return base_config
      end
    end
  end
end
