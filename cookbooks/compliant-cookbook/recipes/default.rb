# frozen_string_literal: true

#
# Cookbook:: compliant-cookbook
# Recipe:: default
#
# ✅ This cookbook is fully compliant with all Barclays security policies
# and Chef best practices. Use this as a reference implementation.
#

# Include application setup
include_recipe 'compliant-cookbook::application'
include_recipe 'compliant-cookbook::monitoring'
