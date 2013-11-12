module Mmac
  #
  # Main Data/Rule for MMac (in here is mushroom, ...)
  #
  #
  class Rule
    #
    # @return Array of conditions
    #
    attr_accessor :conditions
    #
    # @return array of labels: result of these conditions
    #
    attr_accessor :labels
    #
    # @return Supp of rule
    #
    attr_accessor :supp
    #
    # @return Conf of rule
    #
    attr_accessor :conf
    #
    # @return actOccr
    #
    attr_accessor :actOccr

    def initialize (conditions, labels, *option)
      @conditions = conditions
      @labels = labels
      if !option.empty?
        @supp = option[0]
        @conf = option[1]
        @actOccr = option[2]
      end
    end

    def ==(other)
      self.conditions == other.conditions && self.labels == other.labels
    end

  end
end