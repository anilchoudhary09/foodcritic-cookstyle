# frozen_string_literal: true

module RuboCop
  module Cop
    module Barclays
      # Base class for all Barclays custom cops
      class Base < RuboCop::Cop::Base
        # Node matchers for Chef resources
        def_node_matcher :chef_resource?, <<~PATTERN
          (block (send nil? $_ ...) ...)
        PATTERN

        def_node_matcher :resource_name, <<~PATTERN
          (block (send nil? _ (str $_)) ...)
        PATTERN

        def_node_matcher :execute_resource?, <<~PATTERN
          (block (send nil? :execute ...) ...)
        PATTERN

        def_node_matcher :bash_resource?, <<~PATTERN
          (block (send nil? {:bash :script :powershell_script} ...) ...)
        PATTERN

        def_node_matcher :service_resource?, <<~PATTERN
          (block (send nil? :service (str $_)) ...)
        PATTERN

        def_node_matcher :file_resource?, <<~PATTERN
          (block (send nil? {:file :cookbook_file :template :remote_file} (str $_)) ...)
        PATTERN

        def_node_matcher :directory_resource?, <<~PATTERN
          (block (send nil? :directory (str $_)) ...)
        PATTERN

        def_node_matcher :user_resource?, <<~PATTERN
          (block (send nil? :user ...) ...)
        PATTERN

        def_node_matcher :group_resource?, <<~PATTERN
          (block (send nil? :group ...) ...)
        PATTERN

        def_node_matcher :command_property, <<~PATTERN
          (send nil? :command (str $_))
        PATTERN

        def_node_matcher :code_property, <<~PATTERN
          (send nil? :code (str $_))
        PATTERN

        private

        def cookbook_name
          path = processed_source.file_path
          match = path.match(%r{cookbooks/([^/]+)/})
          match ? match[1] : nil
        end

        def cookbook_whitelisted?(whitelist_name)
          name = cookbook_name
          return false unless name
          BCookstyleRules.cookbook_whitelisted?(name, whitelist_name)
        end

        def find_command_strings(node)
          commands = []
          return commands unless node

          node.each_descendant(:send) do |send_node|
            if (cmd = command_property(send_node))
              commands << [send_node, cmd]
            end
            if (code = code_property(send_node))
              commands << [send_node, code]
            end
          end

          if execute_resource?(node)
            name = resource_name(node)
            commands << [node, name] if name
          end

          commands
        end
      end
    end
  end
end
