# frozen_string_literal: true

module RuboCop
  module Cop
    module Barclays
      # BARC009: Prohibits firewall manipulation
      #
      # Firewall configuration is managed by the security/network team
      # and should not be modified by application cookbooks.
      #
      # @example
      #   # bad - modifies iptables
      #   execute 'add_firewall_rule' do
      #     command 'iptables -A INPUT -p tcp --dport 8080 -j ACCEPT'
      #   end
      #
      #   # bad - uses firewall resource
      #   firewall_rule 'open_port' do
      #     port 8080
      #   end
      #
      class Barc009NoFirewall < Base
        MSG = 'BARC009: Firewall manipulation is not allowed. ' \
              'Firewall configuration is managed by the security/network team.'

        FORBIDDEN_COMMANDS = %w[
          iptables ip6tables firewall-cmd ufw
          nft iptables-save iptables-restore
        ].freeze

        FORBIDDEN_COMMAND_PATTERNS = FORBIDDEN_COMMANDS.map { |cmd| /\b#{cmd}\b/ }

        FIREWALL_PATHS = %w[
          /etc/firewalld/
          /etc/iptables/
          /etc/sysconfig/iptables
          /etc/ufw/
        ].freeze

        def_node_matcher :firewall_resource?, <<~PATTERN
          (block
            (send nil? {:firewall :firewall_rule :iptables_rule :ufw_rule} ...)
            ...
          )
        PATTERN

        def on_block(node)
          return if cookbook_whitelisted?('platform_cookbooks')

          # Check for firewall Chef resources
          if firewall_resource?(node)
            add_offense(node.send_node)
            return
          end

          # Check file resources for firewall paths
          if (path = file_resource?(node))
            check_firewall_path(node, path)
          end

          # Check execute/bash resources
          if execute_resource?(node) || bash_resource?(node)
            check_commands_for_firewall(node)
          end
        end

        private

        def check_firewall_path(node, path)
          FIREWALL_PATHS.each do |firewall_path|
            if path.start_with?(firewall_path)
              add_offense(node.send_node)
              break
            end
          end
        end

        def check_commands_for_firewall(node)
          find_command_strings(node).each do |cmd_node, cmd|
            FORBIDDEN_COMMAND_PATTERNS.each do |pattern|
              if cmd =~ pattern
                add_offense(cmd_node)
                break
              end
            end
          end
        end
      end
    end
  end
end
