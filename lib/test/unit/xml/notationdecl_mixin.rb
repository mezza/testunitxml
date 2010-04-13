module REXML

  # The REXML::NotationDecl mix-in adds methods that are useful for
  # notation declarations, but not present in the standard
  # REXML::NotationDecl class
  class NotationDecl
    
    # This method retrieves the name of the notation.
    def name
      @name
    end
    
    # This method retrieves the system identifier specified in the notation
    # declaration. If there is no system identifier defined, the method returns
    # +nil+
    def system
      parse_rest(@rest)[1]
    end
    
    # This method retrieves the public identifier specified in the notation
    # declaration. If there is no public identifier defined, the method returns
    # +nil+
    def public
      return nil unless @middle == "PUBLIC"
      parse_rest(@rest)[0]
    end
    
    private
    
    def parse_rest(rest)
      case rest
      when /^"([^"]+)"\s+"([^"]+)"$/
        return [$1,$2]
      when /^'([^']+)'\s+'([^']+)'$/
        return [$1,$2]
      when /^"([^"]+)"\s+'([^']+)'$/
        return [$1,$2]
      when /^'([^']+)'\s+"([^"]+)"$/
        return [$1,$2]
      when /^"([^"]+)"$/
        return [nil, $1] if @middle == 'SYSTEM'
        return [$1, nil] if @middle == 'PUBLIC'
        raise "Unknown notation keyword: #{@middle}"
      when /^'([^']+)'$/
        return [nil, $1] if @middle == 'SYSTEM'
        return [$1, nil] if @middle == 'PUBLIC'
        raise "Unknown notation keyword: #{@middle}"
      else
        raise "Could not parse \@rest variable in REXML::NotationDecl: |#{@rest}|"
      end
    end
  end

end