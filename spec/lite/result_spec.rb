describe Op::Lite::Result do
  describe 'value accessors' do
    it 'allows to access value in function call style on success' do
      result = described_class.success(greeting: 'Hello', name: "Alice")
      expect(result.greeting).to eq 'Hello'
      expect(result.name).to eq 'Alice'
      expect(result.value).to eq(greeting: 'Hello', name: "Alice")
    end

    it 'allows to access value in function call style on failure' do
      result = described_class.failure(:not_found, message: "Not found")
      expect(result.error).to eq :not_found
      expect(result.message).to eq "Not found"
      expect(result.value).to eq(message: "Not found")
    end
  end
end
