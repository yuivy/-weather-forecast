class CreatePrefectures < ActiveRecord::Migration[5.2]
  def change
    create_table :prefectures do |t|
      t.string :name
      t.string :code
      t.string :region_name
      t.timestamps
    end
  end
end
