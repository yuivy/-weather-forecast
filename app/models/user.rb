class User < ApplicationRecord
  belongs_to :prefecture, optional: true
end