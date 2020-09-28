require "date_as_string/version"

require "date_as_string/formats"

module DateAsString
  def self.guess_century(year, cutoff=20)
    century = get_century_from_year_range(year, cutoff)

    century.present? ? century : raise_century_error
  end

  def self.included(base)
    base.send(:extend, DateAsString::ClassMethods)
  end

  def self.parse_date(date)
    date.respond_to?(:strftime) ? date.strftime('%m/%d/%Y') : nil
  end

  def self.parse_string(date_string)
    begin
      case
      when t_regex.match(date_string)
        date_for_t_match(date_string)
      when mmddyy_regex.match(date_string)
        date_for_mmddyy_match(date_string)
      when mmddyy_regex(with_slashes: true).match(date_string)
        date_for_mmddyy_match(date_string, with_slashes: true)
      when mmddyyyy_regex.match(date_string)
        date_for_mmddyyyy_match(date_string)
      when mmddyyyy_regex(with_slashes: true).match(date_string)
        date_for_mmddyyyy_match(date_string, with_slashes: true)
      else
        nil
      end
    rescue
      nil
    end
  end

  module ClassMethods
    def date_as_string(*args)
      defaults = {:input_formats => [:mm_dd_yyyy, :mm_dd_yyyy, :mmddyyyy, :mmddyy, :t_pmd],
                  :default_display_format => :mm_dd_yyyy,
                  :century_cutoff => 20,
                  :default => nil}
      options = args.last.is_a?(Hash) ? defaults.merge(args.pop) : defaults

      #We're current not doing anything with the options...
      #We should support default formats, default value, and allowable formats...

      unless self.respond_to?(:date_as_string_options)
        cattr_accessor :date_as_string_options
        self.date_as_string_options = {}
      end

      args.each do |attribute_name|
        self.date_as_string_options[attribute_name] = options

        validate :"#{attribute_name}_format"

        define_method "#{attribute_name}_string" do |*display_format|
          if instance_variable_get("@#{attribute_name}_string")
            instance_variable_get("@#{attribute_name}_string")
          else
            if self.send("#{attribute_name}").nil?
              if options[:default] && options[:default].is_a?(String)
                eval(options[:default])
              elsif options[:default] && options[:default].is_a?(Proc)
                options[:default].call
              else
                nil
              end
            else
              #self.send("#{attribute_name}").strftime('%m/%d/%Y')
              unless display_format.empty?
                DateAsString::Formats.find_format(display_format[0]).strftime(self.send("#{attribute_name}"))
              else
                DateAsString::Formats.find_format(options[:default_display_format]).strftime(self.send("#{attribute_name}"))
              end
            end
          end
        end

        define_method "#{attribute_name}_string=" do |str|
          instance_variable_set("@#{attribute_name}_string", str)
          self.send("#{attribute_name}=", DateAsString.parse_string(str))
        end

        define_method "#{attribute_name}_format" do
          re = /^(([tT]([\-\+]\d+)?)|(\d{6})|(\d{8})|([0-1]?\d\/[0-3]?\d\/\d\d)|([0-1]?\d\/[0-3]?\d\/(19|20)\d\d))$/

          attribute_string = instance_variable_get("@#{attribute_name}_string")

          #No string was entered - this clears the date
          return if attribute_string.blank?

          #the entered string did not match a regex...
          if (attribute_string =~ re).nil?
            errors.add("#{attribute_name}_string", "must be in the format of MM/DD/YY, MM/DD/YYYY, MMDDYY, MMDDYYYY or t, t+#, t-#")
            return
          end

          #The mapping did not work for some reason...
          if self.send("#{attribute_name}").nil?
            errors.add("#{attribute_name}_string", :invalid)
          end
        end
      end
    end
  end

  private

  def self.year_range(cutoff)
    current_year = Time&.zone&.today&.year || Date.today.year

    range_start = current_year - (99 - cutoff)
    range_end = current_year + cutoff

    range_start..range_end
  end

  def self.get_century_from_year_range(year, cutoff=20)
    year_range(cutoff).detect { |temp_year| temp_year % 100 == year }
  end

  def self.raise_century_error
    raise RangeError.new('Error converting year...')
  end

  def self.t_regex
    /^[tT]((?<operator>[\-\+])(?<days_count>\d+))?$/
  end

  #Allow MMDDYY or MM/DD/YY
  def self.mmddyy_regex(options={})
    with_slashes = options.fetch(:with_slashes, false)

    slash_str = with_slashes ? '/' : nil
    month_str = '(?<month>[0-1]?\d)'
    day_str = '(?<day>[0-3]?\d)'
    year_str =  '(?<year>\d{2})'

    date_tup = [month_str, day_str, year_str]
    slashes = [slash_str]*2

    inner_regex = date_tup.zip(slashes)
                          .flatten
                          .compact
                          .join

    /^#{inner_regex}$/
  end

  #Allow MMDDYYYY or MM/DD/YYYY
  def self.mmddyyyy_regex(options={})
    with_slashes = options.fetch(:with_slashes, false)

    slash_str = with_slashes ? '/' : nil
    month_str = '(?<month>[0-1]?\d)'
    day_str = '(?<day>[0-3]?\d)'
    year_str =  '(?<year>\d{4})'

    date_tup = [month_str, day_str, year_str]
    slashes = [slash_str]*2

    inner_regex = date_tup.zip(slashes)
                          .flatten
                          .compact
                          .join

    /^#{inner_regex}$/
  end

  # matches:
  #   e.g.)
  #     t   => Date.today
  #     t+7 => Date.today + 1.week
  #     t-1 => Date.today - 1.day
  def self.date_for_t_match(date_string)
    today = Time&.zone&.today || Date.today

    t_regex.match(date_string) do |match_data|
      operator, days_count = *[match_data[:operator], match_data[:days_count]]

      operator ? today.send(operator, days_count.to_i) : today
    end
  end

  def self.date_for_mmddyy_match(date_string, options={})
    slashy_regex = options.fetch(:with_slashes, false)
    month, day, year = nil, nil, nil

    mmddyy_regex(with_slashes: slashy_regex).match(date_string) do |match_data|
      month = match_data[:month] ? match_data[:month] : date_string[0..1]
      day = match_data[:day] ? match_data[:day] : date_string[2..3]
      year = match_data[:year] ? match_data[:year] : date_string[4..5]

      century = DateAsString.guess_century(year.to_i)

      Date.civil(century, month.to_i, day.to_i)
    end
  end

  def self.date_for_mmddyyyy_match(date_string, options={})
    slashy_regex = options.fetch(:with_slashes, false)
    month, day, year = nil, nil, nil

    mmddyyyy_regex(with_slashes: slashy_regex).match(date_string) do |match_data|
      month = match_data[:month] ? match_data[:month] : date_string[0..1]
      day = match_data[:day] ? match_data[:day] : date_string[2..3]
      year = match_data[:year] ? match_data[:year] : date_string[4..5]

      Date.civil(year.to_i, month.to_i, day.to_i)
    end
  end
end

if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, DateAsString)
end
