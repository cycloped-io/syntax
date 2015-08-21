#!/usr/bin/env ruby
# encoding: utf-8

require 'bundler/setup'
require 'progress'
require 'csv'
require 'slop'

options = Slop.new do
  banner "#{$PROGRAM_NAME} -a input_1.csv -b input_2.csv -o output.csv"

  on :a=, :input_1, 'First CSV or TXT file with data to join', required: true
  on :b=, :input_2, 'Second CSV or TXT file with data to join', required: true
  on :o=, :output, 'Output file with joined data', required: true
  on :x=, :type_1, 'Type of first input (File|CSV)', default: 'File'
  on :y=, :type_2, 'Type of second input (File|CSV)', default: 'File'
end

begin
  options.parse
rescue Slop::MissingOptionError
  puts options
  exit
end

files = []

[[:type_1,:input_1],[:type_2,:input_2]].each do |type,path|
  begin
    klass = Module.const_get(options[type])
    files << klass.open(options[path], "r:utf-8")
  rescue
    puts "Invalid type #{options[type]}"
    exit
  end
end

CSV.open(options[:output],"w") do |output|
  while true do
    begin
      lines = []
      2.times do |index|
        line = files[0].readline
        if line.respond_to?(:strip)
          line.strip!
        end
        lines << line
      end
    rescue EOFError
      break
    end

    if lines.compact.size < 2
      break
    end
    output << lines.flatten
  end
end
