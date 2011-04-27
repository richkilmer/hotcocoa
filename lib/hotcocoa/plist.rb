module HotCocoa

  def read_plist(data, mutability=:all)
    mutability = case mutability
      when :none
        NSPropertyListImmutable
      when :containers_only
        NSPropertyListMutableContainers
      when :all
        NSPropertyListMutableContainersAndLeaves
      else
        raise ArgumentError, "invalid mutability `#{mutability}'"
    end

    if data.is_a?(String)
      data = data.dataUsingEncoding(NSUTF8StringEncoding)
      if data.nil?
        raise ArgumentError, "cannot convert string `#{data}' to data"
      end
    end

    # TODO retrieve error description and raise it if there is an error.
    NSPropertyListSerialization.propertyListFromData(data,
                                    mutabilityOption:mutability,
                                              format:nil,
                                    errorDescription:nil)
  end
end


module Kernel

  ##
  # A mapping, lol
  PLIST_FORMATS = {
    xml:    NSPropertyListXMLFormat_v1_0,
    binary: NSPropertyListBinaryFormat_v1_0
  }

  ##
  # @todo encoding format can be pushed upstream?
  #
  # override macruby's built-in {kernel#to_plist} method to support
  # specifying an output format. see {plist_formats} for the available
  # formats.
  #
  # @example encoding a plist in the binary format
  #  { key: 'value' }.to_plist(:binary)
  #
  # @return [String] returns `self` serialized as a plist and encoded
  #  using `format`
  def to_plist format = :xml
    format_const = PLIST_FORMATS[format]
    raise ArgumentError, "invalid format `#{format}'" unless format_const

    error = Pointer.new(:id)
    data  = NSPropertyListSerialization.dataFromPropertyList  self,
                                                      format: format_const,
                                            errorDescription: error
    error[0] ? raise( Exception, error[0] ) : data.to_str
  end

end
