# frozen_string_literal: true

#
# barc_cops.rb - COMPREHENSIVE Cookstyle enforcement from rules.rb
#
# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  THIS FILE IS 100% STATIC - NEVER NEEDS ANY MODIFICATION                     ║
# ║                                                                              ║
# ║  ALL 36 BARC RULES COVERED:                                                  ║
# ║  BARC001 - No local users          BARC019 - No find/sudo                    ║
# ║  BARC002 - No local groups         BARC020 - No misc commands                ║
# ║  BARC003 - No /root/.ssh           BARC021 - Exact version deps              ║
# ║  BARC004 - No SSH keys             BARC022 - No chef exit                    ║
# ║  BARC005 - /etc blacklist          BARC023 - Supported platform              ║
# ║  BARC005a- /etc attr blacklist     BARC024 - Maintainer info                 ║
# ║  BARC006 - No reboot/shutdown      BARC025 - Node tags whitelist             ║
# ║  BARC007 - No SELinux              BARC026 - No node.save                    ║
# ║  BARC008 - No kill process         BARC027 - MW packages                     ║
# ║  BARC009 - No firewall             BARC028 - Restricted cookbook deps        ║
# ║  BARC010 - No init/telinit         BARC029 - Community cookbooks             ║
# ║  BARC011 - No rm/rmdir             BARC030 - Deprecated cookbooks            ║
# ║  BARC012 - No kernel manipulation  BARC031 - Controlled packages             ║
# ║  BARC013 - No volume/mount         BARC032 - Cookbook version flags          ║
# ║  BARC014 - No network manipulation BARC033 - Allowed pins only               ║
# ║  BARC015 - No root cron            BARC034 - Restricted attrs roles          ║
# ║  BARC016 - Use Chef resources      BARC035 - Restricted attributes           ║
# ║  BARC017 - No system services      BARC036 - Java version pin                ║
# ║  BARC018 - Review service                                                    ║
# ╚══════════════════════════════════════════════════════════════════════════════╝

# ══════════════════════════════════════════════════════════════════════════════
# RULES ENGINE - Loads all data from rules.rb
# ══════════════════════════════════════════════════════════════════════════════
module BarcRulesEngine
  @rules = {}

  class << self
    def load!
      return if @loaded
      rules_file = File.join(File.dirname(__FILE__), 'rules.rb')
      content = File.read(rules_file).split(/^rule\s+['"]BARC/).first || ''

      b = binding
      begin
        eval(content, b, rules_file)
      rescue => e
        warn "BarcRulesEngine: #{e.message}"
      end

      @rules = {
        # Core service/path restrictions
        system_services: safe_eval('@system_services', b) || [],
        restricted_services: safe_eval('@restricted_services', b) || {},
        etc_whitelist: safe_eval('@etc_whitelist', b) || {},
        etc_blacklist: safe_eval('@etc_blacklist', b) || [],
        restricted_attributes: safe_eval('@restricted_attributes', b) || {},
        cmd_whitelist: safe_eval('@cmd_whitelist', b) || {},

        # Bypass/whitelist arrays
        platform_cookbooks: safe_eval('@platform_cookbook_whitelist', b) || [],
        local_access_cookbooks: safe_eval('@local_access_cookbook_whitelist', b) || [],
        reboot_cookbooks: safe_eval('@reboot_cookbook_whitelist', b) || [],
        selinux_cookbooks: safe_eval('@selinux_cookbook_whitelist', b) || [],
        mount_cookbooks: safe_eval('@mount_cookbook_whitelist', b) || [],
        cron_root_cookbooks: safe_eval('@cron_root_whitelist', b) || [],
        rpm_cookbooks: safe_eval('@rpm_cookbook_whitelist', b) || [],
        system_services_cookbooks: safe_eval('@system_services_cookbook_whitelist', b) || [],

        # Additional rule data for BARC018-036
        tag_whitelist: safe_eval('@tag_whitelist', b) || {},
        cookbook_coverage_whitelist: safe_eval('@cookbook_coverage_whitelist', b) || {},
        restricted_cookbook_whitelist: safe_eval('@restricted_cookbook_whitelist', b) || {},
        blocked_cookbooks: safe_eval('@blocked_cookbooks', b) || [],
        deprecated_cookbooks: safe_eval('@deprecated_cookbooks', b) || {},
        cookbook_minimum_versions: safe_eval('@cookbook_minimum_versions', b) || {},
        whitelist_cookbook_allowed_pins_only: safe_eval('@whitelist_cookbook_allowed_pins_only', b) || [],
        cookbook_allowed_pins_only: safe_eval('@cookbook_allowed_pins_only', b) || {},
        cookbook_wraps: safe_eval('@cookbook_wraps', b) || {},
        mw_cookbook_whitelist: safe_eval('@mw_cookbook_whitelist', b) || [],
        mw_pkg_prefixes: safe_eval('@mw_pkg_prefixes', b) || [],
        controlled_packages: safe_eval('@controlled_packages', b) || {},
        orac_java_hard_pined_up: safe_eval('@orac_java_hard_pined_up', b) || {},
      }
      @loaded = true
    end

    def rules
      load!
      @rules
    end

    # Bypass checks
    def platform_bypass?(cookbook)
      rules[:platform_cookbooks].include?(cookbook)
    end

    def local_access_bypass?(cookbook)
      rules[:local_access_cookbooks].include?(cookbook)
    end

    def reboot_bypass?(cookbook)
      rules[:reboot_cookbooks].include?(cookbook)
    end

    def selinux_bypass?(cookbook)
      rules[:selinux_cookbooks].include?(cookbook)
    end

    def mount_bypass?(cookbook)
      rules[:mount_cookbooks].include?(cookbook)
    end

    def cron_bypass?(cookbook)
      rules[:cron_root_cookbooks].include?(cookbook)
    end

    def rpm_bypass?(cookbook)
      rules[:rpm_cookbooks].include?(cookbook)
    end

    # /etc path check
    def etc_allowed?(path, cookbook)
      return true if platform_bypass?(cookbook)
      rules[:etc_whitelist].each do |pattern, allowed|
        if path_matches?(path, pattern)
          return true if allowed.empty? || allowed.include?(cookbook)
        end
      end
      !path_blacklisted?(path)
    end

    # Service check
    def service_allowed?(service, cookbook)
      return true if platform_bypass?(cookbook)
      return true if rules[:system_services_cookbooks]&.include?(cookbook)

      svc = service.to_s.downcase.strip
      is_system = rules[:system_services].any? { |s| svc.include?(s.to_s.downcase) }
      return true unless is_system

      rules[:restricted_services].each do |pattern, allowed|
        pat = pattern.to_s.downcase.chomp('-').chomp('@')
        if svc.include?(pat) || svc == pattern.to_s.downcase
          return true if allowed.empty? || allowed.include?(cookbook)
        end
      end
      false
    end

    # Attribute check
    def attribute_allowed?(attr, cookbook)
      return true if platform_bypass?(cookbook)
      return true unless rules[:restricted_attributes].key?(attr)
      allowed = rules[:restricted_attributes][attr]
      allowed.empty? || allowed.include?(cookbook)
    end

    # Service needs review (BARC018)
    def service_needs_review?(service, cookbook)
      return false if platform_bypass?(cookbook)
      svc = service.to_s.downcase.strip
      return false if rules[:system_services].any? { |s| svc.include?(s.to_s.downcase) }
      rules[:restricted_services].each do |pattern, allowed|
        pat = pattern.to_s.downcase.chomp('-').chomp('@')
        if svc.include?(pat)
          return !allowed.empty? && !allowed.include?(cookbook)
        end
      end
      false
    end

    # Tag whitelist check (BARC025)
    # If cookbook not in whitelist, NO tags allowed
    # If cookbook in whitelist, only specified tags allowed
    def tag_allowed?(tag, cookbook)
      return true if platform_bypass?(cookbook)
      allowed_tags = rules[:tag_whitelist][cookbook]
      return false if allowed_tags.nil?  # Cookbook not in whitelist = no tags allowed
      allowed_tags.include?(tag)
    end

    # Cookbook in coverage whitelist (BARC021)
    def cookbook_in_coverage_whitelist?(dep)
      rules[:cookbook_coverage_whitelist].key?(dep)
    end

    # Restricted cookbook dependency (BARC028)
    def restricted_cookbook_allowed?(dep, cookbook)
      return true unless rules[:restricted_cookbook_whitelist].key?(dep)
      rules[:restricted_cookbook_whitelist][dep].include?(cookbook)
    end

    # Blocked cookbook (BARC029)
    def cookbook_blocked?(dep, cookbook)
      rules[:blocked_cookbooks].any? do |entry|
        blocked_name = entry.values.first rescue entry
        blocked_name == dep && rules[:cookbook_wraps][cookbook] != dep
      end
    end

    # Deprecated cookbook (BARC030)
    def cookbook_deprecated?(dep)
      rules[:deprecated_cookbooks].key?(dep)
    end

    # Cookbook version check (BARC032)
    def cookbook_version_ok?(dep, version)
      return true unless rules[:cookbook_minimum_versions].key?(dep)
      return false unless version
      begin
        Gem::Version.new(version) >= Gem::Version.new(rules[:cookbook_minimum_versions][dep])
      rescue
        true
      end
    end

    # Middleware cookbook whitelist (BARC027)
    def mw_cookbook_allowed?(cookbook)
      rules[:mw_cookbook_whitelist].include?(cookbook)
    end

    # Middleware package check (BARC027)
    def mw_package?(pkg)
      rules[:mw_pkg_prefixes].any? { |prefix| pkg.to_s.start_with?(prefix) }
    end

    # Controlled package check (BARC031)
    def controlled_package_allowed?(pkg, cookbook)
      rules[:controlled_packages].each do |pattern, config|
        if pkg.to_s.start_with?(pattern)
          whitelist = config['whitelist'] || []
          return whitelist.include?(cookbook)
        end
      end
      true
    end

    # Java pin check (BARC036)
    def java_pin_allowed?(cookbook)
      rules[:orac_java_hard_pined_up].key?(cookbook)
    end

    # Command whitelist check - returns true if command is whitelisted for cookbook
    def cmd_whitelisted?(cmd, cookbook)
      return false unless cmd
      rules[:cmd_whitelist].each do |pattern, allowed|
        if cmd.include?(pattern)
          return true if allowed.empty? || allowed.include?(cookbook)
        end
      end
      false
    end

    # File resource types (matches @file_resource_types in rules.rb)
    FILE_RESOURCE_TYPES = %i[
      file template remote_file cookbook_file remote_directory directory
      append_if_no_line replace_or_add delete_lines add_to_list delete_from_list
    ].freeze

    def file_resource?(method_name)
      FILE_RESOURCE_TYPES.include?(method_name)
    end

    private

    def safe_eval(var, b)
      eval(var, b)
    rescue
      nil
    end

    def path_matches?(path, pattern)
      pattern.end_with?('/') ? path.start_with?(pattern) : (path == pattern || path.start_with?("#{pattern}/"))
    end

    def path_blacklisted?(path)
      rules[:etc_blacklist].any? { |b| b.end_with?('/') ? path.start_with?(b) : (path == b || path.start_with?("#{b}/")) }
    end
  end
end

BarcRulesEngine.load!

# ══════════════════════════════════════════════════════════════════════════════
# RUBOCOP COPS - All BARC rules implemented
# ══════════════════════════════════════════════════════════════════════════════
module RuboCop
  module Cop
    module Barclays
      # Shared helper
      module CookbookHelper
        def cookbook_name
          processed_source.file_path[%r{cookbooks/([^/]+)/}, 1]
        end

        def extract_string(node)
          return nil unless node
          return node.str_content if node.str_type?
          return node.value.to_s if node.sym_type?
          nil
        end

        def extract_command(node)
          # Try to get command from various patterns
          node.each_descendant(:send).each do |send_node|
            if send_node.method_name == :command || send_node.method_name == :code
              arg = send_node.arguments.first
              return extract_string(arg) if arg
            end
          end
          # Also check resource name for execute resources
          extract_string(node.send_node.arguments.first)
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC001 - No local user manipulation
      # ════════════════════════════════════════════════════════════════════
      class Barc001NoLocalUsers < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC001: Do not manipulate users locally. Use Active Directory instead.'
        UNIX_CMDS = %w[useradd usermod userdel passwd chpasswd adduser].freeze
        WIN_CMDS = ['net user', 'net.exe user'].freeze
        # .NET function pattern for PowerShell: create("user") or create('user')
        DOTNET_USER_PATTERN = /create\s*\(\s*['"]user['"]/i.freeze

        def on_block(node)
          cb = cookbook_name
          return if BarcRulesEngine.platform_bypass?(cb) || BarcRulesEngine.local_access_bypass?(cb)

          # Check user resource
          if node.send_node.method_name == :user
            add_offense(node.send_node)
            return
          end

          # Check execute/bash for forbidden commands
          return unless %i[execute bash script powershell_script batch].include?(node.send_node.method_name)
          cmd = extract_command(node)
          return unless cmd
          cmd_lower = cmd.downcase
          return unless UNIX_CMDS.any? { |c| cmd =~ /\b#{c}\b/i } ||
                        WIN_CMDS.any? { |c| cmd_lower.include?(c) } ||
                        cmd.match?(DOTNET_USER_PATTERN)
          add_offense(node.send_node)
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC002 - No local group manipulation
      # ════════════════════════════════════════════════════════════════════
      class Barc002NoLocalGroups < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC002: Do not manipulate groups locally. Use Active Directory instead.'
        UNIX_CMDS = %w[groupadd groupmod groupdel addgroup].freeze
        WIN_CMDS = ['net group', 'net localgroup', 'net.exe group', 'net.exe localgroup'].freeze
        # .NET function pattern for PowerShell: create("group") or create('group')
        DOTNET_GROUP_PATTERN = /create\s*\(\s*['"]group['"]/i.freeze

        def on_block(node)
          cb = cookbook_name
          return if BarcRulesEngine.platform_bypass?(cb) || BarcRulesEngine.local_access_bypass?(cb)

          if node.send_node.method_name == :group
            add_offense(node.send_node)
            return
          end

          return unless %i[execute bash script powershell_script batch].include?(node.send_node.method_name)
          cmd = extract_command(node)
          return unless cmd
          cmd_lower = cmd.downcase
          return unless UNIX_CMDS.any? { |c| cmd =~ /\b#{c}\b/i } ||
                        WIN_CMDS.any? { |c| cmd_lower.include?(c) } ||
                        cmd.match?(DOTNET_GROUP_PATTERN)
          add_offense(node.send_node)
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC003 - No /root/.ssh manipulation
      # ════════════════════════════════════════════════════════════════════
      class Barc003NoRootSsh < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC003: Do not manipulate files in /root/.ssh directory.'

        def on_block(node)
          return if BarcRulesEngine.platform_bypass?(cookbook_name)
          return unless BarcRulesEngine.file_resource?(node.send_node.method_name)

          path = extract_string(node.send_node.arguments.first)
          # Also check path attribute
          path ||= extract_path_attribute(node)
          return unless path&.start_with?('/root/.ssh')
          add_offense(node.send_node)
        end

        private

        def extract_path_attribute(node)
          node.each_descendant(:send) do |send_node|
            if send_node.method_name == :path
              return extract_string(send_node.arguments.first)
            end
          end
          nil
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC004 - No SSH key manipulation
      # ════════════════════════════════════════════════════════════════════
      class Barc004NoSshKeys < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC004: Do not manipulate SSH keys for any user.'
        UNIX_CMDS = %w[ssh-keygen ssh-add].freeze

        def on_block(node)
          return if BarcRulesEngine.platform_bypass?(cookbook_name)

          # Check file resources for .ssh paths (but allow known_hosts)
          if BarcRulesEngine.file_resource?(node.send_node.method_name)
            path = extract_string(node.send_node.arguments.first)
            path ||= extract_path_attribute(node)
            # Match /users/.+/.ssh or any /.ssh/ path (excluding known_hosts)
            if path&.match?(%r{/\.ssh/}) && !path&.end_with?('known_hosts')
              add_offense(node.send_node)
              return
            end
          end

          return unless %i[execute bash script].include?(node.send_node.method_name)
          cmd = extract_command(node)
          return unless cmd && UNIX_CMDS.any? { |c| cmd.include?(c) }
          add_offense(node.send_node)
        end

        private

        def extract_path_attribute(node)
          node.each_descendant(:send) do |send_node|
            return extract_string(send_node.arguments.first) if send_node.method_name == :path
          end
          nil
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC005 - /etc path blacklist (rules.rb driven)
      # ════════════════════════════════════════════════════════════════════
      class Barc005EtcBlacklist < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC005: Modification of %<path>s is not allowed. Add to rules.rb @etc_whitelist.'

        def on_block(node)
          return unless BarcRulesEngine.file_resource?(node.send_node.method_name)

          path = extract_string(node.send_node.arguments.first)
          path ||= extract_path_attribute(node)
          return unless path&.start_with?('/etc/')
          return if BarcRulesEngine.etc_allowed?(path, cookbook_name)

          add_offense(node.send_node, message: format(MSG, path: path))
        end

        private

        def extract_path_attribute(node)
          node.each_descendant(:send) do |send_node|
            return extract_string(send_node.arguments.first) if send_node.method_name == :path
          end
          nil
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC006 - No reboot/shutdown
      # ════════════════════════════════════════════════════════════════════
      class Barc006NoReboot < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC006: Do not halt, shutdown, reboot, or poweroff nodes.'
        UNIX_CMDS = %w[halt shutdown reboot poweroff].freeze
        UNIX_SYSTEMCTL = ['systemctl shutdown', 'systemctl poweroff', 'systemctl halt', 'systemctl reboot'].freeze
        WIN_CMDS = %w[stop-computer restart-computer shutdown].freeze

        def on_block(node)
          cb = cookbook_name
          return if BarcRulesEngine.platform_bypass?(cb) || BarcRulesEngine.reboot_bypass?(cb)

          if node.send_node.method_name == :reboot
            add_offense(node.send_node)
            return
          end

          return unless %i[execute bash script powershell_script batch].include?(node.send_node.method_name)
          cmd = extract_command(node)
          return unless cmd
          cmd_lower = cmd.downcase
          return unless UNIX_CMDS.any? { |c| cmd =~ /\b#{c}\b/i } ||
                        UNIX_SYSTEMCTL.any? { |c| cmd_lower.include?(c) } ||
                        WIN_CMDS.any? { |c| cmd_lower.include?(c) }
          add_offense(node.send_node)
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC007 - No SELinux manipulation
      # ════════════════════════════════════════════════════════════════════
      class Barc007NoSelinux < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC007: Do not manipulate SELinux configuration.'
        FORBIDDEN_CMDS = %w[chcon semanage setenforce setsebool togglesebool setfiles].freeze

        def on_block(node)
          cb = cookbook_name
          return if BarcRulesEngine.platform_bypass?(cb) || BarcRulesEngine.selinux_bypass?(cb)
          return unless %i[execute bash script].include?(node.send_node.method_name)

          cmd = extract_command(node)
          return unless cmd && FORBIDDEN_CMDS.any? { |c| cmd =~ /\b#{c}\b/i }
          add_offense(node.send_node)
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC008 - No kill process
      # ════════════════════════════════════════════════════════════════════
      class Barc008NoKillProcess < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC008: Do not kill or change priority of processes.'
        FORBIDDEN_CMDS = %w[kill pkill killall killall5 nice renice pskill taskkill].freeze

        def on_block(node)
          return if BarcRulesEngine.platform_bypass?(cookbook_name)
          return unless %i[execute bash script powershell_script batch].include?(node.send_node.method_name)

          cmd = extract_command(node)
          return unless cmd && FORBIDDEN_CMDS.any? { |c| cmd =~ /\b#{c}\b/i }
          add_offense(node.send_node)
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC009 - No firewall manipulation
      # ════════════════════════════════════════════════════════════════════
      class Barc009NoFirewall < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC009: Do not manipulate firewall rules.'
        UNIX_CMDS = %w[firewall-cmd firewall-config iptables].freeze
        WIN_CMDS = ['netsh firewall', 'netsh advfirewall', 'set-netfirewall', 'set-netipsec',
                    'disable-netfirewall', 'disable-netipsec', 'enable-netipsec',
                    'new-netfirewall', 'remove-netfirewall'].freeze
        FIREWALL_SERVICES = %w[iptables mpssvc policyagent].freeze

        def on_block(node)
          return if BarcRulesEngine.platform_bypass?(cookbook_name)

          # Check firewall-related services
          if %i[service windows_service].include?(node.send_node.method_name)
            # Check service_name attribute first, then fall back to resource name
            svc = extract_service_name(node) || extract_string(node.send_node.arguments.first)
            svc = svc&.downcase
            add_offense(node.send_node) if svc && FIREWALL_SERVICES.include?(svc)
            return
          end

          return unless %i[execute bash script powershell_script batch].include?(node.send_node.method_name)
          cmd = extract_command(node)
          return unless cmd
          cmd_lower = cmd.downcase
          return unless UNIX_CMDS.any? { |c| cmd =~ /\b#{c}\b/i } ||
                        WIN_CMDS.any? { |c| cmd_lower.include?(c) }
          add_offense(node.send_node)
        end

        private

        def extract_service_name(node)
          node.each_descendant(:send) do |send_node|
            return extract_string(send_node.arguments.first) if send_node.method_name == :service_name
          end
          nil
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC010 - No init/telinit
      # ════════════════════════════════════════════════════════════════════
      class Barc010NoInit < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC010: Do not use init or telinit commands.'
        FORBIDDEN_CMDS = %w[init telinit].freeze

        def on_block(node)
          return if BarcRulesEngine.platform_bypass?(cookbook_name)
          return unless %i[execute bash script].include?(node.send_node.method_name)

          cmd = extract_command(node)
          return unless cmd && FORBIDDEN_CMDS.any? { |c| cmd =~ /\b#{c}\b/ }
          add_offense(node.send_node)
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC011 - No file deletion
      # ════════════════════════════════════════════════════════════════════
      class Barc011NoRemoveFiles < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC011: Do not use rm, rmdir, or dd commands.'
        FORBIDDEN_CMDS = %w[rm rmdir dd].freeze
        FORBIDDEN_WIN = %w[del erase deltree remove-item].freeze

        def on_block(node)
          return if BarcRulesEngine.platform_bypass?(cookbook_name)
          return unless %i[execute bash script powershell_script batch].include?(node.send_node.method_name)

          cmd = extract_command(node)&.downcase
          return unless cmd
          return unless FORBIDDEN_CMDS.any? { |c| cmd =~ /\b#{c}\b/ } ||
                        FORBIDDEN_WIN.any? { |c| cmd =~ /\b#{c}\b/i }
          add_offense(node.send_node)
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC012 - No kernel manipulation
      # ════════════════════════════════════════════════════════════════════
      class Barc012NoKernel < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC012: Do not manipulate OS kernel.'
        FORBIDDEN_CMDS = %w[kexec sysctl modprobe insmod rmmod].freeze

        def on_block(node)
          return if BarcRulesEngine.platform_bypass?(cookbook_name)
          return unless %i[execute bash script].include?(node.send_node.method_name)

          cmd = extract_command(node)
          return unless cmd && FORBIDDEN_CMDS.any? { |c| cmd =~ /\b#{c}\b/ }
          add_offense(node.send_node)
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC013 - No volume/mount manipulation
      # ════════════════════════════════════════════════════════════════════
      class Barc013NoVolume < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC013: Do not manipulate volumes, partitions, or filesystems.'
        UNIX_CMDS = %w[lvremove pvremove vgremove mkfs wipefs umount mount delpart addpart
                       partx kpartx parted partprobe fdisk fsck].freeze
        WIN_CMDS = %w[diskpart format clear-disk new-partition remove-partition
                      remove-physicaldisk set-partition].freeze

        def on_block(node)
          cb = cookbook_name
          return if BarcRulesEngine.platform_bypass?(cb) || BarcRulesEngine.mount_bypass?(cb)

          if node.send_node.method_name == :mount
            add_offense(node.send_node)
            return
          end

          return unless %i[execute bash script powershell_script batch].include?(node.send_node.method_name)
          cmd = extract_command(node)
          return unless cmd
          cmd_lower = cmd.downcase
          return unless UNIX_CMDS.any? { |c| cmd =~ /\b#{c}\b/ } ||
                        WIN_CMDS.any? { |c| cmd_lower.include?(c) }
          add_offense(node.send_node)
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC014 - No network manipulation
      # ════════════════════════════════════════════════════════════════════
      class Barc014NoNetwork < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC014: Do not manipulate network configuration.'
        UNIX_CMDS = %w[ifup ifdown ip ifcfg ifconfig ifenslave ethtool route].freeze
        WIN_CMDS = ['route ', 'netsh ', 'set-netipaddress', 'set-netipinterface',
                    'set-netipv4protocol', 'set-netipv6protocol', 'set-netroute',
                    'set-nettcpsetting', 'set-netudpsetting', 'remove-netroute',
                    'remove-netipaddress'].freeze

        def on_block(node)
          return if BarcRulesEngine.platform_bypass?(cookbook_name)

          if %i[ifconfig route].include?(node.send_node.method_name)
            add_offense(node.send_node)
            return
          end

          return unless %i[execute bash script powershell_script batch].include?(node.send_node.method_name)
          cmd = extract_command(node)
          return unless cmd
          cmd_lower = cmd.downcase
          return unless UNIX_CMDS.any? { |c| cmd =~ /\b#{c}\b/ } ||
                        WIN_CMDS.any? { |c| cmd_lower.include?(c) }
          add_offense(node.send_node)
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC015 - No root cron
      # ════════════════════════════════════════════════════════════════════
      class Barc015NoRootCron < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC015: Do not manipulate root cron jobs.'
        CRONTAB_CMD = %w[crontab].freeze

        def on_block(node)
          cb = cookbook_name
          return if BarcRulesEngine.platform_bypass?(cb) || BarcRulesEngine.cron_bypass?(cb)

          # Check cron resource
          if %i[cron cron_d].include?(node.send_node.method_name)
            # Check if user is root or not specified
            has_non_root_user = false
            node.each_descendant(:send) do |send_node|
              if send_node.method_name == :user
                user = extract_string(send_node.arguments.first)
                has_non_root_user = user && user != 'root'
              end
            end
            add_offense(node.send_node) unless has_non_root_user
            return
          end

          # Check for /var/spool/cron files
          if %i[file template cookbook_file].include?(node.send_node.method_name)
            path = extract_string(node.send_node.arguments.first)
            add_offense(node.send_node) if path&.start_with?('/var/spool/cron')
            return
          end

          # Check for crontab command
          return unless %i[execute bash script].include?(node.send_node.method_name)
          cmd = extract_command(node)
          return unless cmd && CRONTAB_CMD.any? { |c| cmd =~ /\b#{c}\b/ }
          add_offense(node.send_node)
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC016 - Use Chef resources
      # ════════════════════════════════════════════════════════════════════
      class Barc016UseChefResources < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC016: Use Chef service/package resources instead of shell commands.'
        FORBIDDEN_CMDS = %w[service yum rpm].freeze

        def on_block(node)
          cb = cookbook_name
          return if BarcRulesEngine.platform_bypass?(cb) || BarcRulesEngine.rpm_bypass?(cb)
          return unless %i[execute bash script].include?(node.send_node.method_name)

          cmd = extract_command(node)
          return unless cmd && FORBIDDEN_CMDS.any? { |c| cmd =~ /\b#{c}\s+/ }
          add_offense(node.send_node)
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC017 - No system services (rules.rb driven)
      # ════════════════════════════════════════════════════════════════════
      class Barc017NoSystemServices < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC017: Service "%<service>s" is restricted. Add to rules.rb @restricted_services.'
        SERVICE_CMDS = ['chkconfig', 'stop-service', 'net stop', 'net.exe stop',
                        'set-service', 'sc delete', 'sc.exe delete', 'sc stop',
                        'sc.exe stop', 'sc configure', 'sc.exe configure'].freeze

        def on_block(node)
          # Check service/windows_service resources
          if %i[service windows_service].include?(node.send_node.method_name)
            # Check service_name attribute first, then fall back to resource name
            service = extract_service_name(node) || extract_string(node.send_node.arguments.first)
            return unless service
            return if BarcRulesEngine.service_allowed?(service, cookbook_name)
            add_offense(node.send_node, message: format(MSG, service: service))
            return
          end

          # Check command-line service manipulation
          return unless %i[execute bash script powershell_script batch].include?(node.send_node.method_name)
          cmd = extract_command(node)
          return unless cmd
          cmd_lower = cmd.downcase

          # Check if any service command is used with a system service
          SERVICE_CMDS.each do |svc_cmd|
            next unless cmd_lower.include?(svc_cmd)
            BarcRulesEngine.rules[:system_services].each do |sys_svc|
              if cmd_lower.include?(sys_svc.to_s.downcase)
                return if BarcRulesEngine.service_allowed?(sys_svc, cookbook_name)
                add_offense(node.send_node, message: format(MSG, service: sys_svc))
                return
              end
            end
          end
        end

        private

        def extract_service_name(node)
          node.each_descendant(:send) do |send_node|
            return extract_string(send_node.arguments.first) if send_node.method_name == :service_name
          end
          nil
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC019 - No find/sudo
      # ════════════════════════════════════════════════════════════════════
      class Barc019NoFindSudo < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC019: Do not use find or sudo commands.'
        FORBIDDEN_CMDS = %w[find sudo].freeze

        def on_block(node)
          return if BarcRulesEngine.platform_bypass?(cookbook_name)
          return unless %i[execute bash script].include?(node.send_node.method_name)

          cmd = extract_command(node)
          return unless cmd && FORBIDDEN_CMDS.any? { |c| cmd =~ /\b#{c}\b/ }
          add_offense(node.send_node)
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC020 - No misc forbidden commands
      # ════════════════════════════════════════════════════════════════════
      class Barc020NoMiscCommands < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC020: Do not use fuser, setfacl, wall, or smbclient.'
        FORBIDDEN_CMDS = %w[fuser setfacl wall smbclient].freeze

        def on_block(node)
          return if BarcRulesEngine.platform_bypass?(cookbook_name)
          return unless %i[execute bash script].include?(node.send_node.method_name)

          cmd = extract_command(node)
          return unless cmd && FORBIDDEN_CMDS.any? { |c| cmd =~ /\b#{c}\b/ }
          add_offense(node.send_node)
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC005a - /etc blacklist via attributes
      # ════════════════════════════════════════════════════════════════════
      class Barc005aEtcBlacklistAttributes < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC005a: Attribute references blacklisted /etc path: %<path>s'

        def on_str(node)
          return unless processed_source.file_path.include?('/attributes/')
          return if BarcRulesEngine.platform_bypass?(cookbook_name)
          path = node.str_content
          return unless path&.start_with?('/etc/')
          return if BarcRulesEngine.etc_allowed?(path, cookbook_name)
          add_offense(node, message: format(MSG, path: path))
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC018 - Review service (informational)
      # ════════════════════════════════════════════════════════════════════
      class Barc018ReviewService < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC018: Please review service "%<service>s".'
        SERVICE_CMDS = ['chkconfig', 'stop-service', 'net stop', 'net.exe stop',
                        'set-service', 'sc delete', 'sc.exe delete', 'sc stop',
                        'sc.exe stop', 'sc configure', 'sc.exe configure'].freeze

        def on_block(node)
          return if BarcRulesEngine.platform_bypass?(cookbook_name)

          # Check service/windows_service/systemd_unit resources
          if %i[service windows_service systemd_unit].include?(node.send_node.method_name)
            # Check service_name attribute first, then fall back to resource name
            service = extract_service_name(node) || extract_string(node.send_node.arguments.first)
            # Strip .service/.socket/.target/.timer suffix for systemd_unit
            service = service&.gsub(/\.(service|socket|target|timer)$/, '')
            return unless service
            return unless BarcRulesEngine.service_needs_review?(service, cookbook_name)
            add_offense(node.send_node, message: format(MSG, service: service))
            return
          end

          # Check command-line service manipulation
          return unless %i[execute bash script powershell_script batch].include?(node.send_node.method_name)
          cmd = extract_command(node)
          return unless cmd
          cmd_lower = cmd.downcase

          SERVICE_CMDS.each do |svc_cmd|
            next unless cmd_lower.include?(svc_cmd)
            # Check if command involves a restricted service that needs review
            BarcRulesEngine.rules[:restricted_services].each do |svc_pattern, _|
              if cmd_lower.include?(svc_pattern.to_s.downcase)
                next if BarcRulesEngine.rules[:system_services].any? { |s| cmd_lower.include?(s.to_s.downcase) }
                return unless BarcRulesEngine.service_needs_review?(svc_pattern, cookbook_name)
                add_offense(node.send_node, message: format(MSG, service: svc_pattern))
                return
              end
            end
          end
        end

        private

        def extract_service_name(node)
          node.each_descendant(:send) do |send_node|
            return extract_string(send_node.arguments.first) if send_node.method_name == :service_name
          end
          nil
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC021 - Exact version in dependency
      # ════════════════════════════════════════════════════════════════════
      class Barc021ExactVersionDependency < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC021: Please specify exact version (=) in dependency for %<dep>s.'

        def on_send(node)
          return unless processed_source.file_path.end_with?('metadata.rb')
          return unless node.method_name == :depends
          dep_name = extract_string(node.arguments.first)
          return unless dep_name
          return if BarcRulesEngine.cookbook_in_coverage_whitelist?(dep_name)
          # Skip library cookbooks (supports 'b_cookbook_pipeline_library')
          return if library_cookbook?(dep_name)
          version_arg = node.arguments[1]
          if version_arg
            version_str = extract_string(version_arg)
            return if version_str&.include?('=') && !version_str.include?('>') && !version_str.include?('<')
          end
          add_offense(node, message: format(MSG, dep: dep_name))
        end

        private

        # Check if dependency is a library cookbook (supports b_cookbook_pipeline_library)
        def library_cookbook?(dep_name)
          # Check Berksfile.lock if available for library platform marker
          berksfile_lock = File.join(File.dirname(processed_source.file_path), '..', '..', 'Berksfile.lock')
          return false unless File.exist?(berksfile_lock)
          content = File.read(berksfile_lock)
          # If the cookbook declares b_cookbook_pipeline_library support, it's a library
          content.include?(dep_name) && content.include?('b_cookbook_pipeline_library')
        rescue
          false
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC022 - No chef-client exit
      # ════════════════════════════════════════════════════════════════════
      class Barc022NoChefExit < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC022: Do not force chef-client exit. This stops other recipes.'

        def on_send(node)
          return if BarcRulesEngine.platform_bypass?(cookbook_name)
          if node.method_name == :raise || node.method_name == :fail
            add_offense(node)
            return
          end
          if node.method_name == :fatal! && node.receiver
            receiver_str = node.receiver.source rescue ''
            add_offense(node) if receiver_str.include?('Chef::Application')
          end
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC023 - Supported platform in metadata
      # ════════════════════════════════════════════════════════════════════
      class Barc023SupportedPlatform < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC023: Please specify supported platform using "supports" in metadata.rb.'

        def on_new_investigation
          return unless processed_source.file_path.end_with?('metadata.rb')
          has_supports = false
          processed_source.ast&.each_descendant(:send) do |n|
            has_supports = true if n.method_name == :supports
          end
          add_offense(processed_source.ast, message: MSG) unless has_supports
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC024 - Maintainer info in metadata
      # ════════════════════════════════════════════════════════════════════
      class Barc024MaintainerInfo < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC024: Please specify valid %<field>s in metadata.rb.'
        # Regex patterns matching rules.rb
        MAINTAINER_PATTERN = /\A[^0-9`!@#\$%\^&*+_=]+\z/.freeze
        EMAIL_PATTERN = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
        SOURCE_URL_PATTERN = /^(http(s)?):(\/\/)/i.freeze

        def on_new_investigation
          return unless processed_source.file_path.end_with?('metadata.rb')
          cb = cookbook_name
          maintainer_value = nil
          email_value = nil
          source_url_value = nil

          processed_source.ast&.each_descendant(:send) do |n|
            case n.method_name
            when :maintainer
              maintainer_value = extract_string(n.arguments.first)
            when :maintainer_email
              email_value = extract_string(n.arguments.first)
            when :source_url
              source_url_value = extract_string(n.arguments.first)
            end
          end

          # Check maintainer: must exist and match pattern (no special chars/numbers)
          if maintainer_value.nil? || !maintainer_value.match?(MAINTAINER_PATTERN)
            add_offense(processed_source.ast, message: format(MSG, field: 'maintainer'))
          end

          # Check maintainer_email: must exist and be valid email format
          if email_value.nil? || !email_value.match?(EMAIL_PATTERN)
            add_offense(processed_source.ast, message: format(MSG, field: 'maintainer_email'))
          end

          # Check source_url: must exist, be valid URL, and contain cookbook name
          if source_url_value.nil? || !source_url_value.match?(SOURCE_URL_PATTERN) || (cb && !source_url_value.include?(cb))
            add_offense(processed_source.ast, message: format(MSG, field: 'source_url'))
          end
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC025 - Node tags whitelist
      # ════════════════════════════════════════════════════════════════════
      class Barc025UnauthorizedTags < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC025: Unauthorized usage of node tag "%<tag>s".'

        def on_send(node)
          return if BarcRulesEngine.platform_bypass?(cookbook_name)

          # Handle both :tag (singular) and :tags (plural)
          case node.method_name
          when :tag
            # Single tag: tag 'barc'
            tag = extract_string(node.arguments.first)
            return unless tag
            return if BarcRulesEngine.tag_allowed?(tag, cookbook_name)
            add_offense(node, message: format(MSG, tag: tag))
          when :tags
            # Multiple tags: tags %w[barc unix role] or tags ['barc', 'unix']
            node.arguments.each do |arg|
              if arg.array_type?
                arg.each_child_node do |child|
                  tag = extract_string(child)
                  next unless tag
                  next if BarcRulesEngine.tag_allowed?(tag, cookbook_name)
                  add_offense(node, message: format(MSG, tag: tag))
                end
              else
                tag = extract_string(arg)
                next unless tag
                next if BarcRulesEngine.tag_allowed?(tag, cookbook_name)
                add_offense(node, message: format(MSG, tag: tag))
              end
            end
          end
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC026 - No node.save
      # ════════════════════════════════════════════════════════════════════
      class Barc026NoNodeSave < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC026: Do not use node.save to save partial node data mid-run.'

        def on_send(node)
          return if BarcRulesEngine.platform_bypass?(cookbook_name)
          return unless node.method_name == :save
          receiver = node.receiver
          return unless receiver
          receiver_name = receiver.source rescue ''
          add_offense(node) if receiver_name == 'node'
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC027 - Middleware packages
      # ════════════════════════════════════════════════════════════════════
      class Barc027MiddlewarePackages < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC027: Only approved cookbooks can deploy Middleware packages: %<pkg>s'

        def on_new_investigation
          return if BarcRulesEngine.mw_cookbook_allowed?(cookbook_name)
          @mw_var_names = collect_mw_variable_names
        end

        def on_block(node)
          return unless %i[package yum_package].include?(node.send_node.method_name)
          return if BarcRulesEngine.mw_cookbook_allowed?(cookbook_name)

          # Check direct package name
          pkg_name = extract_string(node.send_node.arguments.first)
          if pkg_name && BarcRulesEngine.mw_package?(pkg_name)
            add_offense(node.send_node, message: format(MSG, pkg: pkg_name))
            return
          end

          # Check package_name attribute
          pkg_attr = extract_package_name_attr(node)
          if pkg_attr && BarcRulesEngine.mw_package?(pkg_attr)
            add_offense(node.send_node, message: format(MSG, pkg: pkg_attr))
            return
          end

          # Check if using a variable that holds MW package
          check_variable_usage(node)
        end

        # Also check 1-liner resources (no block)
        def on_send(node)
          return unless node.method_name == :package || node.method_name == :yum_package
          return if node.parent&.block_type?
          return if BarcRulesEngine.mw_cookbook_allowed?(cookbook_name)

          pkg_name = extract_string(node.arguments.first)
          return unless pkg_name && BarcRulesEngine.mw_package?(pkg_name)
          add_offense(node, message: format(MSG, pkg: pkg_name))
        end

        private

        def collect_mw_variable_names
          var_names = Set.new
          return var_names unless processed_source.ast

          # Find variable assignments that contain MW package prefixes
          processed_source.ast.each_descendant(:lvasgn, :ivasgn, :casgn) do |asgn|
            var_name = asgn.children.first.to_s
            # Check if RHS contains an MW package prefix
            asgn.each_descendant(:str) do |str_node|
              if BarcRulesEngine.mw_package?(str_node.str_content)
                var_names << var_name
              end
            end
          end
          var_names
        end

        def check_variable_usage(node)
          return unless @mw_var_names&.any?
          # Check if resource uses a tracked variable
          node.each_descendant(:lvar, :ivar) do |var_node|
            var_name = var_node.children.first.to_s
            if @mw_var_names.include?(var_name)
              add_offense(node.send_node, message: format(MSG, pkg: "variable #{var_name}"))
              return
            end
          end
        end

        def extract_package_name_attr(node)
          node.each_descendant(:send) do |send_node|
            return extract_string(send_node.arguments.first) if send_node.method_name == :package_name
          end
          nil
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC028 - Restricted cookbook dependencies
      # ════════════════════════════════════════════════════════════════════
      class Barc028RestrictedCookbookDeps < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC028: Only whitelisted cookbooks can depend on %<dep>s.'

        def on_send(node)
          return unless processed_source.file_path.end_with?('metadata.rb')
          return unless node.method_name == :depends
          dep_name = extract_string(node.arguments.first)
          return unless dep_name
          return if BarcRulesEngine.restricted_cookbook_allowed?(dep_name, cookbook_name)
          add_offense(node, message: format(MSG, dep: dep_name))
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC029 - Community cookbook access
      # ════════════════════════════════════════════════════════════════════
      class Barc029CommunityCookbooks < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC029: Unauthorized access to community cookbook %<dep>s.'

        def on_send(node)
          return unless processed_source.file_path.end_with?('metadata.rb')
          return unless node.method_name == :depends
          dep_name = extract_string(node.arguments.first)
          return unless dep_name
          return unless BarcRulesEngine.cookbook_blocked?(dep_name, cookbook_name)
          add_offense(node, message: format(MSG, dep: dep_name))
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC030 - Deprecated cookbooks
      # ════════════════════════════════════════════════════════════════════
      class Barc030DeprecatedCookbooks < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC030: Cookbook depends on deprecated cookbook %<dep>s.'

        def on_send(node)
          return unless processed_source.file_path.end_with?('metadata.rb')
          return unless node.method_name == :depends
          dep_name = extract_string(node.arguments.first)
          return unless dep_name
          return unless BarcRulesEngine.cookbook_deprecated?(dep_name)
          add_offense(node, message: format(MSG, dep: dep_name))
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC031 - Controlled packages
      # ════════════════════════════════════════════════════════════════════
      class Barc031ControlledPackages < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC031: Package %<pkg>s is controlled.'

        def on_new_investigation
          @controlled_var_names = collect_controlled_variable_names
        end

        def on_block(node)
          return unless %i[package yum_package].include?(node.send_node.method_name)

          # Check direct package name
          pkg_name = extract_string(node.send_node.arguments.first)
          if pkg_name && !BarcRulesEngine.controlled_package_allowed?(pkg_name, cookbook_name)
            add_offense(node.send_node, message: format(MSG, pkg: pkg_name))
            return
          end

          # Check package_name attribute
          pkg_attr = extract_package_name_attr(node)
          if pkg_attr && !BarcRulesEngine.controlled_package_allowed?(pkg_attr, cookbook_name)
            add_offense(node.send_node, message: format(MSG, pkg: pkg_attr))
            return
          end

          # Check if using a variable that holds controlled package
          check_variable_usage(node)
        end

        # Also check 1-liner resources (no block)
        def on_send(node)
          return unless node.method_name == :package || node.method_name == :yum_package
          return if node.parent&.block_type?

          pkg_name = extract_string(node.arguments.first)
          return unless pkg_name
          return if BarcRulesEngine.controlled_package_allowed?(pkg_name, cookbook_name)
          add_offense(node, message: format(MSG, pkg: pkg_name))
        end

        private

        def collect_controlled_variable_names
          var_map = {}
          return var_map unless processed_source.ast

          # Find variable assignments that match controlled package patterns
          processed_source.ast.each_descendant(:lvasgn, :ivasgn, :casgn) do |asgn|
            var_name = asgn.children.first.to_s
            # Check if RHS contains a controlled package prefix
            asgn.each_descendant(:str) do |str_node|
              pkg_str = str_node.str_content
              BarcRulesEngine.rules[:controlled_packages].each do |pattern, _|
                if pkg_str.start_with?(pattern)
                  var_map[var_name] = pkg_str
                end
              end
            end
          end
          var_map
        end

        def check_variable_usage(node)
          return unless @controlled_var_names&.any?
          # Check if resource uses a tracked variable
          node.each_descendant(:lvar, :ivar) do |var_node|
            var_name = var_node.children.first.to_s
            if @controlled_var_names.key?(var_name)
              pkg = @controlled_var_names[var_name]
              unless BarcRulesEngine.controlled_package_allowed?(pkg, cookbook_name)
                add_offense(node.send_node, message: format(MSG, pkg: pkg))
                return
              end
            end
          end
        end

        def extract_package_name_attr(node)
          node.each_descendant(:send) do |send_node|
            return extract_string(send_node.arguments.first) if send_node.method_name == :package_name
          end
          nil
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC032 - Cookbook version flags
      # ════════════════════════════════════════════════════════════════════
      class Barc032CookbookVersionFlags < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC032: Cookbook depends on %<dep>s version that is no longer supported.'

        def on_send(node)
          return unless processed_source.file_path.end_with?('metadata.rb')
          return unless node.method_name == :depends
          dep_name = extract_string(node.arguments.first)
          return unless dep_name
          version_arg = node.arguments[1]
          version = version_arg ? extract_string(version_arg)&.gsub(/[^\d.]/, '') : nil
          return if BarcRulesEngine.cookbook_version_ok?(dep_name, version)
          add_offense(node, message: format(MSG, dep: dep_name))
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC033 - Allowed pins only
      # ════════════════════════════════════════════════════════════════════
      class Barc033AllowedPinsOnly < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC033: Cookbook must depend on %<dep>s with allowed pin only.'

        def on_send(node)
          return unless processed_source.file_path.end_with?('metadata.rb')
          return unless node.method_name == :depends
          cb = cookbook_name
          return unless BarcRulesEngine.rules[:whitelist_cookbook_allowed_pins_only].include?(cb)
          dep_name = extract_string(node.arguments.first)
          return unless dep_name
          allowed_pins = BarcRulesEngine.rules[:cookbook_allowed_pins_only][dep_name]
          return unless allowed_pins
          version_arg = node.arguments[1]
          return unless version_arg
          version_str = extract_string(version_arg)
          return if allowed_pins.any? { |pin| version_str&.start_with?(pin) }
          add_offense(node, message: format(MSG, dep: dep_name))
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC034 - Restricted attributes in roles
      # ════════════════════════════════════════════════════════════════════
      class Barc034RestrictedAttributesRoles < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC034: Restricted attribute "%<attr>s" found in role file.'

        def on_new_investigation
          file_path = processed_source.file_path
          # Check both .rb and .json role files (matching rules.rb behavior)
          return unless file_path.include?('/roles/')
          return unless file_path.end_with?('.rb') || file_path.end_with?('.json')

          content = processed_source.raw_source
          BarcRulesEngine.rules[:restricted_attributes].each do |attr, cookbooks|
            next if cookbooks.include?(cookbook_name)
            if content.include?(attr)
              if processed_source.ast
                add_offense(processed_source.ast, message: format(MSG, attr: attr))
              else
                # For JSON files, report on first line
                add_global_offense(format(MSG, attr: attr))
              end
            end
          end
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC035 - Restricted attributes (recipes/attributes/libraries)
      # ════════════════════════════════════════════════════════════════════
      class Barc035RestrictedAttributes < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC035: Restricted attribute "%<attr>s" usage.'

        def on_str(node)
          return if processed_source.file_path.include?('metadata')
          return if BarcRulesEngine.platform_bypass?(cookbook_name)
          content = node.str_content
          BarcRulesEngine.rules[:restricted_attributes].each do |attr, cookbooks|
            next if cookbooks.include?(cookbook_name)
            add_offense(node, message: format(MSG, attr: attr)) if content&.include?(attr)
          end
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # BARC036 - Java version hard pin
      # ════════════════════════════════════════════════════════════════════
      class Barc036JavaVersionPin < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'BARC036: Java version hard pin (update_number) requires DWB/ORAC approval.'

        def on_block(node)
          return unless node.send_node.method_name == :b_iac_cc_java_package
          has_update_number = false
          node.each_descendant(:send) do |send_node|
            has_update_number = true if send_node.method_name == :update_number
          end
          return unless has_update_number
          return if BarcRulesEngine.java_pin_allowed?(cookbook_name)
          add_offense(node.send_node)
        end
      end

      # ════════════════════════════════════════════════════════════════════
      # AttributeRestriction - Reads @restricted_attributes from rules.rb
      # ════════════════════════════════════════════════════════════════════
      class AttributeRestriction < RuboCop::Cop::Base
        include CookbookHelper
        MSG = 'Attribute "%<attr>s" is restricted. Add to rules.rb @restricted_attributes.'

        def on_send(node)
          return unless %i[default override normal].include?(node.method_name)
          attr = extract_string(node.arguments.first)
          return unless attr
          return if BarcRulesEngine.attribute_allowed?(attr, cookbook_name)
          add_offense(node, message: format(MSG, attr: attr))
        end
      end
    end
  end
end
