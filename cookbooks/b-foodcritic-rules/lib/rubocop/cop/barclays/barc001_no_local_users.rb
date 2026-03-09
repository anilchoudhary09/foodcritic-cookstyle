# frozen_string_literal: true

module RuboCop
  module Cop
    module Barclays
      # BARC001: Prohibits local user manipulation
      #
      # @example
      #   # bad
      #   user 'myapp_user' do
      #     action :create
      #   end
      #
      #   # bad
      #   execute 'add_user' do
      #     command 'useradd -m myuser'
      #   end
      #
      class Barc001NoLocalUsers < Base
        MSG = 'BARC001: Local user manipulation is not allowed. ' \
              'Use centralized identity management (LDAP/AD) instead.'

        FORBIDDEN_COMMANDS = %w[useradd usermod userdel adduser deluser chsh chfn passwd].freeze
        FORBIDDEN_PATTERNS = FORBIDDEN_COMMANDS.map { |cmd| /\b#{cmd}\b/ }

        def on_block(node)
          return if cookbook_whitelisted?('platform_cookbooks')
          return unless user_resource?(node)
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
