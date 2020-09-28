module DateAsString
  module VERSION
    MAJOR = 0
    MINOR = 1
    TINY  = 0
    PRE   = nil

    STRING = [MAJOR, MINOR, TINY, PRE].compact.join('.')

    SUMMARY = "date_as_string #{STRING}"
  end
end
