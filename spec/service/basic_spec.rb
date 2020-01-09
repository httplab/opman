# frozen_string_literal: true

class Winner < Op::Service
  # Always successful, without value but with custom data.
  class CustomResult < Op::Result
    attr_reader :custom_data

    def initialize(str)
      @custom_data = str
      super(true)
    end
  end

  def perform(a, b, name:, greeting: 'Hello')
    str = [greeting, name, a + b, 'times!'].map(&:to_s).join(' ')
    CustomResult.new(str)
  end
end

class Looser < Op::Service
  def perform(_a)
    Op::Result.new(false, :not_found)
  end
end

describe Winner do
  it 'return success' do
    result = Winner.call(2, 3, name: 'John')

    expect(result).to be_success
    expect(result.custom_data).to eq 'Hello John 5 times!'
  end

  it 'raise error if something wrong' do
    expect { Winner.call('wrong') }.to raise_error(ArgumentError)
  end
end

describe Looser do
  it 'returns failure' do
    result = Looser.call('disaster')

    expect(result).to be_fail
    expect(result.error).to eq :not_found
  end
end
