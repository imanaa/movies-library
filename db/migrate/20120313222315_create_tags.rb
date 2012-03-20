class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :value
      t.references :movie

      t.timestamps
    end
    add_index :tags, :movie_id
  end
end
