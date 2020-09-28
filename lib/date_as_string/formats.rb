module DateAsString
  module Formats
    def self.find_format(format_string)
      case format_string
      when :mm_dd_yyyy
        Format1
      when :mm_dd_yy
        Format2
      when :mmddyyyy
        Format3
      when :mmddyy
        Format4
      when :t_pmd
        Format5
      else
        raise TypeError.new("Format does not exist: #{format_string}")
      end
    end
    
    #mm_dd_yyyy
    class Format1
      def self.strftime(value)
        value.strftime('%m/%d/%Y')
      end
    end
    
    #mm_dd_yy
    class Format2
      def self.strftime(value)
        value.strftime('%m/%d/%y')
      end
    end
    
    #mmddyyyy
    class Format3
      def self.strftime(value)
        value.strftime('%m%d%Y')
      end
    end
    
    #mmddyy
    class Format4
      def self.strftime(value)
        value.strftime('%m%d%y')
      end
    end
    
    #t_pmd
    class Format5
      def self.strftime(value)
        raise NotImplementedError.new
      end
    end
  end
end