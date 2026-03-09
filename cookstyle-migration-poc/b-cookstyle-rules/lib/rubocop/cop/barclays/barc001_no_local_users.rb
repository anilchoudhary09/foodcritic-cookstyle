# frozen_string_literal: true

module RuboCop
  module Cop
    module Barclays
      # BARC001: Prohibits local user manipulation
      #
      # Local user management must be handled through centralized identity
      # management systems (LDAP, Active Directory, etc.) and not through
      # Chef cookbooks directly.
      #
      # @safety
      #   This cop is unsafe because it may flag legitimate user management
      #   in platform/infrastructure cookbooks that have whitelist exceptions.
      #
      # @example
      #   # bad - creates local user
      #   user 'myapp_user' do
      #     action :create
      #   end
      #
      #   # bad - shell command user manipulation
      #   execute 'add_user' do
      #     command 'useradd -m myuser'
      #   end
      #
      #   # bad - modifies existing user
      #   user 'root' do
      #     shell '/bin/bash'
      #   end
      #
      class Barc001NoLocalUsers < Base
        MSG = 'BARC001: Local user manipulation is not allowed. ' \
              'Use centralized identity management (LDAP/AD) instead.'

        FORBIDDEN_COMMANDS = %w[
          useradd usermod userdel adduser deluser
          chsh chfn passwd
        ].freeze

        FORBIDDEN_COMMAND_PATTERNS = FORBIDDEN_COMMANDS.map { |cmd| /\b#{cmd}\b/ }

        def on_block(node)
          # Check for user resource
          return unless user_resource?(node)
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
