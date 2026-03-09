# frozen_string_literal: true

module RuboCop
  module Cop
    module Barclays
      # BARC016: Use Chef resources instead of commands
      #
      # Chef provides native resources that are more idempotent, testable,
      # and maintainable than raw shell commands. Always prefer Chef
      # resources over execute/bash resources when possible.
      #
      # @example
      #   # bad - uses command instead of Chef resource
      #   execute 'install_package' do
      #     command 'yum install -y nginx'
      #   end
      #
      #   # good - uses Chef resource
      #   package 'nginx' do
      #     action :install
      #   end
      #
      #   # bad - creates user with command
      #   execute 'create_user' do
      #     command 'useradd myuser'
      #   end
      #
      #   # good - uses Chef resource
      #   user 'myuser' do
      #     action :create
      #   end
      #
      class Barc016UseChefResources < Base
        MSG = 'BARC016: Use Chef %<resource>s resource instead of %<command>s command. ' \
              'Chef resources are more idempotent and maintainable.'

        # Commands that have Chef resource equivalents
        COMMAND_TO_RESOURCE_MAP = {
          /\byum\s+(install|remove|update)\b/ => 'package',
          /\bapt(-get)?\s+(install|remove|update)\b/ => 'package',
          /\bdnf\s+(install|remove|update)\b/ => 'package',
          /\brpm\s+-[iUe]\b/ => 'package',
          /\bdpkg\s+-[ir]\b/ => 'package',
          /\bsystemctl\s+(start|stop|restart|enable|disable)\b/ => 'service',
          /\bservice\s+\S+\s+(start|stop|restart)\b/ => 'service',
          /\b(chkconfig|update-rc\.d)\b/ => 'service (enable/disable)',
          /\buseradd\b/ => 'user',
          /\busermod\b/ => 'user',
          /\buserdel\b/ => 'user',
          /\bgroupadd\b/ => 'group',
          /\bgroupmod\b/ => 'group',
          /\bgroupdel\b/ => 'group',
          /\bmkdir\s+-p\b/ => 'directory',
          /\bchown\b/ => 'file/directory (owner property)',
          /\bchmod\b/ => 'file/directory (mode property)',
          /\bln\s+-s\b/ => 'link',
          /\bcurl\s+.*-[oO]\b/ => 'remote_file',
          /\bwget\s+.*-O\b/ => 'remote_file',
          /\bcp\s+/ => 'cookbook_file or template',
          /\bcat\s+.*>\s*\S+/ => 'file (content property)',
          /\becho\s+.*>\s*\S+/ => 'file (content property)',
          /\bcrontab\b/ => 'cron',
          /\bmount\b/ => 'mount',
          /\bunzip\b/ => 'archive_file',
          /\btar\s+.*x/ => 'archive_file',
        }.freeze

        def on_block(node)
          return unless execute_resource?(node) || bash_resource?(node)

          check_commands_for_chef_alternatives(node)
        end

        private

        def check_commands_for_chef_alternatives(node)
          find_command_strings(node).each do |cmd_node, cmd|
            COMMAND_TO_RESOURCE_MAP.each do |pattern, resource|
              if cmd =~ pattern
                matched_command = Regexp.last_match(0)
                add_offense(
                  cmd_node,
                  message: format(MSG, resource: resource, command: matched_command)
                )
                break
              end
            end
          end
        end
      end
    end
  end
end
