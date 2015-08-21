#!/usr/bin/env ruby

require 'bundler/setup'
require 'csv'
require 'slop'
require 'progress'

options = Slop.new do
  banner "Usage: parse_category_names.rb -s sentences_path -p parsed_path -o output_path\n" +
    "Exporst results of disambiguation with local heuristics"

  on :s=, :sentences, 'Sentences in new lines', required: true
  on :p=, :parsed, 'Sentences parsed by Stanford Parser', required: true
  on :o=, :output, 'Path to output', required: true
end
begin
  options.parse
rescue Slop::MissingOptionError
  puts options
  exit
end

# Lloyds Bank plc v Rosset [1990 1990] UKHL 14, <U+2029>[1991 1991]<U+2029> AC 107 is an important case in English property law dealing with the rights of cohabitees.
sentences = File.new(options[:sentences], "r:utf-8")
CSV.open(options[:output], 'w') do |output|
  File.new(options[:parsed], "r:utf-8") do |input|
    lines = []
    input.each do |line|
      if line == "\n"
        row = [sentences.gets.strip]
        while row.first==''
          output << []
          row = [sentences.gets.strip]
        end
        row.push lines[0].rstrip
        row.push lines[1..-1].join.rstrip
        output << row

        lines=[]
      elsif line == "(())\n"
        puts "Empty parsing for: '#{line}'"
        output << [sentences.gets,nil,nil]
      else
        lines.push(line)
      end
    end
  end
end
sentences.close
