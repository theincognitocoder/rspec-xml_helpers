# frozen_string_literal: true

require 'diff-lcs'
require 'diffy'
require 'stringio'

module RSpec
  module XmlHelpers
    # @api private
    class XmlFormatter

      def format(xml, ordered:)
        xml = NawsXml::Parser.new.parse(xml)
        xml = stable_sort(xml) unless ordered
        xml.to_s(indent: '  ')
      end

      private

      def stable_sort(xml)
        node = NawsXml::Node.new(xml.name)
        node.attributes.update(sort_attrs(xml.attributes))
        node << xml.text if xml.text
        sort_nodes(xml.children).each do |child|
          node << child
        end
        node
      end

      def sort_attrs(attrs)
        attrs.keys.sort.each_with_object({}) do |key, sorted|
          sorted[key] = attrs[key]
        end
      end

      def sort_nodes(nodes)
        nodes.sort_by.with_index { |node, idx| [node.name, idx] }
      end

    end
  end
end
