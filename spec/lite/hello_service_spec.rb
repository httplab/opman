module HelloServiceSpec
  class HelloService < Op::Lite::Service
    private

    def perform(greeting, name:)
      success("#{greeting}, #{name}!")
    end
  end

  describe HelloService do
    it 'returns greeting' do
      result = described_class.call("Hello", name: "Alice")
      expect(result).to be_success
      expect(result.value).to eq 'Hello, Alice!'
    end
  end
end
