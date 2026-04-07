# InSpec test for my-app-cookbook
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

# Verify the cookbook created expected resources (customize based on your cookbook)
describe file('/etc/myapp') do
  it { should_not exist }  # Adjust based on actual cookbook behavior
end

# Chef 19 specific checks - ensure no deprecated features are used
describe command('cat /var/chef/cache/chef-stacktrace.out 2>/dev/null || echo "No errors"') do
  its('stdout') { should_not match(/DEPRECATION/) }
end

# Check that the Chef run was successful
describe file('/var/chef/cache/chef-client-running.pid') do
  it { should_not exist }  # Should be cleaned up after successful run
end
