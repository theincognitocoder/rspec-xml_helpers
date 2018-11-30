# frozen_string_literal: true

require 'diff-lcs'
require 'diffy'
require 'stringio'

module RSpec
  module XmlHelpers
    # @api private
    class XmlMatcher

      BAD_EXPECTED = <<~MSG
        Encountered an error parsing the match_xml expected value:
          %<error>s

        Invalid XML:
          %<got>s
      MSG

      BAD_ACTUAL = <<~MSG
        Expected actual to be an XML string, encountered error while parsing:
          %<error>s

        Invalid XML:
          %<got>s
      MSG

      def initialize(expected, colorize: true)
        @expected = XmlHelpers.normalize_xml(expected)
        @diff_format = colorize ? :color : :text
      rescue NawsXml::ParseError => error
        raise ArgumentError, format(BAD_EXPECTED,
          error: error.message, got: got(expected))
      end

      def matches?(actual)
        @actual = XmlHelpers.normalize_xml(actual)
        @expected == @actual
      rescue NawsXml::ParseError => error
        @error_message = format(BAD_ACTUAL,
          error: error.message, got: got(actual))
        false
      end

      def failure_message
        @error_message || diff_json_error_message
      end

      def failure_message_when_negated
        'Expected XML value not to match.'
      end

      def diff_json_error_message
        message = StringIO.new
        message << "Expected:\n\n#{@expected}\n"
        message << "Got:\n\n#{@actual}\n"
        message << "Diff:\n\n#{diff}"
        message.string
      end

      def diff
        diff = Diffy::Diff.new(@expected, @actual).to_s(@diff_format)
        diff.lines[0..-2].join
      end

      def got(value)
        got = value.inspect unless value.is_a?(String)
        got = xml.inspect if got == ''
        got
      end

    end
  end
end
