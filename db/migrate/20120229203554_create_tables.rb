class CreateTables < ActiveRecord::Migration
  def self.up
    create_table(:people, :force => true) do |t|
      t.column :first_name, :string
      t.column :last_name, :string
      t.column :ssn, :string, :limit => 64
    end

    create_table(:places, :force => true) do |t|
      t.column :address, :text
      t.column :city, :string
      t.column :state, :string
      t.column :country, :string, :limit => 2
    end

    create_table(:person_dimension, :force => true) do |t|
      t.column :first_name, :string, :limit => 50
      t.column :last_name, :string, :limit => 50
      t.column :address, :string, :limit => 100
      t.column :city, :string, :limit => 50
      t.column :state, :string, :limit => 50
      t.column :zip_code, :string, :limit => 20

      t.column :effective_date, :timestamp
      t.column :end_date, :timestamp
      t.column :latest_version, :boolean
    end

    create_table(:truncate_test, :force => true) do |t|
      t.column :x, :string, :limit => 4
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
