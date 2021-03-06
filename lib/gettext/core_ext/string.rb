# encoding: utf-8

=begin
  string.rb - Extension for String.

  Copyright (C) 2005-2009 Masao Mutoh

  You may redistribute it and/or modify it under the same
  license terms as Ruby or LGPL.
=end

# Extension for String class. This feature is included in Ruby 1.9 or later but not occur TypeError.
#
# String#% method which accept "named argument". The translator can know
# the meaning of the msgids using "named argument" instead of %s/%d style.
class String

  unless instance_methods.find {|m| m.to_s == 'bytesize'}
    # For older ruby (such as ruby-1.8.5)
    alias :bytesize :size
  end

  begin
    formatted = "%{key}" % {:key => "value"}
    raise ArgumentError if formatted != "value"
  rescue ArgumentError
    alias :_old_format_m :% # :nodoc:

    PERCENT_MATCH_RE = Regexp.union(
        /%%/,
        /%\{(.+?)\}/,
        /%<(.+?)>(.*?\d*\.?\d*[bBdiouxXeEfgGcps])/
    )

    # call-seq:
    #  %(arg)
    #  %(hash)
    #
    # Format - Uses str as a format specification, and returns the result of applying it to arg.
    # If the format specification contains more than one substitution, then arg must be
    # an Array containing the values to be substituted. See Kernel::sprintf for details of the
    # format string. This is the default behavior of the String class.
    # * arg: an Array or other class except Hash.
    # * Returns: formatted String
    #
    #  (e.g.) "%s, %s" % ["Masao", "Mutoh"]
    #
    # Also you can use a Hash as the "named argument". This is recommanded way for Ruby-GetText
    # because the translators can understand the meanings of the msgids easily.
    # * hash: {:key1 => value1, :key2 => value2, ... }
    # * Returns: formatted String
    #
    #  (e.g.)
    #         For strings.
    #         "%{firstname}, %{familyname}" % {:firstname => "Masao", :familyname => "Mutoh"}
    #
    #         With field type to specify format such as d(decimal), f(float),...
    #         "%<age>d, %<weight>.1f" % {:age => 10, :weight => 43.4}
    def %(args)
      if args.kind_of?(Hash)
        ret = dup
        ret.gsub!(PERCENT_MATCH_RE) {|match|
          if match == '%%'
            '%'
          elsif $1
            key = $1.to_sym
            args.has_key?(key) ? args[key] : match
          elsif $2
            key = $2.to_sym
            args.has_key?(key) ? sprintf("%#{$3}", args[key]) : match
          end
        }
        ret
      else
        ret = gsub(/%([{<])/, '%%\1')
        begin
          ret._old_format_m(args)
        rescue ArgumentError => e
          if $DEBUG
            $stderr.puts "  The string:#{ret}"
            $stderr.puts "  args:#{args.inspect}"
            puts e.backtrace
          else
            raise ArgumentError, e.message
          end
        end
      end
    end
  end
end

