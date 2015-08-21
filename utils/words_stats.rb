#!/usr/bin/env ruby


require 'bundler/setup'
require 'csv'
require 'set'
require 'slop'
require 'progress'
require 'cyclopedio/syntax'


options = Slop.new do
  banner "Usage: char_stats.rb -c parsed_with_heads.csv\n" +
        "Compute char distribution in category names."
  on :c=, :categories, 'CSV with category names in second column', required: true
end

begin
  options.parse
rescue Slop::MissingOptionError
  puts options
  exit
end


char_stats = Hash.new
CSV.open(options[:categories], 'r') do |input|
  input.with_progress do |row|
    category_name = row[1]
    Set.new(category_name.split(' ')).each do |word|
      (char_stats[word] ||= []) << category_name
    end
    if category_name =~ /[1-9][0-9]{3}/
      (char_stats['YEAR_REGEXP'] ||= []) << category_name
    end
  end
end

puts '| Word | Category count | Sample |'
puts '| --- | --- | --- |'
char_stats.sort_by{|_,v| v.count}.reverse.each do |word,categories|
  puts '| '+ word + ' | ' + categories.count.to_s + ' | ' + categories.sample + ' |'
end
