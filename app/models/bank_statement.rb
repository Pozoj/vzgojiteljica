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

  validates_attachment_content_type :statement, content_type: 'application/octet-stream'

  has_many :entries, class_name: 'StatementEntry', dependent: :destroy

  before_save :store_raw_statement
  after_create :parse!

  def parse!
    return unless parsed_mt940

    parsed_mt940.each_with_index do |entry, index|
      next unless entry.is_a?(MT940::StatementLine)
      next if entry.funds_code != :credit
      next unless entry_info = parsed_mt940[index+1]
      next unless entry_info.is_a?(MT940::StatementLineInformation)

      # Uniqueness
      next if StatementEntry.exists?(reference: entry.reference) # A pending statement entry exists.
      next if Invoice.exists?(bank_reference: entry.reference) # An invoice has already been matched with this entry.

      statement_entry = entries.build
      statement_entry.account_holder = entry_info.account_holder
      statement_entry.account_number = entry_info.account_number
      statement_entry.details = entry_info.details
      statement_entry.amount = entry.amount
      statement_entry.date = entry.date
      statement_entry.reference = entry.reference
      statement_entry.save!
    end
  end

  def parsed_mt940
    return unless parsed_statement?
    @parsed_mt940 ||= MT940.parse(parsed_statement).first
  end

  def parse_statement(raw)
    return unless raw
    raw.lines.reject { |line| line =~ /F01BACXSI22AXXX0000000000/ || line =~ /\-}/ }.join
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