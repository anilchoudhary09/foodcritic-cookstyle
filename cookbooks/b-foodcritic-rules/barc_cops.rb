# frozen_string_literal: true

# barc_cops.rb - Cookstyle cops that read exceptions from rules.rb
#
# This file loads the existing rules.rb to get exception data:
# - @restricted_services: Services whitelisted per cookbook
# - @etc_whitelist: /etc paths whitelisted per cookbook
# - @etc_blacklist: /etc paths that are never allowed
# - @system_services: Critical system services (dhcpd, ntpd, sshd, etc.)
#
# Usage in .rubocop.yml:
#   require:
#     - ./barc_cops.rb

require 'pathname'

# Module to load and provide access to rules.rb data
module BarcRulesData
  class << self
    attr_reader :restricted_services, :etc_whitelist, :etc_blacklist,
                :system_services, :restricted_attributes

    def load_rules!
      return if @loaded

      rules_file = File.join(File.dirname(__FILE__), 'rules.rb')

      # Create a binding context to evaluate rules.rb
      context = RulesContext.new
      context.instance_eval(File.read(rules_file), rules_file)

      @restricted_services = context.restricted_services || {}
      @etc_whitelist = context.etc_whitelist || {}
      @etc_blacklist = context.etc_blacklist || []
      @system_services = context.system_services || []
      @restricted_attributes = context.restricted_attributes || {}

      @loaded = true
    end

    # Check if service is whitelisted for a cookbook
    # Returns true if:
    #   - Service has empty array (allowed for all)
    #   - Cookbook is in the allowed list
    def service_whitelisted?(service_name, cookbook_name)
      load_rules!

      # Find matching service key (exact or prefix match)
      key = find_service_key(service_name)
      return false unless key

      allowed = @restricted_services[key]
      allowed.empty? || allowed.include?(cookbook_name)
    end

    # Check if /etc path is whitelisted for a cookbook
    def etc_path_whitelisted?(path, cookbook_name)
      load_rules!

      # Check exact match
      if @etc_whitelist.key?(path)
        allowed = @etc_whitelist[path]
        return true if allowed.empty? || allowed.include?(cookbook_name)
      end

      # Check prefix match
      @etc_whitelist.each do |pattern, allowed|
        if path.start_with?(pattern)
          return true if allowed.empty? || allowed.include?(cookbook_name)
        end
      end

      false
    end

    # Check if path is in the blacklist
    def etc_path_blacklisted?(path)
      load_rules!

      @etc_blacklist.any? do |blacklisted|
        if blacklisted.end_with?('/')
          path.start_with?(blacklisted)
        else
          path == blacklisted || path.start_with?(blacklisted + '/')
        end
      end
    end

    # Check if service is a restricted system service
    def system_service?(service_name)
      load_rules!

      normalized = service_name.to_s.downcase.strip
      @system_services.any? { |s| normalized.include?(s.to_s.downcase) }
    end

    private

    def find_service_key(service_name)
      normalized = service_name.to_s.downcase.strip

      # Exact match first
      return service_name if @restricted_services.key?(service_name)

      # Check case-insensitive and prefix matches
      @restricted_services.keys.find do |key|
        key_lower = key.to_s.downcase
        if key.end_with?('-') || key.end_with?('@')
          normalized.start_with?(key_lower.chomp('-').chomp('@'))
        else
          normalized == key_lower || normalized.include?(key_lower)
        end
      end
    end
  end

  # Context for evaluating rules.rb
  class RulesContext
    attr_reader :restricted_services, :etc_whitelist, :etc_blacklist,
                :system_services, :restricted_attributes

    def initialize
      @restricted_services = {}
      @etc_whitelist = {}
      @etc_blacklist = []
      @system_services = []
      @restricted_attributes = {}
    end

    # Capture instance variable assignments from rules.rb
    def method_missing(method, *args)
      # Ignore unknown methods
    end

    def respond_to_missing?(method, include_private = false)
      true
    end

    # Override instance_eval to capture @variable assignments
    def instance_eval(code, file = nil)
      # Parse and evaluate, capturing the instance variables
      eval(code, binding, file || '(eval)')

      # Copy instance variables
      @restricted_services = instance_variable_get(:@restricted_services) || {}
      @etc_whitelist = instance_variable_get(:@etc_whitelist) || {}
      @etc_blacklist = instance_variable_get(:@etc_blacklist) || []
      @system_services = instance_variable_get(:@system_services) || []
      @restricted_attributes = instance_variable_get(:@restricted_attributes) || {}
    end
  end
end

# Load rules on require
BarcRulesData.load_rules!

module RuboCop
  module Cop
    module Barclays
      # Base class for Barclays cops
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
          (block (send nil? {:bash :script :powershell_script :batch} ...) ...)
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

      # BARC001: Do not create local users
      class Barc001NoLocalUsers < Base
        MSG = 'BARC001: Do not create local users. Use Active Directory instead.'

        USER_COMMANDS = %w[useradd adduser usermod userdel passwd chpasswd].freeze

        def on_block(node)
          add_offense(node.send_node) if user_resource?(node)

          return unless execute_resource?(node) || bash_resource?(node)

          find_command_strings(node).each do |cmd_node, cmd|
            if USER_COMMANDS.any? { |c| cmd =~ /\b#{c}\b/ }
              add_offense(cmd_node)
            end
          end
        end
      end

      # BARC002: Do not create local groups
      class Barc002NoLocalGroups < Base
        MSG = 'BARC002: Do not create local groups. Use Active Directory instead.'

        GROUP_COMMANDS = %w[groupadd addgroup groupmod groupdel].freeze

        def on_block(node)
          add_offense(node.send_node) if group_resource?(node)

          return unless execute_resource?(node) || bash_resource?(node)

          find_command_strings(node).each do |cmd_node, cmd|
            if GROUP_COMMANDS.any? { |c| cmd =~ /\b#{c}\b/ }
              add_offense(cmd_node)
            end
          end
        end

        def_node_matcher :group_resource?, <<~PATTERN
          (block (send nil? :group ...) ...)
        PATTERN
      end

      # BARC003: Do not modify root SSH files
      class Barc003NoRootSsh < Base
        MSG = 'BARC003: Do not modify SSH files for root user.'

        ROOT_SSH_PATTERN = %r{/root/\.ssh/}.freeze

        def on_block(node)
          if (path = file_resource?(node)) || (path = directory_resource?(node))
            add_offense(node.send_node) if path =~ ROOT_SSH_PATTERN
          end
        end
      end

      # BARC005: Do not modify protected /etc paths
      class Barc005EtcBlacklist < Base
        MSG = 'BARC005: Modification of %<path>s is not allowed.'

        def on_block(node)
          if (path = file_resource?(node))
            check_path(node, path)
          end

          if (path = directory_resource?(node))
            check_path(node, path)
          end
        end

        private

        def check_path(node, path)
          return unless path.start_with?('/etc/')
          return if BarcRulesData.etc_path_whitelisted?(path, cookbook_name)
          return unless BarcRulesData.etc_path_blacklisted?(path)

          add_offense(node.send_node, message: format(MSG, path: path))
        end
      end

      # BARC006: Do not reboot/halt/shutdown
      class Barc006NoReboot < Base
        MSG = 'BARC006: Do not reboot, halt, or shutdown nodes.'

        REBOOT_COMMANDS = %w[reboot halt shutdown poweroff].freeze

        def_node_matcher :reboot_resource?, <<~PATTERN
          (block (send nil? :reboot ...) ...)
        PATTERN

        def on_block(node)
          add_offense(node.send_node) if reboot_resource?(node)

          return unless execute_resource?(node) || bash_resource?(node)

          find_command_strings(node).each do |cmd_node, cmd|
            if REBOOT_COMMANDS.any? { |c| cmd =~ /\b#{c}\b/ }
              add_offense(cmd_node)
            end
          end
        end
      end

      # BARC007: Do not modify SELinux
      class Barc007NoSelinux < Base
        MSG = 'BARC007: Do not modify SELinux configuration.'

        SELINUX_COMMANDS = %w[setenforce setsebool chcon semanage togglesebool setfiles].freeze

        def on_block(node)
          return unless execute_resource?(node) || bash_resource?(node)

          find_command_strings(node).each do |cmd_node, cmd|
            if SELINUX_COMMANDS.any? { |c| cmd =~ /\b#{c}\b/ }
              add_offense(cmd_node)
            end
          end
        end
      end

      # BARC008: Do not kill processes
      class Barc008NoKillProcess < Base
        MSG = 'BARC008: Do not kill processes.'

        KILL_COMMANDS = %w[kill pkill killall killall5 pskill taskkill].freeze

        def on_block(node)
          return unless execute_resource?(node) || bash_resource?(node)

          find_command_strings(node).each do |cmd_node, cmd|
            if KILL_COMMANDS.any? { |c| cmd =~ /\b#{c}\b/ }
              add_offense(cmd_node)
            end
          end
        end
      end

      # BARC009: Do not modify firewall
      class Barc009NoFirewall < Base
        MSG = 'BARC009: Do not modify firewall rules.'

        FIREWALL_COMMANDS = %w[iptables firewall-cmd firewall-config].freeze

        def on_block(node)
          return unless execute_resource?(node) || bash_resource?(node)

          find_command_strings(node).each do |cmd_node, cmd|
            if FIREWALL_COMMANDS.any? { |c| cmd =~ /\b#{c}\b/ }
              add_offense(cmd_node)
            end
          end
        end
      end

      # BARC011: Do not remove files dangerously
      class Barc011NoRemoveFiles < Base
        MSG = 'BARC011: Do not use rm -rf or dangerous file removal.'

        def on_block(node)
          return unless execute_resource?(node) || bash_resource?(node)

          find_command_strings(node).each do |cmd_node, cmd|
            if cmd =~ /\brm\s+(-[rf]+\s+)*\// || cmd =~ /\brmdir\b/
              add_offense(cmd_node)
            end
          end
        end
      end

      # BARC016: Use Chef resources instead of shell commands
      class Barc016UseChefResources < Base
        MSG = 'BARC016: Use Chef service/package resources instead of shell commands.'

        def on_block(node)
          return unless execute_resource?(node) || bash_resource?(node)

          find_command_strings(node).each do |cmd_node, cmd|
            # Check for service command
            if cmd =~ /\bservice\s+\w+\s+(start|stop|restart|reload)\b/
              add_offense(cmd_node)
            end
            # Check for yum/apt install
            if cmd =~ /\b(yum|apt-get|apt|dnf)\s+(install|remove)\b/
              add_offense(cmd_node)
            end
          end
        end
      end

      # BARC017: Do not manage system services
      class Barc017NoSystemServices < Base
        MSG = 'BARC017: Management of system service "%<service>s" is restricted.'

        def on_block(node)
          if (service_name = service_resource?(node))
            check_service(node, service_name)
          end

          return unless execute_resource?(node) || bash_resource?(node)

          find_command_strings(node).each do |cmd_node, cmd|
            if cmd =~ /systemctl\s+(start|stop|restart|enable|disable)\s+(\S+)/
              check_service_cmd(cmd_node, Regexp.last_match(2))
            end
            if cmd =~ /service\s+(\S+)\s+(start|stop|restart)/
              check_service_cmd(cmd_node, Regexp.last_match(1))
            end
          end
        end

        private

        def check_service(node, service_name)
          return unless BarcRulesData.system_service?(service_name)
          return if BarcRulesData.service_whitelisted?(service_name, cookbook_name)

          add_offense(node.send_node, message: format(MSG, service: service_name))
        end

        def check_service_cmd(node, service_name)
          return unless BarcRulesData.system_service?(service_name)
          return if BarcRulesData.service_whitelisted?(service_name, cookbook_name)

          add_offense(node, message: format(MSG, service: service_name))
        end
      end

      # BARC019: Do not use find or sudo
      class Barc019NoFindSudo < Base
        MSG = 'BARC019: Do not use find command on root or sudo. Also avoid chmod 777.'

        def on_block(node)
          return unless execute_resource?(node) || bash_resource?(node)

          find_command_strings(node).each do |cmd_node, cmd|
            if cmd =~ /\bfind\s+\// || cmd =~ /\bsudo\b/ || cmd =~ /chmod\s+777/
              add_offense(cmd_node)
            end
          end
        end
      end
    end
  end
end
