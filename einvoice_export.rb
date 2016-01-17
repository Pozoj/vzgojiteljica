require 'fileutils'

files = []
directory_name = "einvoices-#{DateTime.now.to_i}"
directory = "./#{directory_name}"
FileUtils.mkdir_p directory

Invoice.where('id >= 1771').each do |invoice|
  next unless invoice.customer.einvoice?

  xml_filename = "#{invoice.receipt_id}.xml"
  File.open("#{directory}/#{xml_filename}", 'w') { |f| f.write(invoice.einvoice_xml) }
  files << xml_filename

  pdf_filename = "#{invoice.receipt_id}.pdf"
  File.open("#{directory}/#{xml_filename}", 'w') { |f| f.write(invoice.pdf) }
  files << pdf_filename
end;0

p files

require 'zip'

zipfile_base = "#{directory_name}.zip"
zipfile_name = "#{directory}.zip"

Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
  files.each do |filename|
    # Two arguments:
    # - The name of the file as it will appear in the archive
    # - The original file, including the path to find it
    zipfile.add(filename, directory + '/' + filename)
  end
end

require 'fog'
connection = Fog::Storage.new({
  :provider                 => 'AWS',
  :aws_access_key_id        => ENV['AWS_ACCESS_KEY_ID'],
  :aws_secret_access_key    => ENV['AWS_SECRET_ACCESS_KEY']
})

directory = connection.directories.get(ENV['FOG_DIRECTORY'])

file = directory.files.create(
  :key    => zipfile_base,
  :body   => File.open(zipfile_name),
  :public => false
)
