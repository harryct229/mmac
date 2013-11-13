require_relative '../lib/mmac'

puts 'Run program...'
framework = Mmac::Framework.new(File.dirname( __FILE__ ) + '/file/data.txt', 0.2, 0.4)
framework.run

puts 'Run Data Test'
framework.set_label(File.dirname( __FILE__ ) + '/file/test.txt')

f1 = IO.readlines(File.dirname( __FILE__ ) + "/file/testOut.txt").map(&:chomp)
f2 = IO.readlines(File.dirname( __FILE__ ) + "/file/data.txt"   ).map(&:chomp)

diff = f1 - f2
puts ("Number of diff: " + "#{diff.count}")

File.open(File.dirname( __FILE__ ) + "/file/diff.txt","w"){ |f| f.write(diff.join("\n")) }

puts 'Done!'