# frozen_string_literal: true

module RuboCop
  module Cop
    module Barclays
      # BARC019: Prohibits dangerous commands like find with sudo
      #
      # @example
      #   # bad
      #   execute 'find_files' do
      #     command 'sudo find /tmp -exec rm {} \;'
      #   end
      #
      #   # bad
      #   execute 'bad_perms' do
      #     command 'chmod 777 /opt/app'
      #   end
      #
      class Barc019NoFindSudo < Base
        MSG = 'BARC019: Dangerous command pattern detected (%<pattern>s). ' \
              'This pattern can lead to security vulnerabilities.'

        DANGEROUS_PATTERNS = {
          /sudo\s+find\b/ => 'sudo find',
          /find\b.*-exec\s+.*sudo/ => 'find -exec with sudo',
          /find\b.*-exec\s+.*rm\s+-rf/ => 'find -exec rm -rf',
          /xargs\s+.*sudo/ => 'xargs with sudo',
          /chmod\s+-R\s+777/ => 'chmod -R 777',
          /chmod\s+777/ => 'chmod 777 (world-writable)',
          /eval\s+.*\$\(/ => 'eval with command substitution',
        }.freeze

        def on_block(node)
          return if cookbook_whitelisted?('platform_cookbooks')

          check_commands(node) if execute_resource?(node) || bash_resource?(node)
        end

        private

        def check_commands(node)
          find_command_strings(node).each do |cmd_node, cmd|
            DANGEROUS_PATTERNS.each do |pattern, description|
              if cmd =~ pattern
                add_offense(cmd_node, message: format(MSG, pattern: description))
              end
            end
          end
        end
      end
    end
  end
end
