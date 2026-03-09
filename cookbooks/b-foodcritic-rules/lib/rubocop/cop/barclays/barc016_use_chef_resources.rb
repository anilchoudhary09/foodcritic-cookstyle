# frozen_string_literal: true

module RuboCop
  module Cop
    module Barclays
      # BARC016: Use Chef resources instead of commands
      #
      # @example
      #   # bad
      #   execute 'install_nginx' do
      #     command 'yum install -y nginx'
      #   end
      #
      #   # good
      #   package 'nginx' do
      #     action :install
      #   end
      #
      class Barc016UseChefResources < Base
        MSG = 'BARC016: Use Chef %<resource>s resource instead of %<command>s command.'

        COMMAND_TO_RESOURCE = {
          /\byum\s+(install|remove|update)\b/ => 'package',
          /\bapt(-get)?\s+(install|remove)\b/ => 'package',
          /\bdnf\s+(install|remove)\b/ => 'package',
          /\bsystemctl\s+(start|stop|restart|enable|disable)\b/ => 'service',
          /\bservice\s+\S+\s+(start|stop|restart)\b/ => 'service',
          /\buseradd\b/ => 'user',
          /\bgroupadd\b/ => 'group',
          /\bmkdir\s+-p\b/ => 'directory',
          /\bchown\b/ => 'file/directory (owner property)',
          /\bchmod\b/ => 'file/directory (mode property)',
          /\bln\s+-s\b/ => 'link',
          /\bcurl\s+.*-[oO]\b/ => 'remote_file',
          /\bwget\s+.*-O\b/ => 'remote_file',
          /\bcrontab\b/ => 'cron',
        }.freeze

        def on_block(node)
          return unless execute_resource?(node) || bash_resource?(node)

          find_command_strings(node).each do |cmd_node, cmd|
            COMMAND_TO_RESOURCE.each do |pattern, resource|
              if cmd =~ pattern
                add_offense(cmd_node, message: format(MSG, resource: resource, command: Regexp.last_match(0)))
                break
              end
            end
          end
        end
      end
    end
  end
end
