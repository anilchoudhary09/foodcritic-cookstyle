#
# Cookbook:: b-foodcritic-cookstyle
# Recipe:: bad_practices
#
# This recipe INTENTIONALLY demonstrates BAD practices that Cookstyle will catch
# Run `cookstyle recipes/bad_practices.rb` to see all the violations
#

# =============================================================================
# BAD PRACTICE 1: Using deprecated 'attribute' method
# Chef/Deprecations/Attribute - Use node[] instead
# =============================================================================
# Uncomment to see violation:
# attribute_value = node.attribute['some_attribute']

# =============================================================================
# BAD PRACTICE 2: Using old-style notifications
# Chef/Modernize/NotifiesActionSymbol
# =============================================================================
execute 'bad-notify-example' do
  command 'echo "test"'
  notifies :restart, 'service[nginx]'  # This is correct, but let's show old style below
end

# =============================================================================
# BAD PRACTICE 3: Using string file modes instead of octal
# Chef/Correctness/InvalidPlatformMetadata
# =============================================================================
file '/tmp/bad_permissions.txt' do
  content 'test content'
  mode 644  # BAD: Should be '0644' as a string
end

# =============================================================================
# BAD PRACTICE 4: Using deprecated 'run_context' patterns
# =============================================================================
ruby_block 'unnecessary-complexity' do
  block do
    # This pattern is often flagged for being overly complex
    Chef::Log.info("This could be simpler")
  end
end

# =============================================================================
# BAD PRACTICE 5: Double-quoted strings without interpolation
# Style/StringLiterals - Use single quotes for strings without interpolation
# =============================================================================
package "vim" do
  action :install
end

# =============================================================================
# BAD PRACTICE 6: Unnecessary 'return' in blocks
# Style/RedundantReturn
# =============================================================================
ruby_block 'redundant-return' do
  block do
    value = 42
    return value  # Redundant return
  end
end

# =============================================================================
# BAD PRACTICE 7: Using 'unless' with 'else'
# Style/UnlessElse
# =============================================================================
ruby_block 'unless-else-example' do
  block do
    unless false
      Chef::Log.info("True case")
    else
      Chef::Log.info("False case")
    end
  end
end

# =============================================================================
# BAD PRACTICE 8: Trailing whitespace and missing newline
# Layout/TrailingWhitespace, Layout/TrailingEmptyLines
# =============================================================================
template '/tmp/trailing_space.txt' do
  source 'test.erb'
  action :create
end

# =============================================================================
# BAD PRACTICE 9: Long lines exceeding 120 characters
# Layout/LineLength
# =============================================================================
log 'very-long-message' do
  message "This is a very long log message that exceeds the recommended line length of 120 characters and should be broken up into multiple lines for better readability"
  level :info
end

# =============================================================================
# BAD PRACTICE 10: Mixed indentation (spaces vs tabs)
# Layout/IndentationStyle
# =============================================================================
directory '/tmp/mixed_indent' do
	owner 'root'  # This line uses a tab
  group 'root'  # This line uses spaces
  mode '0755'
end

# =============================================================================
# BAD PRACTICE 11: Missing frozen_string_literal comment
# Style/FrozenStringLiteralComment (in some configurations)
# =============================================================================

# =============================================================================
# BAD PRACTICE 12: Using 'and' or 'or' instead of && or ||
# Style/AndOr
# =============================================================================
ruby_block 'and-or-example' do
  block do
    value = true
    if value and true
      Chef::Log.info("Using 'and' instead of '&&'")
    end
  end
end

# =============================================================================
# BAD PRACTICE 13: Parentheses in method calls where not needed
# Style/MethodCallWithoutArgsParentheses
# =============================================================================
ruby_block 'unnecessary-parens' do
  block do
    current_time = Time.now()  # Unnecessary parentheses
  end
end

# =============================================================================
# BAD PRACTICE 14: Not using safe navigation operator
# Style/SafeNavigation
# =============================================================================
ruby_block 'no-safe-nav' do
  block do
    obj = nil
    result = obj && obj.to_s  # Could use obj&.to_s
  end
end
