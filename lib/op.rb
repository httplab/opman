# frozen_string_literal: true

require 'json'

require 'op/railtie'
require 'op/lite'
# require 'op/result_helpers'
# require 'op/result'
# require 'op/service'
# require 'op/context'

module Op
  Service = Op::Lite::Service
  Result = Op::Lite::Result
  Context = Op::Lite::Context
end

require 'op/operation'
