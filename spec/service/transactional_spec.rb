# frozen_string_literal: true

module ServiceTransactionalSpec
  class Foo < Op::Service
    operation_name 'foo'
    transactional

    # This perform call should be wrapped in transaction becaues Foo is transactional
    # and Foo is initiator of further calls
    def perform
      op(Bar).call
      success
    end
  end

  class Bar < Op::Service
    operation_name 'bar'
    transactional

    # This perform should not be wrapped in transaction despite Bar is transactional. It is because
    # Bar is called by Foo which is already defined as transactional.
    def perform
      success
    end
  end

  describe 'Transactional services' do
    let(:foo) { Foo.new }
    let(:bar) { Bar.new(nil, foo) }

    before do
      allow(Foo).to receive(:new).and_return(foo)
      allow(Bar).to receive(:new).with(nil, foo).and_return(bar)
    end

    it 'wraps top level #perform in transaction' do
      expect(foo).to receive(:perform_in_transaction)

      Foo.call
    end

    it "doesn't wrap nested perform in transaction" do
      expect(bar).to receive(:perform)
      expect(bar).to_not receive(:perform_in_transaction)

      Foo.call
    end
  end
end
