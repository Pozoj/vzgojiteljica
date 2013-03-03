vzgojiteljica_upload_root = 'http://new.vzgojiteljica.si/upload'

Rails.logger = Logger.new(STDOUT)

class LegacyDb < ActiveRecord::Base
  self.abstract_class = true
  establish_connection adapter: 'mysql2', database: 'vzgojiteljica_new'
end

# Avtorji to Authors
class LegacyAvtorji < LegacyDb; self.table_name = "avtorji"; end
puts
puts
puts '##### AVTORJI -> AUTHORS ' + LegacyAvtorji.count.to_s
LegacyAvtorji.all.each do |avtor|
  next if Author.exists?(avtor.id)
  author = Author.new(
    id: avtor.id,
    first_name: avtor.ime,
    last_name: avtor.priimek,
    address: avtor.naslov,
    post_id: avtor.postna_st,
    email: avtor.email,
    notes: avtor.opomba,
    institution: avtor.ustanova.present? ? Institution.find_or_create_by(name: avtor.ustanova) : nil,
    phone: avtor.telefon,
    title: avtor.funkcija,
    education: avtor.izobrazba
  )

  if author.save
    print '*'
  else
    print "AVT[#{avtor.id}]"
  end
end

# Indeks to Copy
class LegacyIndeks < LegacyDb; self.table_name = "indeks"; end
puts
puts
puts '##### INDEKS -> COPY'
index_copy = LegacyIndeks.first
unless LegacyIndeks.any?
  copy = Copy.new page_code: 'pages#index', copy_html: index_copy.vsebina
  if copy.save
    print '*'
  else
    print "IND[#{index_copy.id}]"
  end
end

# Rubrike to Sections
class LegacyRubrike < LegacyDb; self.table_name = "rubrike"; end
puts
puts
puts '##### RUBRIKE -> SECTIONS ' + LegacyRubrike.count.to_s
LegacyRubrike.all.each do |rubrika|
  next if Section.exists?(rubrika.id)
  section = Section.new(
    id: rubrika.id,
    name: rubrika.naziv,
    position: rubrika.vrstni_red
  )

  if section.save
    print '*'
  else
    print "RUB[#{rubrika.id}]"
  end
end

# Vsebina to Articles
class LegacyVsebina < LegacyDb; self.table_name = "vsebina"; end
puts
puts
puts '##### VSEBINA -> ARTICLE ' + LegacyVsebina.count.to_s
LegacyVsebina.all.each do |vsebina|
  article = Article.new(
    author_id: vsebina.avtor_id,
    section_id: vsebina.rubrika_id,
    issue_id: vsebina.revija_id,
    title: vsebina.naziv,
    abstract: vsebina.povzetek,
    abstract_html: vsebina.povzetek,
    abstract_english: vsebina.povzetek_ang,
    abstract_english_html: vsebina.povzetek_ang,
    keywords: vsebina.kljucne
  )

  if article.save
    print '*'
  else
    print "VSE[#{vsebina.id}]"
  end
end

# Revije to Issues
class LegacyRevije < LegacyDb; self.table_name = "revije"; end
puts
puts
puts '##### REVIJE -> ISSUES ' + LegacyRevije.count.to_s
LegacyRevije.all.each do |revija|
  next if Issue.exists?(revija.id)
  issue = Issue.new(
    id: revija.id,
    year: revija.letnik,
    issue: revija.stevilka,
    published_at: revija.datum_i,
    keywords: revija.kljucne
  )

  # Download files.
  if revija.slika.present?
    begin
      url = URI.escape "#{vzgojiteljica_upload_root}/naslovnice/#{revija.slika}"
      if slika = open(url)
        print "S"
        issue.cover = slika
        issue.cover_file_name = revija.slika
      end
    rescue Error => e
      puts "REV[#{revija.id}][IMG]"
      puts e.inspect
      puts url
    end
  end
  if revija.pdf_link.present?
    begin
      url = URI.escape "#{vzgojiteljica_upload_root}/pdf/#{revija.pdf_link}"
      if pdf_link = open(url)
        print "P"
        issue.document = pdf_link
        issue.document_file_name = revija.pdf_link
      end
    rescue Error => e
      puts "REV[#{revija.id}][PDF]"
      puts e.inspect
      puts url
    end
  end

  if issue.save
    print '*'
  else
    print "REV[#{revija.id}]"
  end
end