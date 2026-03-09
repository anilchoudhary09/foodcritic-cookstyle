# frozen_string_literal: true

#
# Cookbook:: sample-app-cookbook
# Recipe:: default
#
# Default recipe - include compliant patterns only
#

# Include only the compliant recipe in production
include_recipe 'sample-app-cookbook::compliant'

# NOTE: The violations recipe should NEVER be included in production
# It exists only for testing the Cookstyle BARC rules
# include_recipe 'sample-app-cookbook::violations'  # DO NOT UNCOMMENT
