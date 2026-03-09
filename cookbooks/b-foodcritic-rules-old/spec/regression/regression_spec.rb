require 'English'
require_relative '../regression_helpers'

describe 'regression test with b-foodcritic-violator' do
  let(:expected_lint_output) do
    File.read('spec/regression/expected-output-violator.txt').split("\n").sort.join("\n")
  end
  let(:actual_lint_output) do
    lint_regression_violator
  end
  it 'should result in the match with expected output' do
#    File.write('spec/regression/expected-output-violator.txt', actual_lint_output.split("\n").sort.join("\n"))
    expect(actual_lint_output.split("\n").sort.join("\n")).to eq(expected_lint_output)
  end
end

describe 'regression test with b-foodcritic-regression repo' do
  let(:expected_lint_output) do
    File.read('spec/regression/expected-output-regression.txt').split("\n").sort.join("\n")
  end
  let(:actual_lint_output) do
    lint_regression_repo
  end
  it 'should result in the match with expected output' do
#    File.write('spec/regression/expected-output-regression.txt', actual_lint_output.split("\n").sort.join("\n"))
    expect(actual_lint_output.split("\n").sort.join("\n")).to eq(expected_lint_output)
  end
end
