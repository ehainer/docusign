require 'docusign/version'
require 'docusign/client'
require 'docusign/config'
require 'docusign/data'
require 'docusign/response'
require 'docusign/action_dispatch/routes'
require 'docusign/active_record'
require 'docusign/helpers/document_helper'
require 'carrierwave'

module Docusign

  class Error < StandardError; end

  class ResponseError < Error; end

  class LoginError < Error; end

  def self.setup
    yield config
  end

  def self.config
    @config ||= Config.new
  end

  def self.client
    @client ||= Client.new
  end

end

require 'docusign/engine' if defined?(Rails)