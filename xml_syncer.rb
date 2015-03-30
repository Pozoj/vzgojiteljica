DIR1 = '/Users/mihar/Downloads/einvoices-1427088532'
DIR2 = '/Users/mihar/Downloads/einvoices-1427128192'

require 'fileutils'

Dir.glob("#{DIR2}/*.xml") do |xml|
  moved = false
  invoice_id = File.basename(xml).gsub('.xml', '')
  if Dir.glob("#{DIR1}/ACCEPTED").find { |f| f =~ Regexp.new(invoice_id) }
    moved = true
    FileUtils.mv(xml, "#{DIR1}/#{File.basename(xml)}")
  end

  p [invoice_id, moved]
  sleep 5
end
