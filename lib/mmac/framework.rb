require File.dirname( __FILE__ ) + "/rule"
require 'set'
module Mmac
  #
  # Main Manager for MMac (contains all options, rules, ...)
  #
  #
  class Framework
    #
    # @return Array of data
    #
    attr_accessor :data
    #
    # @return number of data column except Label
    #
    attr_accessor :attrCount
    #
    # @return minSupp
    #
    attr_accessor :minSupp
    #
    # @return minConf
    #
    attr_accessor :minConf
    #
    # @return Array of Filter rules
    #
    attr_accessor :filters
    #
    # @return Array of Filter rules
    #
    attr_accessor :filtersPrint


    def initialize input_file, minSupp, minConf
      @data = []
      @rules = []
      @filters = []
      @filtersPrint = []
      @minSupp = minSupp
      @minConf = minConf

      puts 'Input from file ...'
      parse_data(input_file)
      puts 'Done!'
      @attrCount = @data.first.conditions.count
    end

    def run
      puts 'Learning ...'
      self.normalize
      puts 'Done!'
      # Write to Filter file
      File.open(File.dirname( __FILE__ ) + '/cache/filter.txt', 'a+') {|f| f.write(@filtersPrint.map{|p| p.conditions.join(",") + "," +  p.labels}.join("\n"))}
    end

    def parse_data input_file
      line_array = File.readlines(input_file)
      line_array.each do |line|
        *conditions, label = line.strip.split(',')
        @data << Rule.new(Array[(0...conditions.size).zip conditions].flatten(1), label)
      end
    end

    def normalize
      # Apriori
      filterSet = []
      blackList = []
      dataCount = @data.count

      1.upto(attrCount).flat_map do |n|
        rules = []
        filterCount = filterSet.count
        @data.each do |data|
          conditions = data.conditions
          label      = data.labels

          # All combinations with n attrs
          combinations = conditions.combination(n).to_a
          rules += combinations.map{|c| Rule.new(c, label)}
        end

        # collect conditions without dup
        conRules = rules.map{|r| r.conditions}.to_set
        conRules.each do |c|
          # Placeholder for using blacklist
          # => skip all blacklist rules
          #
          arr = rules.select{|r| r.conditions == c}
          actOccr = arr.count

          set = arr.map{|a| a.labels}.to_set
          set.each do |s|
            suppCount = arr.count{|a| a.labels == s}
            # Calculate sup and conf
            supp = suppCount.fdiv(dataCount)
            conf = suppCount.fdiv(actOccr)

            if supp >= minSupp && conf >= minConf
              filterSet << Rule.new(c, s, supp, conf, actOccr)
            else
              blackList << Rule.new(c, s)
            end
          end
        end
        # break if all new combinations is < minSupp and minConf
        break if filterSet.count == filterCount
      end

      originalOrder = filterSet.clone
      filterSet = filterSet.sort_by{|s| [-s.conf, -s.supp, -s.actOccr, s.conditions.count, originalOrder.index(s)]}
      @filters += filterSet.map{|p| p.clone}
      filterSet.each do |filter|
        # Remove data that contain filter create T'
        @data -= @data.select{|data| data.labels == filter.labels && (filter.conditions - data.conditions).empty?}
        hash = Hash[filter.conditions]
        filter.conditions = (0..(@attrCount-1)).map{|index| hash[index] || ""}
      end
      @filtersPrint += filterSet.map{|p| p.clone}


      # recursive until Data empty
      if !@data.empty?
        self.normalize
      end

      # Separate for Performance
      # GC::Profiler.enable
      # temps.each do |f|
      #   label = f.labels
      #   f.conditions.each do |ff|
      #     arr = ff.to_a
      #     arr.each do |elem|
      #       @rules << Rule.new(elem, label)
      #     end
      #     # Free Memory
      #     arr = []
      #     GC::Profiler.clear
      #     sleep 0.1
      #   end
      # end
      # GC::Profiler.clear
    end

    def set_label sample_file
      test = []
      line_array = File.readlines(sample_file)
      line_array.each do |line|
        conditions = line.strip.split(',')
        rule = Rule.new(Array[(0...conditions.size).zip conditions].flatten(1), "")
        # set label for test data
        @filters.each do |filter|
          if (filter.conditions - rule.conditions).empty?
            rule.labels = filter.labels
            break
          end
        end
        test << rule
      end
      File.open(File.dirname(sample_file) + '/testOut.txt', 'a+') {|f| f.write(test.map{|p| p.conditions.join(",") + "," +  p.labels}.join("\n"))}
    end

  end
end