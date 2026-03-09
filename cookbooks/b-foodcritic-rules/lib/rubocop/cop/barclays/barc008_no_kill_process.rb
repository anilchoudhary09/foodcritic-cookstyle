# frozen_string_literal: true

module RuboCop
  module Cop
    module Barclays
      # BARC008: Prohibits kill and process priority manipulation
      #
      # @example
      #   # bad
      #   execute 'kill_process' do
      #     command 'kill -9 1234'
      #   end
      #
      class Barc008NoKillProcess < Base
        MSG = 'BARC008: Process killing/priority manipulation is not allowed. ' \
              'Use proper service management instead.'

        FORBIDDEN_COMMANDS = %w[kill killall pkill renice nice ionice].freeze
        FORBIDDEN_PATTERNS = FORBIDDEN_COMMANDS.map { |cmd| /\b#{cmd}\b/ }

        def on_block(node)
          return if cookbook_whitelisted?('platform_cookbooks')
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
