# frozen_string_literal: true

module RuboCop
  module Cop
    module Barclays
      # BARC005: Enforces /etc directory blacklist
      #
      # Certain files and directories under /etc are critical system
      # configuration that should not be modified by application cookbooks.
      # Platform/infrastructure cookbooks may have whitelist exceptions.
      #
      # @example
      #   # bad - modifies /etc/passwd
      #   file '/etc/passwd' do
      #     content 'root:x:0:0:...'
      #   end
      #
      #   # bad - modifies /etc/shadow
      #   template '/etc/shadow' do
      #     source 'shadow.erb'
      #   end
      #
      class Barc005EtcBlacklist < Base
        MSG = 'BARC005: Modification of %<path>s is not allowed. ' \
              'This is a protected system configuration file.'

        # Critical system files that should never be modified
        BLACKLISTED_PATHS = %w[
          /etc/passwd
          /etc/shadow
          /etc/group
          /etc/gshadow
          /etc/sudoers
          /etc/ssh/sshd_config
          /etc/pam.d/
          /etc/security/
          /etc/selinux/
          /etc/hosts.allow
          /etc/hosts.deny
          /etc/crontab
          /etc/inittab
          /etc/fstab
          /etc/mtab
          /etc/resolv.conf
          /etc/nsswitch.conf
          /etc/krb5.conf
          /etc/krb5.keytab
          /etc/yum.repos.d/
          /etc/apt/sources.list
          /etc/audit/
          /etc/modprobe.d/
          /etc/sysctl.conf
          /etc/sysctl.d/
          /etc/firewalld/
          /etc/iptables/
        ].freeze

        def on_block(node)
          return if cookbook_whitelisted?('platform_cookbooks')

          # Check file resources
          if (path = file_resource?(node))
            check_blacklisted_path(node, path)
          end

          # Check directory resources
          if (path = directory_resource?(node))
            check_blacklisted_path(node, path)
          end
        end

        def on_str(node)
          return if cookbook_whitelisted?('platform_cookbooks')
          return unless inside_file_operation?(node)

          check_blacklisted_path(node, node.value)
        end

        private

        def check_blacklisted_path(node, path)
          return unless path.start_with?('/etc/')
          return if etc_path_whitelisted?(path)

          BLACKLISTED_PATHS.each do |blacklisted|
            if path.start_with?(blacklisted) || path == blacklisted.chomp('/')
              add_offense(
                node.is_a?(RuboCop::AST::BlockNode) ? node.send_node : node,
                message: format(MSG, path: path)
              )
              break
            end
          end
        end

        def etc_path_whitelisted?(path)
          name = cookbook_name
          return false unless name

          BCookstyleRules.etc_path_whitelisted?(path, name)
        end

        def inside_file_operation?(node)
          node.each_ancestor(:block).any? do |ancestor|
            file_resource?(ancestor) || directory_resource?(ancestor)
          end
        end
      end
    end
  end
end
