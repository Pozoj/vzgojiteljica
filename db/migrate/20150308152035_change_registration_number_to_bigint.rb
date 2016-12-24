# frozen_string_literal: true
class ChangeRegistrationNumberToBigint < ActiveRecord::Migration
  def change
    # Postgres:
    Entity.connection.execute <<-SQL
      ALTER TABLE entities
      ALTER COLUMN registration_number TYPE bigint USING registration_number::bigint
    SQL
  end
end
