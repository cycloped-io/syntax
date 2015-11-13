require_relative 'stanford/all'
require 'wiktionary/noun'

module Cyclopedio
  module Syntax

    class NameDecorator < SimpleDelegator
      def initialize(category, options={})
        @category = category
        @parse_tree_factory = options[:parse_tree_factory] || Cyclopedio::Syntax::Stanford::Converter
        super(@category)
      end

      # Returns the first parse tree of the +category+ name.
      def category_head_tree
        convert_head_into_object(@category.parsed_head)
      end

      # Returns the word (string) being a head of the +category+ name.
      def category_head
        head_node = category_head_tree.find_head_noun
        head_node && head_node.content
      end

      # Returns a list of parse trees of the +category+ name.
      # The might be more parse trees for categories such as "Cities and
      # villages in X", etc.
      def category_head_trees
        if @category.multiple_heads?
          @category.parsed_heads.map{|h| convert_head_into_object(h) }
        else
          [category_head_tree]
        end
      end

      def remove_parentheses
        return @category.name if @category.name !~ /\(/ || @category.name =~ /^\(/
        @category.name.sub(/\([^)]*\)/,"").strip
      end

      def type_in_parentheses
        type = @category.name[/\([^)]*\)/]
        type ? type[1..-2] : ""
      end

      private
      # Converts the string representing the parsed +head+ into tree of objects.
      def convert_head_into_object(head)
        @parse_tree_factory.new(head).object_tree
      end
    end
  end
end

