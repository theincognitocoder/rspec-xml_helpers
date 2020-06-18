# frozen_string_literal: true

require 'naws_xml'

require_relative 'xml_helpers/xml_matcher'
require_relative 'xml_helpers/xml_formatter'

module RSpec
  # Provides a `match_xml` rspec matcher.
  module XmlHelpers
    # @param [String<XML>] expected
    def match_xml(expected)
      XmlMatcher.new(expected, ordered: false)
    end

    def match_ordered_xml(expected)
      XmlMatcher.new(expected, ordered: true)
    end

    class << self

      # @param [String<XML>] xml
      # @return [String<XML>]
      # @api private
      def normalize_xml(xml, ordered:)
        XmlFormatter.new.format(xml, ordered: ordered)
      end

    end
  end
end

RSpec.configure do |config|
  config.include RSpec::XmlHelpers
end
