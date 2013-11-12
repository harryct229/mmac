require File.dirname( __FILE__ ) + "/rule"
require 'set'
require 'pry'
require 'ruby-progressbar'
module Mmac
  #
  # Main Manager for MMac (contains all options, rules, ...)
  #
  #
  class Framework

    # @return input file
    #
    attr_accessor :inputFile

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
    attr_accessor :level


    def initialize inputFile, minSupp, minConf
      @inputFile = inputFile
      @data = []
      @rules = []
      @filters = []
      @filtersPrint = []
      @minSupp = minSupp
      @minConf = minConf
      @level = 0

      puts 'Input from file...'
      parse_data(inputFile)
      @attrCount = @data.first.conditions.count
      puts ("Number of data: " + "#{@data.count}")
      puts ("Number of attr: " + "#{@attrCount}")
    end

    def run
      puts 'Learning...'
      self.normalize
      puts 'Done!'
      # Write to Filter file
      File.open(File.dirname(@inputFile) + '/filter.txt', 'w') {|f| f.write(@filtersPrint.map{|p| p.conditions.join(",") + "," +  p.labels}.join("\n"))}
    end

    def parse_data inputFile
      line_array = File.readlines(inputFile)
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
      @level = @level + 1
      puts ("Level " + "#{@level}")

      1.upto(attrCount).flat_map do |n|
        rules = []
        filterCount = filterSet.count
        @data.each do |data|
          conditions = data.conditions
          label      = data.labels

          # All combinations with n attrs
          combinations = conditions.combination(n).to_a

          # bList = blackList.map {|b| b.conditions if b.labels == label}.compact
          # rules += combinations.select{|c| !(c - bList).empty?}.map{|c| Rule.new(c, label)} # Remove all combinations that in blacklist
          rules += combinations.map{|c| Rule.new(c, label)} # Remove all combinations that in blacklist
        end

        # collect conditions without dup
        conRules = rules.map{|r| r.conditions}.to_set

        # Log using progressbar
        progressbar = ProgressBar.create(:title => "N = #{n}", :starting_at => 0, :total => conRules.count, :length => 100)

        conRules.each do |c|
          # increase
          progressbar.increment

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

      # Log Number of rule in level
      puts ("Number of rules: " + "#{filterSet.count}")
      # recursive until Data empty
      if !@data.empty? && !filterSet.empty?
        self.normalize
      end

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
      File.open(File.dirname(sample_file) + '/testOut.txt', 'w') {|f| f.write(test.map{|p| p.conditions.map{|c| c[1]}.join(",") + "," +  p.labels}.join("\n"))}
    end

  end
end