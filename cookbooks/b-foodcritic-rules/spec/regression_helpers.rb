require 'fileutils'
require 'pathname'

def lint_regression_violator
  working_dir = Pathname.new('tmp/regression-violator')
  FileUtils.mkdir_p(working_dir)
  pinned_cookbooks('spec/regression/cookbooks-violator.txt').each do |cbk|
    clone_cookbook(working_dir, cbk)
  end
  lint_cookbooks(working_dir)
end

def lint_regression_repo
  working_dir = Pathname.new('tmp/regression-repo')
  FileUtils.mkdir_p(working_dir)
  pinned_cookbooks('spec/regression/cookbooks-regression.txt').each do |cbk|
    clone_cookbook(working_dir, cbk)
  end
  lint_array = []
  pinned_cookbooks('spec/regression/cookbooks-regression.txt').each do |cbk|
    lint_array.push(lint_cookbooks("#{working_dir}/#{cbk[:ckbk_name]}/cookbooks"))
  end
  lint_array.join("\n")
end

def pinned_cookbooks(filename)
  File.read(filename).lines.map do |line|
    full_url, ref, ckbk_name = line.strip.split('|')
    { full_url: full_url, ref: ref, ckbk_name: ckbk_name }
  end
end

def clone_cookbook(clone_path, cbk)
  target_path = "#{clone_path}/#{cbk[:ckbk_name]}"
  unless Dir.exist?(target_path)
    `git clone -q #{cbk[:full_url]} #{target_path}`
    fail "Unable to clone #{cbk[:full_url]}" unless $CHILD_STATUS.success?
  end
  `cd #{target_path} && git checkout -q #{cbk[:ref]}`
  fail "Unable to checkout revision #{cbk[:ref]} for #{cbk[:name]}" unless $CHILD_STATUS.success?
end

def lint_cookbooks(cookbook_path)
  rules = "#{File.expand_path('../../', __FILE__)}/rules.rb"
  result = `cd #{cookbook_path} && foodcritic -t barc --no-progress -I #{rules} .`
  result.chomp.split("\n").sort.join("\n")
end
