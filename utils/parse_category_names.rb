#!/usr/bin/env ruby

require 'bundler/setup'
require 'csv'
require 'slop'
require 'progress'
require 'cyclopedio/syntax'
require 'wiktionary/noun'

options = Slop.new do
  banner "Usage: #{$PROGRAM_NAME} -c parsed_categories.csv -o parsed_categories_with_heads.csv -e errors.csv\n"+
             'Finds head nouns'

  on :c=, 'parsed_categories', 'Parsed categories', required: true
  on :o=, 'output', 'Parsed categories with heads', required: true
  on :e=, 'errors', 'Heads not found correctly', required: true
end
begin
  options.parse
rescue Slop::MissingOptionError
  puts options
  exit
end

nouns = Wiktionary::Noun.new

output = options[:output]

file_output = CSV.open(output, 'w')
file_stats = CSV.open(output+'.stats', 'w')
file_stats_err = CSV.open(output+'.stats.err', 'w')
file_errors = CSV.open(options[:errors], 'w')

counter = 0
CSV.open(options[:parsed_categories], 'r:utf-8') do |input|
  input.with_progress do |row|
    category_name, preprocessed_category_name, full_parse, dependency = row
    tree = Syntax::PennTree.new(full_parse)
    tree.fix_number(nouns)
    nouns.fix_penn_tree(tree.tree)
    row[2] = tree.to_s
    dependencies = Syntax::Dependencies.new(dependency.split("\n"))
    sentence = Syntax::ParsedSentence.new(tree, dependencies)

    heads = [sentence.dep_head] # removing from tree can cause errors in methods based on dependencies
    tree.remove_parenthetical!
    heads.concat sentence.heads

    stats = [tree.tree.to_s, tree.tree.tree_without_content.to_s, tree.tree.tree_without_content_and_word_level.to_s]

    tree.remove_prepositional_phrases!

    heads.push tree.find_last_plural_noun
    heads.push tree.find_last_nominal

    heads_stats = heads.map { |h| h.nil? ? nil : h.find_parent_np.to_s }
    heads_without_nils = heads.select { |h| not h.nil? }
    noun_phrases = heads_without_nils.map { |h| h.find_parent_np.to_s }

    if noun_phrases.uniq.size==1 && heads.size>=2
      counter += 1
      file_output << row + [heads_without_nils[0].find_parent_np.to_s, heads_without_nils[0].content, heads_without_nils[0].parent.plural_noun?]
      file_stats << row + stats + [tree.tree.to_s, tree.tree.tree_without_content, tree.tree.tree_without_content_and_word_level] + heads_stats
    else
      #p category_name
      #p heads
      file_errors << [category_name] + heads
      file_output << row + [nil, nil, nil]
      file_stats_err << row + stats + [tree.tree.to_s, tree.tree.tree_without_content, tree.tree.tree_without_content_and_word_level] + heads_stats
    end
  end
end

file_output.close
file_errors.close
file_stats.close
file_stats_err.close

puts "Number of correctly parsed heads: #{counter}"
# EN wiki 2013-10: 869601
