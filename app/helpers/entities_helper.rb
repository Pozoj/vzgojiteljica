module EntitiesHelper
  def pluralize_days(days)
    case days
    when 0
      '0 dnevi'
    when 1
      '1 dnevom'
    when 2
      '2 dnevoma'
    else
      "#{days} dnevi"
    end
  end
end
