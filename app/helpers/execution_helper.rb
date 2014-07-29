module ExecutionHelper
  def parse_exception_to_user_case(exception)
    result=""
    exception.split("\n").each{|line|
        if line.empty?
          result=result+"\n"
          next
        end
        break if line.match(/^\s*(_\s?)+\s*$/)
        result=result+"\n"+line
    }
    result
  end
end
