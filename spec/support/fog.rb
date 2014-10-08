RSpec.configure do |config|
  config.before(:suite) do
    Fog.mock!
  end
end