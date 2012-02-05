#!/usr/bin/env ruby

# Given a transactions file, run the student ID number
# through the MD5 one-way hash to make it anonymous.
#
# Input:
# 10	12	45
# 11	12	53
#
# Output:
# 10	12	93e50d72ab294091a81d828459019eba
# 11	12	c92841e00dbfeb12a0ce7fb3ffbd1fcb

require 'digest/md5'

file = ARGV[0]
if file.nil?
  puts "Please specify a transaction file"
  exit
end

File.open(file, "r") do |t|
  while trans = t.gets
    next if trans.chomp.nil?
    transactions = trans.split("\t") # Will fail on whitespace, make it \s if that's a problem
    puts transactions[0] + "\t" + transactions[1] + "\t" + Digest::MD5.hexdigest(transactions[2])
  end
end
