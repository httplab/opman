# frozen_string_literal: true

module OperationValidtionSpec
  Client = Struct.new(:email) do
    include ActiveModel::Validations

    validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  end

  class SaveClient < Op::Operation
    operation_name :save_client

    attr_reader :client

    step :prepare_client
    step :validate, discard_state_on_fail: true

    def prepare_client(email)
      @client = Client.new(email: email)
    end

    def validate(_email)
      Op::Result::ValidationFail.new(client) unless client.valid?
    end
  end

  describe 'Validation step' do
    let(:user) { OpenStruct.new(id: 42, email: 'john.doe@foobar.com') }
    let(:operation_context) { OperationContext.new(user) }
    let(:operation) { SaveClient.new(operation_context) }

    it 'returns validation error when email is invalid' do
      result = operation.call('wrong.email')

      expect(result).to be_fail
      expect(result.error).to eq :validation
      expect(result.details.as_json).to eq [{ source: :email, error: :invalid, details: 'is invalid', value: 'wrong.email' }]

      # Because of discard_state_on_fail
      expect(OperationState.count).to eq 0
    end
  end
end
