# frozen_string_literal: true

module RuboCop
  module Cop
    module Barclays
      # Base class for all Barclays custom cops
      # Provides common functionality for Chef cookbook analysis
      class Base < RuboCop::Cop::Base
        # Common node matchers for Chef resources
        def_node_matcher :chef_resource?, <<~PATTERN
          (block
            (send nil? $_ ...)
            ...
          )
        PATTERN

        def_node_matcher :resource_name, <<~PATTERN
          (block
            (send nil? _ (str $_))
            ...
          )
        PATTERN

        def_node_matcher :execute_resource?, <<~PATTERN
          (block
            (send nil? :execute ...)
            ...
          )
        PATTERN

        def_node_matcher :bash_resource?, <<~PATTERN
          (block
            (send nil? {:bash :script :powershell_script} ...)
            ...
          )
        PATTERN

        def_node_matcher :service_resource?, <<~PATTERN
          (block
            (send nil? :service (str $_))
            ...
          )
        PATTERN

        def_node_matcher :file_resource?, <<~PATTERN
          (block
            (send nil? {:file :cookbook_file :template :remote_file} (str $_))
            ...
          )
        PATTERN

        def_node_matcher :directory_resource?, <<~PATTERN
          (block
            (send nil? :directory (str $_))
            ...
          )
        PATTERN

        def_node_matcher :user_resource?, <<~PATTERN
          (block
            (send nil? :user ...)
            ...
          )
        PATTERN

        def_node_matcher :group_resource?, <<~PATTERN
          (block
            (send nil? :group ...)
            ...
          )
        PATTERN

        def_node_matcher :command_property, <<~PATTERN
          (send nil? :command (str $_))
        PATTERN

        def_node_matcher :code_property, <<~PATTERN
          (send nil? :code (str $_))
        PATTERN

        def_node_matcher :action_property, <<~PATTERN
          (send nil? :action $_)
        PATTERN

        private

        # Extract cookbook name from file path
        def cookbook_name
          path = processed_source.file_path
          match = path.match(%r{cookbooks/([^/]+)/})
          match ? match[1] : nil
        end

        # Check if current cookbook is in whitelist
        def cookbook_whitelisted?(whitelist_name)
          name = cookbook_name
          return false unless name

          BCookstyleRules.cookbook_whitelisted?(name, whitelist_name)
        end

        # Find all string nodes containing specific patterns
        def find_strings_matching(node, patterns)
          matches = []
          return matches unless node

          node.each_descendant(:str) do |str_node|
            value = str_node.value
            patterns.each do |pattern|
              if pattern.is_a?(Regexp)
                matches << [str_node, value] if value =~ pattern
              else
                matches << [str_node, value] if value.include?(pattern)
              end
            end
          end
          matches
        end

        # Find command strings in execute/bash/script resources
        def find_command_strings(node)
          commands = []
          return commands unless node

          # Look for command property
          node.each_descendant(:send) do |send_node|
            if (cmd = command_property(send_node))
              commands << [send_node, cmd]
            end
            if (code = code_property(send_node))
              commands << [send_node, code]
            end
          end

          # Also check the resource name for execute resources
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
