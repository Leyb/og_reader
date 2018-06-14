class NewStoriesTable < ActiveRecord::Migration[5.1]

  def up

    create_table :stories do |t|
      t.string :canonical_url,  null: false
      t.timestamps null: true
    end

  end

  def down
    drop_table :stories
  end

end
