module SessionHelper

  def parse_month(key)
    return Date::MONTHNAMES[key][0...3]
  end

  def parse_day(d_key)
    return d_key if d_key > 10
    return "0#{d_key}"
  end

  def parse_time(time)
    time.gsub(/.*_/,"")
  end

end
