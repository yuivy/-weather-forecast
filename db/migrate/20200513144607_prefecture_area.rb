class PrefectureArea < ActiveRecord::Migration[5.2]
  def up
    add_column :prefectures, :area, :string, after: :region_name
  end

  def down
    remove_column :prefectures, :area, :string
  end
end