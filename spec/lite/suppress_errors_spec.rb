module SuppressErrorsSpec
  class Base < Op::Service
  end

  class Foo < Base
    suppress_errors
  end

  class Bar < Foo
    def perform
      raise 'something went wrong'
    end
  end

  # rubocop:disable RSpec/DescribeClass
  describe 'suppressing errors' do
    it 'suppresses an exception and returns failure' do
      result = nil
      expect { result = Bar.call }.to_not raise_error

      expect(result).to be_failure
      expect(result.error).to eq :exception
      expect(result.message).to eq 'something went wrong'
    end

    it 'doesnt affect parent when set suppress_errors' do
      expect(Foo.suppress_errors?).to be true
      expect(Base.suppress_errors?).to be false
    end

    it 'propagates suppress_errors to children' do
      expect(Foo.suppress_errors?).to be true
      expect(Bar.suppress_errors?).to be true
    end
  end
  # rubocop:enable RSpec/DescribeClass
end
