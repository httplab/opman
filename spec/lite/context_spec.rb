module ContextSpec
  class SimpleService < Op::Lite::Service
    private

    def perform
      success
    end
  end

  describe SimpleService do
    it 'allows to set logger from context' do
      logger = Logger.new('/dev/null')
      ctx = Op::Lite::Context.new(logger:)
      service = described_class.new(ctx)

      expect(service.logger).to eq(logger)
    end
  end
end
