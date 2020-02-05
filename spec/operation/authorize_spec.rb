# frozen_string_literal: true

module OperationAuthorizeSpec
  class Document
    def self.find(_id)
      new
    end

    def author
      OpenStruct.new(id: 42, email: 'john.doe@foobar.com')
    end
  end

  class DeleteDocument < Op::Operation
    operation_name :delete_document

    attr_reader :document

    step :prepare_document
    step :authorize

    def prepare_document(document_id)
      @document = Document.find(document_id)
    end

    def authorize(_document_id)
      return if context.user == document.author

      Op::Result::Unauthorized.new('Current user is not author of the document')
    end
  end

  describe 'Validation step' do
    let(:user) { OpenStruct.new(id: 66, email: 'evil.intruder@foobar.com') }
    let(:operation_context) { OperationContext.new(user) }
    let(:operation) { DeleteDocument.new(operation_context) }

    it 'performs authorization and returns error' do
      result = operation.call(42)

      expect(result).to be_fail
      expect(result.error).to eq :authorization
      expect(result.message).to eq 'Current user is not author of the document'

      expect(OperationState.count).to eq 1
      opstate = OperationState.first
      expect(opstate).to be_failed
    end
  end
end
