class BankStatement < ActiveRecord::Base
  has_attached_file :statement,
                    :whiny => false,
                    :storage => :s3,
                    :bucket => AWS_S3['bucket'],
                    :s3_credentials => {
                      :access_key_id => AWS_S3['access_key_id'],
                      :secret_access_key => AWS_S3['secret_access_key']
                    },
                    :s3_storage_class => :reduced_redundancy,
                    :path => "/bank_statements/:id/:style_:basename.:extension"

  validates_attachment_content_type :statement, content_type: 'text/plain'

  has_many :entries, class_name: 'StatementEntry', dependent: :destroy

  before_save :store_raw_statement
  after_create :parse!

  def parse!
    return unless parsed_mt940

    parsed_mt940.each do |statement|
      statement.transactions.each do |entry|
        next unless entry.credit?

        # Uniqueness
        next if StatementEntry.exists?(reference: entry.reference) # A pending statement entry exists.
        next if Invoice.exists?(bank_reference: entry.reference) # An invoice has already been matched with this entry.

        statement_entry = entries.build
        statement_entry.account_holder = entry.details.entity
        statement_entry.account_number = entry.iban
        statement_entry.amount = entry.amount
        statement_entry.date = entry.date
        statement_entry.reference = entry.details.reference
        statement_entry.save!
      end
    end
  end

  def parsed_mt940
    return unless parsed_statement?
    @parsed_mt940 ||= Cmxl.parse(raw_statement)
  end

  def parse_statement(raw)
    return unless raw
    raw.lines.reject { |line| line =~ /F01BACXSI22AXXX0000000000/ || line =~ /F21HALCOMXXXXXX0000000000/ || line =~ /\-}/ }.join
  end

  private

  def store_raw_statement
    return if parsed_statement?
    return if raw_statement?

    # Store raw statement
    self.raw_statement = Paperclip.io_adapters.for(statement).read
      
    # Parse if we have the raw statement now
    return unless raw_statement
    self.parsed_statement = parse_statement(raw_statement)
  end
end