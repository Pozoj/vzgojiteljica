class KeywordablesIdsToInteger < ActiveRecord::Migration
  def change
    if Rails.env.development?
      change_column :keywordables, :article_id, :integer
      change_column :keywordables, :keyword_id, :integer
    elsif Rails.env.production?
      execute %{ALTER TABLE "keywordables" ALTER COLUMN article_id TYPE integer USING CAST(CASE article_id WHEN '' THEN NULL ELSE article_id END AS INTEGER)}
      execute %{ALTER TABLE "keywordables" ALTER COLUMN keyword_id TYPE integer USING CAST(CASE keyword_id WHEN '' THEN NULL ELSE keyword_id END AS INTEGER)}
    end
  end
end
