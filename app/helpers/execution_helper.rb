module ExecutionHelper
  def parse_exception_to_error(exception)
    exception.split(/^\s*(_\s?)+\s*$/).last.split("\n").collect{|line| line if line =~/^E\s*.*/ }.join("\n").strip()
  end

  def parse_exception_to_user_case(exception)
    result=""
    return result if !exception
    isInclude=false
    exception.split(/^\s*(_\s?)+\s*$/)[0].split("\n").each{|line|

        isInclude=true if line =~ /^\s*(@pytest.mark|def).*$/
        result=result+"\n"+line if isInclude
    }
    result
    #exception.split(/^\s*(_\s?)+\s*$/)[0].include?('@pytest') ? exception.split(/^\s*(_\s?)+\s*$/)[0].gsub(exception.match(/(^[^\-]*?)@pytest/)[1],'').gsub(/^@pytest/,exception.split(/^\s*(_\s?)+\s*$/)[0].match(/^.*?@pytest/)[0]) : exception.split(/^\s*(_\s?)+\s*$/)[0].gsub(exception.match(/(^[^\-]*?)def\s/)[1],'').gsub(/^def\s/,exception.split(/^\s*(_\s?)+\s*$/)[0].match(/^.*?def\s/)[0])
  end
end
