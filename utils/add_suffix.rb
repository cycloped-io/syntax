#!/usr/bin/env ruby

require 'bundler/setup'
require 'csv'
require 'slop'
require 'progress'

options = Slop.new do
  banner "Usage: #{$PROGRAM_NAME} -c preprocessed_categories.csv\n"+
  'Adds suffix to category names for Stanford Parser.'

  on :c=, 'categories', 'CSV with categories and categories without commas and brackets', required: true
end

begin
  options.parse
rescue Slop::MissingOptionError
  puts options
  exit
end

SUFFIX = ' are good.'

CSV.open(options[:categories]) do |file_categories|
  file_categories.with_progress do |row|
    preprocessed_category_name = row[1]
    puts preprocessed_category_name+SUFFIX
  end
end

