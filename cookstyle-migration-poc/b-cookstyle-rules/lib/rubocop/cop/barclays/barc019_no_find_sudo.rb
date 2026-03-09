# frozen_string_literal: true

module RuboCop
  module Cop
    module Barclays
      # BARC019: Prohibits dangerous commands like find with sudo
      #
      # Commands like `find` with `sudo` or `find` with `-exec` can be
      # exploited for privilege escalation. These patterns should be avoided.
      #
      # @example
      #   # bad - find with sudo
      #   execute 'find_files' do
      #     command 'sudo find /tmp -name "*.log" -exec rm {} \;'
      #   end
      #
      #   # bad - find with exec as root
      #   execute 'find_and_exec' do
      #     command 'find /var -user root -exec chmod 777 {} \;'
      #     user 'root'
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
          /\|\s*sudo\s+xargs/ => 'pipe to sudo xargs',
          /chmod\s+-R\s+777/ => 'chmod -R 777',
          /chmod\s+777/ => 'chmod 777 (world-writable)',
          /eval\s+.*\$\(/ => 'eval with command substitution',
          /`[^`]*\$[^`]*`/ => 'command substitution with variables',
        }.freeze

        def on_block(node)
          return if cookbook_whitelisted?('platform_cookbooks')

          if execute_resource?(node) || bash_resource?(node)
            check_dangerous_patterns(node)
          end
        end

        private

        def check_dangerous_patterns(node)
          find_command_strings(node).each do |cmd_node, cmd|
            DANGEROUS_PATTERNS.each do |pattern, description|
              if cmd =~ pattern
                add_offense(
                  cmd_node,
                  message: format(MSG, pattern: description)
                )
              end
            end
          end
        end
      end
    end
  end
end
