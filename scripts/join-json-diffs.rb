#!/usr/bin/ruby

require 'json'
require 'fileutils'

INTERESTING_PARTS=["new", "fixed"]

if (ARGV.size < 2 || ARGV[0] == "-h" || ARGV[0] == "--help")
  puts "Merges two or more JSON files into one"
  puts "Only #{INTERESTING_PARTS} parts are merged"
  puts "Usage: join-json-diffs.rb output-file.json input-file1.json [input-file2.json[ ...]]"
  exit 0
end

files_to_merge = ARGV
export_to_file = files_to_merge.slice!(0)

if File.exists?(export_to_file)
  puts "For security reasons, export file #{export_to_file} must not exist!"
  exit 1
end

merged_diffs = Hash[INTERESTING_PARTS.map{ |part| [part, []] }]

files_to_merge.each do |file|
  puts "Merging file #{file} ..."

  unless File.exists?(file)
    puts "File #{file} does not exist"
    exit 1
  end

  file_content = JSON.parse(File.read(file))

  # Merging by parts, all items must be unique
  INTERESTING_PARTS.each do |part|
    if (file_content.has_key?(part) && (file_content[part].size != 0))
      merged_diffs[part] = (merged_diffs[part] + file_content[part]).uniq
    end
  end
end

puts "Exporting to file #{export_to_file}"
jj(merged_diffs)
File.open(export_to_file, "w") do |f|
  f.write(JSON.pretty_generate(merged_diffs))
end

exit 0
