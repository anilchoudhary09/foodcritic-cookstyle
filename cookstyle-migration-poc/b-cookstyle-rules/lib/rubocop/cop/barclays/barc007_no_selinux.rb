# frozen_string_literal: true

module RuboCop
  module Cop
    module Barclays
      # BARC007: Prohibits SELinux manipulation
      #
      # SELinux configuration is managed by security team and should
      # not be modified by application cookbooks.
      #
      # @example
      #   # bad - disables SELinux
      #   execute 'disable_selinux' do
      #     command 'setenforce 0'
      #   end
      #
      #   # bad - modifies SELinux config
      #   file '/etc/selinux/config' do
      #     content 'SELINUX=disabled'
      #   end
      #
      class Barc007NoSelinux < Base
        MSG = 'BARC007: SELinux manipulation is not allowed. ' \
              'SELinux configuration is managed by the security team.'

        FORBIDDEN_COMMANDS = %w[
          setenforce getenforce sestatus setsebool getsebool
          semanage chcon restorecon sealert audit2allow audit2why
        ].freeze

        FORBIDDEN_COMMAND_PATTERNS = FORBIDDEN_COMMANDS.map { |cmd| /\b#{cmd}\b/ }

        SELINUX_PATHS = %w[
          /etc/selinux/
          /etc/sysconfig/selinux
        ].freeze

        def_node_matcher :selinux_resource?, <<~PATTERN
          (block
            (send nil? {:selinux_state :selinux_boolean :selinux_fcontext :selinux_permissive :selinux_module :selinux_install :selinux_port :selinux_login :selinux_user} ...)
            ...
          )
        PATTERN

        def on_block(node)
          return if cookbook_whitelisted?('platform_cookbooks')

          # Check for SELinux Chef resources
          if selinux_resource?(node)
            add_offense(node.send_node)
            return
          end

          # Check file resources for SELinux paths
          if (path = file_resource?(node))
            check_selinux_path(node, path)
          end

          # Check execute/bash resources
          if execute_resource?(node) || bash_resource?(node)
            check_commands_for_selinux(node)
          end
        end

        private

        def check_selinux_path(node, path)
          SELINUX_PATHS.each do |selinux_path|
            if path.start_with?(selinux_path)
              add_offense(node.send_node)
              break
            end
          end
        end

        def check_commands_for_selinux(node)
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
