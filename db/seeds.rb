# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Prefecture.create(name: "北海道", code: "01")
Prefecture.create(name: "青森", code: "02")
Prefecture.create(name: "岩手", code: "03")
Prefecture.create(name: "宮城", code: "04")
Prefecture.create(name: "秋田", code: "05")
Prefecture.create(name: "山形", code: "06")
Prefecture.create(name: "福島", code: "07")
Prefecture.create(name: "茨城", code: "08")
Prefecture.create(name: "栃木", code: "09")
Prefecture.create(name: "群馬", code: "10")
Prefecture.create(name: "埼玉", code: "11")
Prefecture.create(name: "千葉", code: "12")
Prefecture.create(name: "東京", code: "13")
Prefecture.create(name: "神奈川", code: "14")
Prefecture.create(name: "新潟", code: "15")
Prefecture.create(name: "富山", code: "16")
Prefecture.create(name: "石川", code: "17")
Prefecture.create(name: "福井", code: "18")
Prefecture.create(name: "山梨", code: "19")
Prefecture.create(name: "長野", code: "20")
Prefecture.create(name: "岐阜", code: "21")
Prefecture.create(name: "静岡", code: "22")
Prefecture.create(name: "愛知", code: "23")
Prefecture.create(name: "三重", code: "24")
Prefecture.create(name: "滋賀", code: "25")
Prefecture.create(name: "京都", code: "26")
Prefecture.create(name: "大阪", code: "27")
Prefecture.create(name: "兵庫", code: "28")
Prefecture.create(name: "奈良", code: "29")
Prefecture.create(name: "和歌山", code: "30")
Prefecture.create(name: "鳥取", code: "31")
Prefecture.create(name: "島根", code: "32")
Prefecture.create(name: "岡山", code: "33")
Prefecture.create(name: "広島", code: "34")
Prefecture.create(name: "山口", code: "35")
Prefecture.create(name: "徳島", code: "36")
Prefecture.create(name: "香川", code: "37")
Prefecture.create(name: "愛媛", code: "38")
Prefecture.create(name: "高知", code: "39")
Prefecture.create(name: "福岡", code: "40")
Prefecture.create(name: "佐賀", code: "41")
Prefecture.create(name: "長崎", code: "42")
Prefecture.create(name: "熊本", code: "43")
Prefecture.create(name: "大分", code: "44")
Prefecture.create(name: "宮崎", code: "45")
Prefecture.create(name: "鹿児島", code: "46")
Prefecture.create(name: "沖縄", code: "47")

# ①これを47こ登録

# ②rails db:seedを実行

# ③seedファイルに書かれているデータがdbに登録される

# ④userデータを登録するときにprefectureテーブルのnameカラムに対して都道府県名で検索

# ⑤都道府県名を取得できたらPrefecturesテーブルのidをUsersテーブルに保存

# ⑥天気予報の情報を取得するには対象のユーザーの都道府県情報のcodeをurlに埋め込む(数字の部分)