#!/usr/bin/env ruby

require 'bundler/setup'
require 'set'
require 'csv'
require 'slop'
require 'progress'
require 'cyclopediosyntax'

options = Slop.new do
  banner "Usage: filter_administrative.rb -p parsed_path -o output_path -a administrative_path\n" +
    "Filter out administrative categories from the file with parsed heads."

  on :p=, :sentences_path, 'Parsed categories', required: true
  on :a=, :administrative_path, 'Administrative categories', required: true
  on :o=, :output_path, 'Output file with parsed categories without administrative categories', required: true
end
begin
  options.parse
rescue Slop::MissingOptionError
  puts options
  exit
end

file_output =

administrative = Set.new
CSV.open(options[:administrative_path], "r:utf-8") do |input|
  input.each do |category_tuple|
    administrative.add(category_tuple[0].strip)
  end
end

distinct_excluded = Set.new
counter = 0
CSV.open(options[:sentences_path], "r:utf-8") do |input|
  CSV.open(options[:output_path], "w") do |output|
    input.each do |row|
      if administrative.include?(row[0])
        counter += 1
        distinct_excluded.add(row[0])
        next
      end
      output << row
    end
  end
end

puts "Total number of excluded categories #{counter}"
puts "Number of administrative categories #{administrative.size}"
puts "Number of distinct excluded categories #{distinct_excluded.size}"

# 138377
# 138391
# 138377
#<Set: {"Wikipedia files with unknown source as of 4 October 2013", "Wikipedia files needing editor assistance at upload as of 4 October 2013", "Wikipedia files with no non-free use rationale as of 4 October 2013", "Orphaned non-free use Wikipedia files as of 4 October 2013", "Disputed non-free Wikipedia files as of 4 October 2013", "Wikipedia files with the same name on Wikimedia Commons as of 4 October 2013", "Wikipedia files with a different name on Wikimedia Commons as of 4 October 2013", "Frasier episode redirects to lists", "October 2013 peer reviews", "Infobox holiday with missing field", "Convert invalid units", "Convert invalid options", "Wikipedia files missing permission as of 2 October 2013", "Osku County geography stubs"}>
