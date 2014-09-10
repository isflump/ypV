module SessionHelper

  def parse_date(date)
    Time.parse(date).strftime('%Y-%m-%d %H:%M:%S')
  end

  def parse_month(key)
    return Date::MONTHNAMES[key][0...3]
  end

  def parse_day(d_key)
    return d_key if d_key >= 10
    return "0#{d_key}"
  end

  def parse_time(time)
    temp = time.gsub(/.*_/,"")
    temp[0..1]+":"+temp[2..3]+":"+temp[4..5]
  end

end
