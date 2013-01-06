require 'optparse'
require 'rails/test_help'
require 'rails/performance_tests/test_help'
require 'rails/performance_tests/active_support/testing/performance'

def options
  options = {}
  defaults = ActiveSupport::Testing::Performance::DEFAULTS

  OptionParser.new do |opt|
    opt.banner = "Usage: rails profiler 'Ruby.code' 'Ruby.more_code' ... [OPTS]"
    opt.on('-r', '--runs N', Numeric, 'Number of runs.', "Default: #{defaults[:runs]}") { |r| options[:runs] = r }
    opt.on('-o', '--output PATH', String, 'Directory to use when writing the results.', "Default: #{defaults[:output]}") { |o| options[:output] = o }
    opt.on('-m', '--metrics a,b,c', Array, 'Metrics to use.', "Default: #{defaults[:metrics].join(",")}") { |m| options[:metrics] = m.map(&:to_sym) }
    opt.on('-f', '--formats x,y,z', Array, 'Formats to output to.', "Default: #{defaults[:formats].join(",")}") { |m| options[:formats] = m.map(&:to_sym) }
    opt.parse!(ARGV)
  end

  options
end

class ProfilerTest < ActionDispatch::PerformanceTest #:nodoc:
  self.profile_options = options

  ARGV.each do |expression|
    eval <<-RUBY
      def test_#{expression.parameterize('_')}
        #{expression}
      end
    RUBY
  end
end
