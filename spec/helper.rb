require "rspec"

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "perlin"

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
end

# Check a N-d array of floats for consistency with another one.
def same_array_within_accuracy(result, expected, accuracy)
  expect(result.size).to eq expected.size

  result.zip(expected) do |a, b|
    if b[0].is_a? Array
      same_array_within_accuracy a, b, accuracy
    else
      a.zip(b.flatten) do |x, y|
        expect(x).to be_within(@accuracy).of y
      end
    end
  end
end