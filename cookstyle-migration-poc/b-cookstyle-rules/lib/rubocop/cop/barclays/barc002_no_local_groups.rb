# frozen_string_literal: true

module RuboCop
  module Cop
    module Barclays
      # BARC002: Prohibits local group manipulation
      #
      # Local group management must be handled through centralized identity
      # management systems and not through Chef cookbooks directly.
      #
      # @example
      #   # bad - creates local group
      #   group 'myapp_group' do
      #     action :create
      #   end
      #
      #   # bad - shell command group manipulation
      #   execute 'add_group' do
      #     command 'groupadd mygroup'
      #   end
      #
      class Barc002NoLocalGroups < Base
        MSG = 'BARC002: Local group manipulation is not allowed. ' \
              'Use centralized identity management (LDAP/AD) instead.'

        FORBIDDEN_COMMANDS = %w[
          groupadd groupmod groupdel addgroup delgroup
          gpasswd
        ].freeze

        FORBIDDEN_COMMAND_PATTERNS = FORBIDDEN_COMMANDS.map { |cmd| /\b#{cmd}\b/ }

        def on_block(node)
          # Check for group resource
          return unless group_resource?(node)
          return if cookbook_whitelisted?('platform_cookbooks')

          add_offense(node.send_node)
        end

        def on_send(node)
          return unless execute_or_script_context?(node)
          return if cookbook_whitelisted?('platform_cookbooks')

          cmd = command_property(node) || code_property(node)
          return unless cmd

          check_forbidden_commands(node, cmd)
        end

        private

        def execute_or_script_context?(node)
          node.each_ancestor(:block).any? do |ancestor|
            execute_resource?(ancestor) || bash_resource?(ancestor)
          end
        end

        def check_forbidden_commands(node, command)
          FORBIDDEN_COMMAND_PATTERNS.each do |pattern|
            if command =~ pattern
              add_offense(node, message: MSG)
              break
            end
          end
        end
      end
    end
  end
end
