# frozen_string_literal: true

require 'json'

require 'op/railtie'
require 'op/lite'

module Op
  Service = Op::Lite::Service
  Result = Op::Lite::Result
  Failure = Op::Lite::Failure
  Context = Op::Lite::Context
end

require 'op/operation'
