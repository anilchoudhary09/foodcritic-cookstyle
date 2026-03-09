# frozen_string_literal: true

module RuboCop
  module Cop
    module Barclays
      # BARC003: Prohibits root .ssh directory manipulation
      #
      # @example
      #   # bad
      #   directory '/root/.ssh' do
      #     mode '0700'
      #   end
      #
      class Barc003NoRootSsh < Base
        MSG = 'BARC003: Manipulation of root .ssh directory is prohibited. ' \
              'SSH access must be managed through centralized security controls.'

        ROOT_SSH_PATTERNS = [%r{/root/\.ssh}i, %r{~root/\.ssh}i].freeze

        def on_block(node)
          return if cookbook_whitelisted?('platform_cookbooks')

          if (path = file_resource?(node)) || (path = directory_resource?(node))
            check_root_ssh_path(node, path)
          end

          check_commands(node) if execute_resource?(node) || bash_resource?(node)
        end

        private

        def check_root_ssh_path(node, path)
          ROOT_SSH_PATTERNS.each do |pattern|
            if path =~ pattern
              add_offense(node.send_node)
              break
            end
          end
        end

        def check_commands(node)
          find_command_strings(node).each do |cmd_node, cmd|
            ROOT_SSH_PATTERNS.each do |pattern|
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
