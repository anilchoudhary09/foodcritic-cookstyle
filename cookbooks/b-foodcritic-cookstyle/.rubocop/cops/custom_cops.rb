# frozen_string_literal: true

#
# Custom Cookstyle Cops for Organization-Specific Rules
#
# This file demonstrates how to create custom RuboCop/Cookstyle cops
# for enforcing organization-specific coding standards
#
# Place this file in: .rubocop/cops/ or lib/rubocop/cop/custom/
#

require 'rubocop'

module RuboCop
  module Cop
    module Custom
      # =======================================================================
      # Custom Cop: RequireResourceDescription
      # =======================================================================
      # This cop ensures that all Chef resources have a description comment
      # above them explaining what the resource does.
      #
      # @example Bad
      #   package 'nginx' do
      #     action :install
      #   end
      #
      # @example Good
      #   # Install nginx web server for serving static content
      #   package 'nginx' do
      #     action :install
      #   end
      #
      class RequireResourceDescription < Base
        MSG = 'Chef resource should have a descriptive comment above it explaining its purpose.'

        CHEF_RESOURCES = %w[
          package service file directory template cookbook_file
          remote_file execute bash script ruby_block user group
          cron mount link git deploy apt_package yum_package
        ].freeze

        def on_send(node)
          return unless chef_resource?(node)
          return if has_comment_above?(node)

          add_offense(node)
        end

        private

        def chef_resource?(node)
          return false unless node.method_name

          CHEF_RESOURCES.include?(node.method_name.to_s)
        end

        def has_comment_above?(node)
          # Check for comments immediately above this node
          processed_source.comments.any? do |comment|
            comment.loc.line == node.loc.line - 1
          end
        end
      end

      # =======================================================================
      # Custom Cop: RequireExplicitAction
      # =======================================================================
      # This cop ensures that all Chef resources have an explicit action
      # defined rather than relying on defaults.
      #
      # @example Bad
      #   package 'nginx' do
      #     # no action specified, uses default
      #   end
      #
      # @example Good
      #   package 'nginx' do
      #     action :install
      #   end
      #
      class RequireExplicitAction < Base
        extend AutoCorrector

        MSG = 'Chef resource should have an explicit action defined.'

        CHEF_RESOURCES_WITH_DEFAULTS = {
          'package' => ':install',
          'service' => ':nothing',
          'file' => ':create',
          'directory' => ':create',
          'template' => ':create',
          'cookbook_file' => ':create',
          'remote_file' => ':create',
          'execute' => ':run',
          'bash' => ':run',
          'ruby_block' => ':run'
        }.freeze

        def on_block(node)
          return unless chef_resource_block?(node)
          return if has_action?(node)

          add_offense(node.send_node) do |corrector|
            # Auto-correct by adding the default action
            resource_name = node.send_node.method_name.to_s
            default_action = CHEF_RESOURCES_WITH_DEFAULTS[resource_name]

            if default_action
              # Insert action before 'end'
              corrector.insert_before(
                node.loc.end,
                "  action #{default_action}\n"
              )
            end
          end
        end

        private

        def chef_resource_block?(node)
          return false unless node.send_node&.method_name

          CHEF_RESOURCES_WITH_DEFAULTS.key?(node.send_node.method_name.to_s)
        end

        def has_action?(node)
          node.body&.each_descendant(:send)&.any? do |send_node|
            send_node.method_name == :action
          end
        end
      end

      # =======================================================================
      # Custom Cop: NoHardcodedPasswords
      # =======================================================================
      # This cop detects hardcoded passwords or secrets in Chef recipes.
      #
      # @example Bad
      #   user 'deploy' do
      #     password 'secret123'
      #   end
      #
      # @example Good
      #   user 'deploy' do
      #     password data_bag_item('users', 'deploy')['password']
      #   end
      #
      class NoHardcodedPasswords < Base
        MSG = 'Avoid hardcoding passwords. Use data bags, encrypted data bags, or Chef Vault.'

        SENSITIVE_METHODS = %i[password secret api_key token auth_token].freeze

        def on_send(node)
          return unless sensitive_method?(node)
          return unless hardcoded_value?(node)

          add_offense(node)
        end

        private

        def sensitive_method?(node)
          SENSITIVE_METHODS.include?(node.method_name)
        end

        def hardcoded_value?(node)
          # Check if the argument is a plain string
          return false unless node.arguments.any?

          first_arg = node.arguments.first
          first_arg&.str_type? || first_arg&.sym_type?
        end
      end

      # =======================================================================
      # Custom Cop: RequireGuardClause
      # =======================================================================
      # This cop ensures execute resources have guard clauses (not_if/only_if)
      #
      # @example Bad
      #   execute 'install-app' do
      #     command './install.sh'
      #   end
      #
      # @example Good
      #   execute 'install-app' do
      #     command './install.sh'
      #     not_if { File.exist?('/opt/app/installed') }
      #   end
      #
      class RequireGuardClause < Base
        MSG = 'Execute resources should have a guard clause (not_if or only_if) for idempotency.'

        GUARDED_RESOURCES = %w[execute bash script].freeze

        def on_block(node)
          return unless guarded_resource_block?(node)
          return if has_guard?(node)

          add_offense(node.send_node)
        end

        private

        def guarded_resource_block?(node)
          return false unless node.send_node&.method_name

          GUARDED_RESOURCES.include?(node.send_node.method_name.to_s)
        end

        def has_guard?(node)
          return false unless node.body

          node.body.each_descendant(:send).any? do |send_node|
            %i[not_if only_if creates].include?(send_node.method_name)
          end
        end
      end

      # =======================================================================
      # Custom Cop: PreferPlatformHelpers
      # =======================================================================
      # This cop encourages using platform helpers instead of direct comparison
      #
      # @example Bad
      #   if node['platform'] == 'ubuntu'
      #
      # @example Good
      #   if platform?('ubuntu')
      #
      class PreferPlatformHelpers < Base
        MSG = "Use platform helpers (platform?, platform_family?) instead of comparing node['platform']."

        def on_send(node)
          return unless platform_comparison?(node)

          add_offense(node)
        end

        private

        def platform_comparison?(node)
          return false unless node.method_name == :==

          receiver = node.receiver
          return false unless receiver&.send_type?

          # Check for node['platform'] or node['platform_family']
          receiver.method_name == :[] &&
            receiver.arguments.first&.value.to_s.match?(/^platform/)
        end
      end
    end
  end
end
