#!/usr/bin/env ruby
# encoding: utf-8

require_relative '../lib/mmac'

puts 'Run program...'
MIN_SUPP = 0.3
MIN_CONF = 0.5
framework = Mmac::Framework.new(File.dirname( __FILE__ ) + '/file/data.txt', MIN_SUPP, MIN_CONF)
framework.run

puts "\n"
puts 'Run Data Test'
framework.set_label(File.dirname( __FILE__ ) + '/file/test.txt')

f1 = IO.readlines(File.dirname( __FILE__ ) + "/file/testOut.txt").map(&:chomp)
f2 = IO.readlines(File.dirname( __FILE__ ) + "/file/data.txt"   ).map(&:chomp)

diff = f1 - f2
puts ("Number of diff: #{diff.count}")
puts ("Percent of success test: #{((1 - diff.count.fdiv(f1.count))*100).round(2)}%")

File.open(File.dirname( __FILE__ ) + "/file/diff.txt","w"){ |f| f.write(diff.join("\n")) }

puts 'Done!'