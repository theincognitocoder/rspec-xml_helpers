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

      it 'gives a helpful error message actual is not valid XML' do
        expect do
          expect('').to match_xml('<xml/>')
        end.to raise_error(RSpec::Expectations::ExpectationNotMetError,
          /Expected XML, but encountered an error while parsing the actual value:/)
      end

      it 'gives a helpful error message actual is not a String' do
        expect do
          expect(false).to match_xml('<xml/>')
        end.to raise_error(/wrong argument type/)
      end
    end
  end
end
