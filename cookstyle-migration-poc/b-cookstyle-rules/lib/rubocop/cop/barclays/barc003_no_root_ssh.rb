# frozen_string_literal: true

module RuboCop
  module Cop
    module Barclays
      # BARC003: Prohibits root .ssh directory manipulation
      #
      # SSH configuration for the root user must be managed through
      # centralized security controls, not Chef cookbooks.
      #
      # @example
      #   # bad - creates root .ssh directory
      #   directory '/root/.ssh' do
      #     mode '0700'
      #   end
      #
      #   # bad - manages root authorized_keys
      #   file '/root/.ssh/authorized_keys' do
      #     content 'ssh-rsa ...'
      #   end
      #
      class Barc003NoRootSsh < Base
        MSG = 'BARC003: Manipulation of root .ssh directory is prohibited. ' \
              'SSH access must be managed through centralized security controls.'

        ROOT_SSH_PATTERNS = [
          %r{/root/\.ssh}i,
          %r{~root/\.ssh}i,
          %r{\$HOME/\.ssh.*root}i,
        ].freeze

        def on_block(node)
          return if cookbook_whitelisted?('platform_cookbooks')

          # Check file and directory resources
          if (path = file_resource?(node)) || (path = directory_resource?(node))
            check_root_ssh_path(node, path)
          end

          # Check execute/bash resources
          if execute_resource?(node) || bash_resource?(node)
            check_commands_for_root_ssh(node)
          end
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

        def check_commands_for_root_ssh(node)
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
