class PdfGenerator
  def initialize
    @client = Pdfcrowd::Client.new(ENV['PDFCROWD_USERNAME'], ENV['PDFCROWD_TOKEN'])
    @client.setPageWidth('210mm')
    @client.setPageHeight('297mm')
  end

  def convert_url(url)
    client.convertURI(url)
  end

  def save_url_to_file(url, file_path)
    pdf = convert_url(url)
    File.open(file_path, 'w') { |f| f.write(pdf) }
  end
end