# frozen_string_literal: true

module RuboCop
  module Cop
    module Barclays
      # BARC011: Prohibits file/directory removal
      #
      # @example
      #   # bad
      #   execute 'clean' do
      #     command 'rm -rf /app/data'
      #   end
      #
      class Barc011NoRemoveFiles < Base
        MSG = 'BARC011: File/directory removal is restricted. ' \
              'Ensure proper backup exists and removal is approved.'

        FORBIDDEN_PATTERNS = [/\brm\s+-rf\b/, /\brm\s+-r\b/, /\brmdir\b/, /\bunlink\b/].freeze

        def_node_matcher :delete_action?, <<~PATTERN
          (send nil? :action (sym :delete))
        PATTERN

        def_node_matcher :recursive_true?, <<~PATTERN
          (send nil? :recursive (true))
        PATTERN

        def on_block(node)
          return if cookbook_whitelisted?('platform_cookbooks')

          if directory_resource?(node) && has_recursive_delete?(node)
            add_offense(node.send_node)
            return
          end

          check_commands(node) if execute_resource?(node) || bash_resource?(node)
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
