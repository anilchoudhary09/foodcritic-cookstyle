# frozen_string_literal: true

module RuboCop
  module Cop
    module Barclays
      # BARC006: Prohibits reboot/shutdown commands
      #
      # @example
      #   # bad
      #   reboot 'restart' do
      #     action :reboot_now
      #   end
      #
      #   # bad
      #   execute 'reboot_server' do
      #     command 'reboot'
      #   end
      #
      #   # bad
      #   execute 'shutdown' do
      #     command 'shutdown -h now'
      #   end
      #
      class Barc006NoReboot < Base
        MSG = 'BARC006: Reboot/shutdown commands are not allowed in cookbooks. ' \
              'System reboots must be managed through proper change control.'

        # More specific patterns to avoid false positives like "init-db.sh"
        # Match standalone commands or commands with arguments
        FORBIDDEN_PATTERNS = [
          /(?:^|\s|\/|;|&&|\|\|)reboot(?:\s|$|;|&&|\|\|)/,           # reboot command
          /(?:^|\s|\/|;|&&|\|\|)shutdown(?:\s|$|;|&&|\|\|)/,         # shutdown command
          /(?:^|\s|\/|;|&&|\|\|)halt(?:\s|$|;|&&|\|\|)/,             # halt command
          /(?:^|\s|\/|;|&&|\|\|)poweroff(?:\s|$|;|&&|\|\|)/,         # poweroff command
          /(?:^|\s|\/|;|&&|\|\|)init\s+[0-6](?:\s|$|;|&&|\|\|)/,     # init 0-6 (runlevel changes)
          /(?:^|\s|\/|;|&&|\|\|)telinit\s+[0-6](?:\s|$|;|&&|\|\|)/,  # telinit 0-6 (runlevel changes)
          /\/sbin\/reboot/,                                # Full path reboot
          /\/sbin\/shutdown/,                              # Full path shutdown
          /\/sbin\/halt/,                                  # Full path halt
          /\/sbin\/poweroff/,                              # Full path poweroff
        ].freeze

        def_node_matcher :reboot_resource?, <<~PATTERN
          (block (send nil? :reboot ...) ...)
        PATTERN

        def on_block(node)
          return if cookbook_whitelisted?('platform_cookbooks')

          if reboot_resource?(node)
            add_offense(node.send_node)
            return
          end

          check_commands(node) if execute_resource?(node) || bash_resource?(node)
        end

        private

        def check_commands(node)
          find_command_strings(node).each do |cmd_node, cmd|
            FORBIDDEN_PATTERNS.each do |pattern|
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
