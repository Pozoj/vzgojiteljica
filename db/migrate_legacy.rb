# Avtorji to Authors
class LegacyAvtorji < ActiveRecord::Base; set_table_name 'avtorji'; end
LegacyAvtorji.all.each do |avtor|
  author = Author.new(
    id: avtor.id,
    first_name: avtor.ime,
    last_name: avtor.priimek,
    address: avtor.naslov,
    post_id: avtor.postna_st,
    email: avtor.email,
    notes: avtor.opomba,
    institution: Institution.find_or_create_by_name(avtor.ustanova),
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
class LegacyIndeks < ActiveRecord::Base; set_table_name 'indeks'; end
index_copy = Indeks.first
copy = Copy.new page_code: 'pages#index', copy_html: index_copy.vsebina
if copy.save
  print '*'
else
  print "IND[#{index_copy.id}]"
end

# Revije to Issues
class LegacyRevije < ActiveRecord::Base; set_table_name 'revije'; end
LegacyRevije.all.each do |revija|
  # Download files.
  # if revija.slika.present?
  #   begin
  #     slika = open("#{vzgojiteljica_upload_root}/naslovnice/#{revija.slika}")
  #   rescue
  #     puts "REV[#{revija.id}][IMG]"
  #   end
  # end
  # if revija.pdf_link.present?
  #   begin
  #     pdf_link = open("#{vzgojiteljica_upload_root}/pdf/#{revija.pdf_link}")
  #   rescue
  #     puts "REV[#{revija.id}][PDF]"
  #   end
  # end

  issue = Issue.new(
    id: revija.id,
    year: revija.letnik,
    issue: revija.stevilka,
    published_at: revija.datum_i,
    keywords: revija.kljucne
  )

  if issue.save
    print '*'
  else
    print "REV[#{revija.id}]"
  end
end

# Rubrike to Sections
class LegacyRubrike < ActiveRecord::Base; set_table_name 'rubrike'; end
LegacyRubrike.all.each do |rubrika|
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
class LegacyVsebina < ActiveRecord::Base; set_table_name 'vsebina'; end
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
end