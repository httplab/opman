module AfterHooksSpec
  class HooksService < Op::Lite::Service
    after :run_always
    after :run_on_success, on: :success
    after :run_on_failure, on: :failure

    private

    def perform(must_be_failed:)
      return failure(:oh_nooo) if must_be_failed

      success
    end

    def run_always(_result)
      @run_always = true
    end

    def run_on_success(_result)
      @run_on_success = true
    end

    def run_on_failure(_result)
      @run_on_failure = true
    end
  end

  describe HooksService do
    it 'run hooks on success' do
      service = described_class.new
      result = service.call(must_be_failed: false)

      expect(result).to be_success
      expect(service.instance_variable_get(:@run_always)).to be true
      expect(service.instance_variable_get(:@run_on_success)).to be true
      expect(service.instance_variable_get(:@run_on_failure)).to be_nil
    end

    it 'run hooks on failure' do
      service = described_class.new
      result = service.call(must_be_failed: true)

      expect(result).to be_failure
      expect(service.instance_variable_get(:@run_always)).to be true
      expect(service.instance_variable_get(:@run_on_success)).to be_nil
      expect(service.instance_variable_get(:@run_on_failure)).to be true
    end
  end
end
