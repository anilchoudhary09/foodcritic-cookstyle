#
# Cookbook:: b-foodcritic-cookstyle
# Recipe:: default
#
# Copyright:: 2026, The Authors, All Rights Reserved.
#
# This is the default recipe for the b-foodcritic-cookstyle cookbook
# It includes the showcase recipes to demonstrate Cookstyle capabilities
#

# Log that we're running the Cookstyle demo cookbook
log 'cookstyle-demo-start' do
  message 'Running Cookstyle demonstration cookbook'
  level :info
end

# Include the cookstyle showcase recipe
include_recipe 'b-foodcritic-cookstyle::cookstyle_showcase'

# Note: Don't include bad_practices in production - it's for demonstration only!
# include_recipe 'b-foodcritic-cookstyle::bad_practices'

# Include custom rules demo
include_recipe 'b-foodcritic-cookstyle::custom_rules_demo'

# Final log message
log 'cookstyle-demo-end' do
  message 'Cookstyle demonstration cookbook completed'
  level :info
end
