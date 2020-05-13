class LineClient
  REGIONS = %W[北海道,東北 関東 北陸,甲信越 東海,関西 中国,四国 九州,沖縄]
  #1回目の質問(地域選択部分)
  #labelは選択肢
  #textはlineで受け取るもの
  def self.first_reply
    items = REGIONS.map do |region|
      {
        "type": "action",
        "action": {
          "type": "message",
          "label": region,
          "text": region,
        }
      }
    end

    {
      "type": "text",
      "text": "どこの地域？",
      "quickReply": {
        "items": items,
      }
    }
  end

  def self.second_reply(region)
    items = Prefecture.where(region_name: region).map do |prefecture|
      {
        "type": "action",
        "action": {
          "type": "message",
          "label": prefecture.name,
          "text": prefecture.name,
        }
      }
    end

    items << {
      "type": "action",
      "action": {
        "type": "message",
        "label": "都道府県を選び直す",
        "text": "都道府県を選び直す"
      }
    }
    # binding.pry
    {
      "type": "text",
      "text": "都道府県は？",
      "quickReply": {
        "items": items,
      }
    }
  end

  def self.third_reply(prefecture)
    { "type": "text",
      "text": "#{prefecture}で登録しました！試しに明日の天気を聞いてみましょう",
      }       
  end
end