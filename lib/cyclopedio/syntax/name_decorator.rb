require_relative 'stanford/all'
require 'wiktionary/noun'

module Cyclopedio
  module Syntax

    class NameDecorator < SimpleDelegator
      def initialize(concept, options={})
        @parse_tree_factory = options[:parse_tree_factory] || Cyclopedio::Syntax::Stanford::Converter
        super(concept)
      end

      # Returns the first parse tree of the +category+ name.
      def category_head_tree
        convert_head_into_object(__getobj__.parsed_head)
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
        if __getobj__.multiple_heads?
          __getobj__.parsed_heads.map{|h| convert_head_into_object(h) }
        else
          [category_head_tree]
        end
      end

      # Removes parentheses with content from concept name. Usually used for disambiguated article names.
      def remove_parentheses
        return __getobj__.name if __getobj__.name !~ /\(/ || __getobj__.name =~ /^\(/
        __getobj__.name.sub(/\([^)]*\)/,"").strip
      end

      # Returns string in parentheses from concept name. Usually used for disambiguated article names.
      def type_in_parentheses
        type = __getobj__.name[/\([^)]*\)/]
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

