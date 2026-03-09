# frozen_string_literal: true

module RuboCop
  module Cop
    module Barclays
      # BARC002: Prohibits local group manipulation
      #
      # @example
      #   # bad
      #   group 'myapp_group' do
      #     action :create
      #   end
      #
      class Barc002NoLocalGroups < Base
        MSG = 'BARC002: Local group manipulation is not allowed. ' \
              'Use centralized identity management (LDAP/AD) instead.'

        FORBIDDEN_COMMANDS = %w[groupadd groupmod groupdel addgroup delgroup gpasswd].freeze
        FORBIDDEN_PATTERNS = FORBIDDEN_COMMANDS.map { |cmd| /\b#{cmd}\b/ }

        def on_block(node)
          return if cookbook_whitelisted?('platform_cookbooks')
          return unless group_resource?(node)
          add_offense(node.send_node)
        end

        def on_send(node)
          return if cookbook_whitelisted?('platform_cookbooks')
          check_command_in_context(node)
        end

        private

        def check_command_in_context(node)
          return unless node.each_ancestor(:block).any? { |a| execute_resource?(a) || bash_resource?(a) }

          cmd = command_property(node) || code_property(node)
          return unless cmd

          FORBIDDEN_PATTERNS.each do |pattern|
            if cmd =~ pattern
              add_offense(node)
              break
            end
          end
        end
      end
    end
  end
end
