#!/usr/bin/env ruby

require 'bundler/setup'
require 'csv'
require 'set'
require 'slop'
require 'progress'
require 'syntax/penn_tree'
require 'syntax/parsed_sentence'
require 'syntax/dependencies'
require 'syntax/stanford/converter'


#Compute char distribution in category names.

options = Slop.new do
  banner 'Usage: char_stats.rb -c parsed_with_heads.csv'

  on :c=, 'categories', 'CSV with category names in second column', required: true
end
begin
  options.parse
rescue Slop::MissingOptionError
  puts options
  exit
end


char_stats = Hash.new
CSV.open(options[:categories], 'r:utf-8') do |input|
  input.each do |row|
    category_name = row[1]
    Set.new(category_name.split('')).each do |char|
      (char_stats[char] ||= []) << category_name
    end
  end
end

puts '| Char | Category count | Sample |'
puts '| --- | --- | --- |'
char_stats.sort_by{|_,v| v.count}.reverse.each do |char,categories|
  next if char =~ /\p{L}/u # omit letters
  puts '| '+ char + ' | ' + categories.count.to_s + ' | ' + categories.sample + ' |'
end
