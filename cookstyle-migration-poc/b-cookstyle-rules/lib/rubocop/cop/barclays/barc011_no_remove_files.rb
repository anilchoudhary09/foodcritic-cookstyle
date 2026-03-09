# frozen_string_literal: true

module RuboCop
  module Cop
    module Barclays
      # BARC011: Prohibits file/directory removal
      #
      # Deleting files and directories can cause system instability and
      # data loss. Use explicit action :delete only when necessary and
      # approved.
      #
      # @example
      #   # bad - removes file with rm command
      #   execute 'remove_file' do
      #     command 'rm -rf /app/data'
      #   end
      #
      #   # bad - removes directory
      #   directory '/app/logs' do
      #     action :delete
      #     recursive true
      #   end
      #
      class Barc011NoRemoveFiles < Base
        MSG = 'BARC011: File/directory removal is restricted. ' \
              'Ensure proper backup exists and removal is approved.'

        FORBIDDEN_COMMANDS = [
          /\brm\s+-rf\b/,
          /\brm\s+-r\b/,
          /\brm\s+-f\b/,
          /\brmdir\b/,
          /\bunlink\b/,
        ].freeze

        def_node_matcher :delete_action?, <<~PATTERN
          (send nil? :action (sym :delete))
        PATTERN

        def_node_matcher :recursive_true?, <<~PATTERN
          (send nil? :recursive (true))
        PATTERN

        def on_block(node)
          return if cookbook_whitelisted?('platform_cookbooks')

          # Check for directory with delete + recursive
          if directory_resource?(node) && has_recursive_delete?(node)
            add_offense(node.send_node)
            return
          end

          # Check execute/bash resources
          if execute_resource?(node) || bash_resource?(node)
            check_commands_for_removal(node)
          end
        end

        private

        def has_recursive_delete?(node)
          has_delete = false
          has_recursive = false

          node.each_descendant(:send) do |send_node|
            has_delete = true if delete_action?(send_node)
            has_recursive = true if recursive_true?(send_node)
          end

          has_delete && has_recursive
        end

        def check_commands_for_removal(node)
          find_command_strings(node).each do |cmd_node, cmd|
            FORBIDDEN_COMMANDS.each do |pattern|
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
