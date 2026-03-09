# frozen_string_literal: true

module RuboCop
  module Cop
    module Barclays
      # BARC017: Prohibits manipulation of restricted system services
      #
      # Certain system services are critical for security, monitoring,
      # and compliance. These services should only be managed by
      # approved platform/infrastructure cookbooks.
      #
      # @example
      #   # bad - stops security monitoring agent
      #   service 'falcon-sensor' do
      #     action :stop
      #   end
      #
      #   # bad - disables audit daemon
      #   service 'auditd' do
      #     action :disable
      #   end
      #
      class Barc017NoSystemServices < Base
        MSG = 'BARC017: Management of system service "%<service>s" is restricted. ' \
              'Only approved platform cookbooks may manage this service.'

        # System services that are restricted
        RESTRICTED_SERVICES = %w[
          auditd
          rsyslog
          syslog
          chronyd
          ntpd
          sssd
          sshd
          firewalld
          iptables
          polkitd
          systemd-journald
          falcon-sensor
          crowdstrike
          qualys
          tanium
          splunk
          splunkforwarder
          puppet
          chef-client
          node_exporter
          prometheus
          nagios
          zabbix-agent
          ossec
          aide
          selinux
        ].freeze

        def on_block(node)
          return if cookbook_whitelisted?('platform_cookbooks')

          # Check service resource
          if (service_name = service_resource?(node))
            check_restricted_service(node, service_name)
          end

          # Check execute/bash for service commands
          if execute_resource?(node) || bash_resource?(node)
            check_commands_for_services(node)
          end
        end

        private

        def check_restricted_service(node, service_name)
          normalized = service_name.downcase.strip
          return unless RESTRICTED_SERVICES.any? { |s| normalized.include?(s) }
          return if service_whitelisted?(service_name)

          add_offense(
            node.send_node,
            message: format(MSG, service: service_name)
          )
        end

        def service_whitelisted?(service_name)
          name = cookbook_name
          return false unless name

          BCookstyleRules.service_whitelisted?(service_name, name)
        end

        def check_commands_for_services(node)
          find_command_strings(node).each do |cmd_node, cmd|
            # Check for systemctl commands
            if cmd =~ /systemctl\s+(start|stop|restart|enable|disable)\s+(\S+)/
              service = Regexp.last_match(2)
              check_restricted_service_cmd(cmd_node, service)
            end
            # Check for service command
            if cmd =~ /service\s+(\S+)\s+(start|stop|restart)/
              service = Regexp.last_match(1)
              check_restricted_service_cmd(cmd_node, service)
            end
          end
        end

        def check_restricted_service_cmd(node, service_name)
          normalized = service_name.downcase.strip
          return unless RESTRICTED_SERVICES.any? { |s| normalized.include?(s) }
          return if service_whitelisted?(service_name)

          add_offense(node, message: format(MSG, service: service_name))
        end
      end
    end
  end
end
