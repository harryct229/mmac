require_relative '../lib/mmac'

puts 'Run program ...'
framework = Mmac::Framework.new(File.dirname( __FILE__ ) + '/file/data.txt', 0.2, 0.4)
framework.run

puts 'Run Data Test'
framework.set_label(File.dirname( __FILE__ ) + '/file/test.txt')
puts 'Done!'