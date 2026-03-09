# frozen_string_literal: true

module RuboCop
  module Cop
    module Barclays
      # BARC008: Prohibits kill and process priority manipulation
      #
      # Killing processes or changing process priorities can destabilize
      # systems and should not be done by application cookbooks.
      #
      # @example
      #   # bad - kills process
      #   execute 'kill_process' do
      #     command 'kill -9 1234'
      #   end
      #
      #   # bad - changes process priority
      #   execute 'change_nice' do
      #     command 'renice -n -5 1234'
      #   end
      #
      class Barc008NoKillProcess < Base
        MSG = 'BARC008: Process killing/priority manipulation is not allowed. ' \
              'Use proper service management instead.'

        FORBIDDEN_COMMANDS = %w[
          kill killall pkill renice nice ionice
        ].freeze

        FORBIDDEN_COMMAND_PATTERNS = FORBIDDEN_COMMANDS.map { |cmd| /\b#{cmd}\b/ }

        def on_block(node)
          return if cookbook_whitelisted?('platform_cookbooks')

          # Check execute/bash resources
          if execute_resource?(node) || bash_resource?(node)
            check_commands_for_kill(node)
          end
        end

        private

        def check_commands_for_kill(node)
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
