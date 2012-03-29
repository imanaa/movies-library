class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies do |t|
      t.string :title
      t.references :location
      t.string :folder_name
      t.string :poster
      t.integer :rank, :default=>0
      t.integer :seen, :default=>0
      t.integer :year, :default=>nil
      t.boolean :online, :default=>true

      t.timestamps
    end
    add_index :movies, :location_id
  end
end
