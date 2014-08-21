module ExecutionHelper
  def parse_exception_to_error(exception)
    return "" if !exception
    isInclude = false
    exception.split(/^\s*(_\s?)+\s*$/).last.split("\n").collect{|line|
      isInclude = true if line =~/^E\s*.*/
      line if isInclude
    }.join("\n").strip()
  end

  def parse_exception_to_user_case(exception)
    return "NO exception" if !exception
    isInclude = false
    lastLine = false
    exception.split(/^\s*(_\s?)+\s*$/)[0].split("\n").collect{|line|

        isInclude=true if line =~ /^\s*(@pytest.mark|def).*$/
        if line =~ /^\s*>/
          isInclude = false
          lastline = true
        end
        line if isInclude || lastline
    }.join("\n").strip()
  end

end
