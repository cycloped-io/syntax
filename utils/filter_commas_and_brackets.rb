#!/usr/bin/env ruby

require 'bundler/setup'
require 'csv'
require 'slop'
require 'progress'
require 'cyclopedio/syntax'

options = Slop.new do
  banner "Usage: #{$PROGRAM_NAME} -c categories.csv -o preprocessed_categories.csv\n"+
  'Filter parentheses and commas from category names.'

  on :i=, :input, 'CSV with category names', required: true
  on :o=, :output, 'CSV with categories and categories without commas and brackets', required: true
end

begin
  options.parse
rescue Slop::MissingOptionError
  puts options
  exit
end

stats = Hash.new(0)

CSV.open(options[:output], 'w') do |output|
  CSV.open(options[:input], 'r:utf-8') do |input|
    input.with_progress do |row|
      category_name=row.first
      preprocessed_category_name = category_name.dup

      brackets = preprocessed_category_name.gsub!(/ \(.*?\)/, '') # brackets
      stats['Removed brackets'] += 1 if brackets

      commas = preprocessed_category_name.gsub!(/, (\p{Lu}[^ ,]* ?){1,2}/u, ' ') # commas specifying locations
      stats['Removed commas specifying locations'] += 1 if commas

      output << [category_name, preprocessed_category_name]
    end
  end
end

stats.each do |name, value|
  puts name+': '+value.to_s
end
