ENV['RACK_ENV'] = 'test'
require 'rack/test'
require 'webmock/rspec'
require 'redis'
require 'multi_json'
require 'json'

require_relative '../app'


RSpec.configure do |config|
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # Disable all external requests in test mode (will raise error in test run)
  WebMock.disable_net_connect!(allow_localhost: true)

  # Uncomment below to allow network access during tests
  #WebMock.allow_net_connect!

  # Set up for feature tests
  shared_context "Feature specs", type: :feature do
    include Rack::Test::Methods
    let(:app) { LocalSyncApp }
  end

  # Clear Redis DB between tests
  config.before(:each) do
    redis = LocalSyncApp.settings.redis
    redis.flushall
  end

  # Assorted helpers

  # Convert json string to hash
  def as_hash(string)
    MultiJson.load(string)
  end

  # Load a json fixture as a raw (presumably JSON compliant) string
  def raw_json_fixture(name)
    File.read(File.join(File.dirname(__FILE__), "fixtures/json/#{name.to_s}.json"))
  end

  # Load a json fixture as a hash
  def json_fixture(name)
    MultiJson.load(
      raw_json_fixture(name)
    )
  end

  # Load the result of evalutaing the file
  def ruby_fixture(name)
    eval(
      File.read(File.join(File.dirname(__FILE__), "fixtures/ruby/#{name.to_s}.rb"))
    )
  end

  # POST json as actual json
  def post_json(uri, payload='{}')
    post(uri, payload, { "CONTENT_TYPE" => "application/json" })
  end

# The settings below are suggested to provide a good initial experience
# with RSpec, but feel free to customize to your heart's content.
=begin
  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options. We recommend
  # you configure your source control system to ignore this file.
  config.example_status_persistence_file_path = "spec/examples.txt"

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended. For more details, see:
  #   - http://rspec.info/blog/2012/06/rspecs-new-expectation-syntax/
  #   - http://www.teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://rspec.info/blog/2014/05/notable-changes-in-rspec-3/#zero-monkey-patching-mode
  config.disable_monkey_patching!

  # This setting enables warnings. It's recommended, but in some cases may
  # be too noisy due to issues in dependencies.
  config.warnings = true

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
=end
end
