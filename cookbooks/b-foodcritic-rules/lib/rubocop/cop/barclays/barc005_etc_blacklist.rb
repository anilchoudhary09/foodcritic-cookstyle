# frozen_string_literal: true

module RuboCop
  module Cop
    module Barclays
      # BARC005: Enforces /etc directory blacklist
      #
      # @example
      #   # bad
      #   file '/etc/passwd' do
      #     content 'root:x:0:0:...'
      #   end
      #
      class Barc005EtcBlacklist < Base
        MSG = 'BARC005: Modification of %<path>s is not allowed. ' \
              'This is a protected system configuration file.'

        BLACKLISTED_PATHS = %w[
          /etc/passwd /etc/shadow /etc/group /etc/gshadow /etc/sudoers
          /etc/ssh/sshd_config /etc/pam.d/ /etc/security/ /etc/selinux/
          /etc/hosts.allow /etc/hosts.deny /etc/crontab /etc/fstab
          /etc/resolv.conf /etc/nsswitch.conf /etc/krb5.conf
          /etc/yum.repos.d/ /etc/apt/sources.list /etc/audit/
          /etc/sysctl.conf /etc/sysctl.d/ /etc/firewalld/ /etc/iptables/
        ].freeze

        def on_block(node)
          return if cookbook_whitelisted?('platform_cookbooks')

          if (path = file_resource?(node))
            check_blacklisted_path(node, path)
          end

          if (path = directory_resource?(node))
            check_blacklisted_path(node, path)
          end
        end

        private

        def check_blacklisted_path(node, path)
          return unless path.start_with?('/etc/')
          return if etc_path_whitelisted?(path)

          BLACKLISTED_PATHS.each do |blacklisted|
            if path.start_with?(blacklisted) || path == blacklisted.chomp('/')
              add_offense(node.send_node, message: format(MSG, path: path))
              break
            end
          end
        end

        def etc_path_whitelisted?(path)
          name = cookbook_name
          return false unless name
          BCookstyleRules.etc_path_whitelisted?(path, name)
        end
      end
    end
  end
end
