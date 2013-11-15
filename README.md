# Mmac

Multi-class multi-label associative classification (mmac) library for Ruby

## Installation

Add this line to your application's Gemfile:

    gem 'mmac'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mmac

## Usage

Learning
    
    framework = Mmac::Framework.new('path/to/file/data.txt', MIN_SUPP, MIN_CONF)
    framework.run
    
Set Label for Test File
    
    framework.set_label('path/to/file/test.txt')

The output will be 'path/to/file/testOut.txt'

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
