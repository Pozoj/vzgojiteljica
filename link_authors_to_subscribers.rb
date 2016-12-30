# Link Authors to Subscribers

Author.all.each do |author|
  name_wildcard = author.name.split(' ').join('%')
  subscriber = Subscriber.where(
    Subscriber.arel_table[:name].matches("%#{name_wildcard}%")
    .or(Subscriber.arel_table[:title].matches("%#{name_wildcard}%"))
  )

  next unless subscriber.any?

  author.subscriber = subscriber.first
  author.save!
end
