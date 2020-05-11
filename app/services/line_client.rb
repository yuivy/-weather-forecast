class LineClient
  # 1回目の質問(地域選択部分)
  def self.first_reply
    { "type": "text",
                    "text": "どこの地域？",
                    "quickReply": {
                      "items":
                      [
                        {
                          "type": "action",
                          "action": {
                          "type": "message",
                          "label": "北海道,東北",
                          "text": "北海道,東北"
                          }
                        },
                        {
                          "type": "action",
                          "action": {
                          "type": "message",
                          "label": "関東",
                          "text": "関東"
                          }
                        },
                        {
                          "type": "action",
                          "action": {
                          "type": "message",
                          "label": "北陸,甲信越",
                          "text": "北陸,甲信越"
                          }
                        },
                        {
                          "type": "action",
                          "action": {
                          "type": "message",
                          "label": "東海,関西",
                          "text": "東海,関西"
                          }
                        },
                        {
                          "type": "action",
                          "action": {
                          "type": "message",
                          "label": "中国,四国",
                          "text": "中国,四国"
                          }
                        },
                        {
                          "type": "action",
                          "action": {
                            "type": "message",
                            "label": "九州",
                            "text": "九州,沖縄"
                            }
                        }
                      ]
                    }
                  }
  end

  # 2回目の質問(都道府県の選択部分)
  def self.second_reply_hokkaido_tohoku
    { "type": "text",
                    "text": "都道府県は？",
                    "quickReply": {
                      "items":
                      [
                        {
                          "type": "action",
                          "action": {
                          "type": "message",
                          "label": "北海道",
                          "text": "北海道"
                          }
                        },
                        {
                          "type": "action",
                          "action": {
                          "type": "message",
                          "label": "青森",
                          "text": "青森"
                          }
                        },
                        {
                          "type": "action",
                          "action": {
                            "type": "message",
                            "label": "岩手",
                            "text": "岩手"
                          }
                        },
                        {
                          "type": "action",
                          "action": {
                          "type": "message",
                          "label": "宮城",
                          "text": "宮城"
                          }
                        },
                        {
                          "type": "action",
                          "action": {
                          "type": "message",
                          "label": "秋田",
                          "text": "秋田"
                          }
                        },
                        {
                          "type": "action",
                          "action": {
                          "type": "message",
                          "label": "山形",
                          "text": "山形"
                          }
                        },
                        {
                          "type": "action",
                          "action": {
                          "type": "message",
                          "label": "福島",
                          "text": "福島"
                          }
                        },
                        {
                          "type": "action",
                          "action": {
                          "type": "message",
                          "label": "都道府県を選び直す",
                          "text": "都道府県を選び直す"
                          }
                        }
                      ]
                    }
                  }
  end

  def self.second_reply_kanto
     { "type": "text",
                  "text": "都道府県は？",
                  "quickReply": {
                    "items":
                    [
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "茨城",
                        "text": "茨城"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                          "type": "message",
                          "label": "栃木",
                          "text": "栃木"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "群馬",
                        "text": "群馬"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "埼玉",
                        "text": "埼玉"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "千葉",
                        "text": "千葉"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "東京",
                        "text": "東京"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "神奈川",
                        "text": "神奈川"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "都道府県を選び直す",
                        "text": "都道府県を選び直す"
                        }
                      }
                    ]
                  }
                }
  end

  def self.second_reply_hokuriku_koushinetsu
     { "type": "text",
                  "text": "都道府県は？",
                  "quickReply": {
                    "items":
                    [
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "新潟",
                        "text": "新潟"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                          "type": "message",
                          "label": "富山",
                          "text": "富山"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "石川",
                        "text": "石川"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "福井",
                        "text": "福井"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                          "type": "message",
                          "label": "山梨",
                          "text": "山梨"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "長野",
                        "text": "長野"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "都道府県を選び直す",
                        "text": "都道府県を選び直す"
                        }
                      }
                    ]
                  }
                }
  end

  def self.second_reply_tokai_kansai
     { "type": "text",
                  "text": "どの県で遊ぶの？",
                  "quickReply": {
                    "items":
                    [
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "岐阜",
                        "text": "岐阜"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                          "type": "message",
                          "label": "静岡",
                          "text": "静岡"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "愛知",
                        "text": "愛知"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "三重",
                        "text": "三重"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "滋賀",
                        "text": "滋賀"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "京都",
                        "text": "京都"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "大阪",
                        "text": "大阪"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                          "type": "message",
                          "label": "兵庫",
                          "text": "兵庫"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "奈良",
                        "text": "奈良"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "和歌山",
                        "text": "和歌山"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "都道府県を選び直す",
                        "text": "都道府県を選び直す"
                        }
                      }
                    ]
                  }
                }
  end

  def self.second_reply_chugoku_shikoku
     { "type": "text",
                  "text": "都道府県は？",
                  "quickReply": {
                    "items":
                    [
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "鳥取",
                        "text": "鳥取"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                          "type": "message",
                          "label": "島根",
                          "text": "島根"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "岡山",
                        "text": "岡山"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "広島",
                        "text": "広島"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "山口",
                        "text": "山口"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "徳島",
                        "text": "徳島"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                          "type": "message",
                          "label": "香川",
                          "text": "香川"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "愛媛",
                        "text": "愛媛"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "高知",
                        "text": "高知"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "都道府県を選び直す",
                        "text": "都道府県を選び直す"
                        }
                      }
                    ]
                  }
                }
  end

  def self.second_reply_kyusyu_okinawa
     { "type": "text",
                  "text": "都道府県は？",
                  "quickReply": {
                    "items":
                    [
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "福岡",
                        "text": "福岡"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                          "type": "message",
                          "label": "佐賀",
                          "text": "佐賀"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "長崎",
                        "text": "長崎"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "熊本",
                        "text": "熊本"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "大分",
                        "text": "大分"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "宮崎",
                        "text": "宮崎"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "鹿児島",
                        "text": "鹿児島"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "沖縄",
                        "text": "沖縄"
                        }
                      },
                      {
                        "type": "action",
                        "action": {
                        "type": "message",
                        "label": "都道府県を選び直す",
                        "text": "都道府県を選び直す"
                        }
                      }
                    ]
                  }
                }
  end

  def self.third_reply(prefecture)
    { "type": "text",
                 "text": "#{prefecture}で登録しました！試しに明日の天気を聞いてみましょう",
                 }       
  end
end