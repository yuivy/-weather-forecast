class AddPrefectureToUsers < ActiveRecord::Migration[5.2]

  def change
    add_column :users, :prefecture_id, :integer
  end
end
