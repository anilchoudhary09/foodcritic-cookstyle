# InSpec test for compliant-cookbook
#
# Verify that the cookbook converges successfully and meets expected state

# Test that Chef 19 converged successfully
describe command('chef-client --version') do
  its('stdout') { should match(/Chef Infra Client: 19/) }
  its('exit_status') { should eq 0 }
end

# Basic system tests
describe os.family do
  it { should be_in ['redhat', 'debian'] }
end

# Verify compliant cookbook behavior
# This cookbook should be clean and not create problematic resources

# Ensure no local users were created (BARC001 compliant)
describe passwd.where { user =~ /^app_/ } do
  its('users') { should be_empty }
end

# Ensure /etc/passwd was not modified (BARC005 compliant)
describe file('/etc/passwd') do
  its('mode') { should cmp '0644' }
  its('owner') { should eq 'root' }
end

# Chef 19 specific checks - ensure no deprecated features are used
describe command('cat /var/chef/cache/chef-stacktrace.out 2>/dev/null || echo "No errors"') do
  its('stdout') { should_not match(/DEPRECATION/) }
end
