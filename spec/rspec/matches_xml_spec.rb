# frozen_string_literal: true

require_relative '../spec_helper'

module RSpec
  module XmlHelpers
    describe XmlMatcher do
      it 'matches XML strings' do
        expect('<xml/>').to match_xml('<xml/>')
      end

      it 'fails to matches different XML strings' do
        expect('<xml/>').not_to match_xml('<xml atttr="value"/>')
      end

      it 'considers whitespace significant for elements without children' do
        expect('<xml> </xml>').not_to match_xml('<xml/>')
      end

      it 'matches nested XML strings' do
        expect('<xml><nested/></xml>').to match_xml('<xml><nested/></xml>')
      end

      it 'matches XML with attributes strings' do
        expect('<xml><nested attr="value"/></xml>').to match_xml('<xml><nested attr="value"/></xml>')
      end

      it 'matches XML with text' do
        expect('<xml><nested>value</nested></xml>').to match_xml('<xml><nested>value</nested></xml>')
      end

      it 'matches ignoring whitespace' do
        expect('<xml><nested/></xml>').to match_xml(<<~XML)
          <xml>
            <nested/>
          </xml>
        XML
      end

      it 'ignores child node order' do
        expect('<xml><child1/><child2/></xml>').to match_xml(<<~XML)
          <xml>
            <child2/>
            <child1/>
          </xml>
        XML
      end

      it 'stable sorts children with the same name' do
        actual = '<xml><c>1</c><c>2</c></xml>'
        expected = '<xml><c>1</c><c>2</c></xml>'
        expect(actual).to match_xml(expected)

        actual = '<xml><c>2</c><c>1</c></xml>'
        expected = '<xml><c>1</c><c>2</c></xml>'
        expect(actual).not_to match_xml(expected)
      end

      it 'gives a helpful error message when xml does not match' do
        actual = '<xml><node>value</node></xml>'
        expected = '<xml><otherNode>value</otherNode></xml>'
        matcher = XmlMatcher.new(expected, colorize: false)
        matcher.matches?(actual)
        expect(matcher.failure_message).to eq(<<~MSG)
          Expected:

          <xml>
            <otherNode>value</otherNode>
          </xml>

          Got:

          <xml>
            <node>value</node>
          </xml>

          Diff:

           <xml>
          -  <otherNode>value</otherNode>
          +  <node>value</node>
        MSG
      end

      it 'gives a helpful error message when actual is not valid XML' do
        expect do
          expect('').to match_xml('<xml/>')
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError,
          /^Expected actual to be an XML string, encountered error while parsing:/)
      end

      it 'gives a helpful error message when expected is not valid XML' do
        expect do
          expect('<xml/>').to match_xml(123)
        end.to raise_error(ArgumentError,
          /^Encountered an error parsing the match_xml expected value:/)
      end

      it 'gives an error when negation matching fails' do
        expect do
          expect('<xml/>').not_to match_xml('<xml/>')
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError, 'Expected XML value not to match.')
      end
    end
  end
end
