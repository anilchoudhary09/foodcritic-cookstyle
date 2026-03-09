# frozen_string_literal: true

# Load all custom Barclays cops
require_relative 'barclays/base'
require_relative 'barclays/barc001_no_local_users'
require_relative 'barclays/barc002_no_local_groups'
require_relative 'barclays/barc003_no_root_ssh'
require_relative 'barclays/barc005_etc_blacklist'
require_relative 'barclays/barc006_no_reboot'
require_relative 'barclays/barc007_no_selinux'
require_relative 'barclays/barc008_no_kill_process'
require_relative 'barclays/barc009_no_firewall'
require_relative 'barclays/barc011_no_remove_files'
require_relative 'barclays/barc016_use_chef_resources'
require_relative 'barclays/barc017_no_system_services'
require_relative 'barclays/barc019_no_find_sudo'

# Load whitelist configuration
require 'yaml'

module BCookstyleRules
  # Load whitelists from YAML files
  def self.load_whitelist(name)
    file_path = File.expand_path("../../../data/#{name}.yml", __FILE__)
    return {} unless File.exist?(file_path)

    YAML.safe_load(File.read(file_path), permitted_classes: [Symbol]) || {}
  end

  # Cache loaded whitelists
  @whitelists = {}

  def self.whitelist(name)
    @whitelists[name] ||= load_whitelist(name)
  end

  # Check if cookbook is whitelisted
  def self.cookbook_whitelisted?(cookbook_name, whitelist_name)
    whitelist = whitelist(whitelist_name)
    whitelist['cookbooks']&.include?(cookbook_name) || false
  end

  # Check if service is whitelisted for cookbook
  def self.service_whitelisted?(service_name, cookbook_name)
    whitelist = whitelist('services')
    return true if whitelist['global']&.include?(service_name)

    cookbook_services = whitelist['per_cookbook']&.dig(cookbook_name)
    cookbook_services&.include?(service_name) || false
  end

  # Check if /etc path is whitelisted for cookbook
  def self.etc_path_whitelisted?(path, cookbook_name)
    whitelist = whitelist('etc_whitelist')
    return true if whitelist['global']&.any? { |p| path.start_with?(p) }

    cookbook_paths = whitelist['per_cookbook']&.dig(cookbook_name)
    cookbook_paths&.any? { |p| path.start_with?(p) } || false
  end
end
