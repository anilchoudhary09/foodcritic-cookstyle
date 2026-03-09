# frozen_string_literal: true

module RuboCop
  module Cop
    module Barclays
      # BARC006: Prohibits reboot/shutdown commands
      #
      # System reboots and shutdowns must be carefully controlled and
      # should not be initiated by application cookbooks.
      #
      # @example
      #   # bad - executes reboot
      #   execute 'reboot_system' do
      #     command 'reboot'
      #   end
      #
      #   # bad - uses Chef reboot resource
      #   reboot 'reboot_now' do
      #     action :reboot_now
      #   end
      #
      class Barc006NoReboot < Base
        MSG = 'BARC006: Reboot/shutdown commands are not allowed in cookbooks. ' \
              'System reboots must be managed through proper change control.'

        FORBIDDEN_COMMANDS = %w[
          reboot shutdown halt poweroff init telinit
        ].freeze

        FORBIDDEN_COMMAND_PATTERNS = FORBIDDEN_COMMANDS.map { |cmd| /\b#{cmd}\b/ }

        def_node_matcher :reboot_resource?, <<~PATTERN
          (block
            (send nil? :reboot ...)
            ...
          )
        PATTERN

        def on_block(node)
          return if cookbook_whitelisted?('platform_cookbooks')

          # Check for reboot resource
          if reboot_resource?(node)
            add_offense(node.send_node)
            return
          end

          # Check execute/bash resources for reboot commands
          if execute_resource?(node) || bash_resource?(node)
            check_commands_for_reboot(node)
          end
        end

        private

        def check_commands_for_reboot(node)
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
