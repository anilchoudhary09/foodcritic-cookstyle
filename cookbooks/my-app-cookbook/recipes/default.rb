# frozen_string_literal: true

#
# Cookbook:: my-app-cookbook
# Recipe:: default
#
# Default recipe - includes compliant setup only
#

include_recipe 'my-app-cookbook::compliant'

# NOTE: For POC demo, run cookstyle against violations.rb to see
# the BARC rules in action:
#   cookstyle recipes/violations.rb
