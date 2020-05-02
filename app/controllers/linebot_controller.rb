class LinebotController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'
  require 'open-uri'
  require 'kconv'
  require 'rexml/document'

  # callbackアクションのCSRFトークン認証を無効
  protect_from_forgery :except => [:callback]

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      return head :bad_request
    end
    events = client.parse_events_from(body)

    # 作った都道府県データを変数に保存
    prefectures = Prefecture.all
    events.each { |event|
      case event
        # メッセージが送信された場合の対応（機能①）
      when Line::Bot::Event::Message
        case event.type
          # ユーザーからテキスト形式のメッセージが送られて来た場合
        when Line::Bot::Event::MessageType::Text  #MessageType::Textの場合の処理
          case @message #送信されたメッセージに応じて分岐させる

          when "北海道,東北"
            message = ::LineClient.second_reply_hokkaido_tohoku
            client.reply_message(event['replyToken'], message)
          when "関東"
            message = ::LineClient.second_reply_kanto
            client.reply_message(event['replyToken'], message)
          when "北陸,甲信越"
            message = ::LineClient.second_reply_hokuriku_koushinetsu
            client.reply_message(event['replyToken'], message)
          when "東海,関西"
            message = ::LineClient.second_reply_tokai_kansai
            client.reply_message(event['replyToken'], message)
          when "中国,四国"
            message = ::LineClient.second_reply_chugoku_shikoku
            client.reply_message(event['replyToken'], message)
          when "九州,沖縄"
            message = ::LineClient.second_reply_kyusyu_okinawa
            client.reply_message(event['replyToken'], message)

          # Prefectureモデルに該当するメッセージの場合に反応する
          when *prefectures.pluck(:name)
            line_id = event['source']['userId']
            prefecture = Prefecture.find_by(name: @message)

            user = User.find_by(line_id: line_id)
            if prefecture && user
              user.update(prefecture_id: prefecture[:id])
            end
            

          else
            message = ::LineClient.first_reply
            client.reply_message(event['replyToken'], message)
          end





          # ユーザーからテキスト形式のメッセージが送られて来た場合
        when Line::Bot::Event::MessageType::Text
          # event.message['text']：ユーザーから送られたメッセージ
          input = event.message['text']
          url  = "https://www.drk7.jp/weather/xml/13.xml"
          xml  = open( url ).read.toutf8
          doc = REXML::Document.new(xml)
          xpath = 'weatherforecast/pref/area[4]/'
          # 当日朝のメッセージの送信の下限値は20％としているが、明日・明後日雨が降るかどうかの下限値は30％としている
          min_per = 30
          case input
            # 「明日」or「あした」というワードが含まれる場合
          when /.*(明日|あした).*/
            # info[2]：明日の天気
            per06to12 = doc.elements[xpath + 'info[2]/rainfallchance/period[2]'].text
            per12to18 = doc.elements[xpath + 'info[2]/rainfallchance/period[3]'].text
            per18to24 = doc.elements[xpath + 'info[2]/rainfallchance/period[4]'].text
            if per06to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
              push =
                "明日の天気だよね。\n明日は雨が降りそうだよ(>_<)\n今のところ降水確率はこんな感じだよ。\n　  6〜12時　#{per06to12}％\n　12〜18時　 #{per12to18}％\n　18〜24時　#{per18to24}％\nまた明日の朝の最新の天気予報で雨が降りそうだったら教えるね！"
            else
              push =
                "明日の天気？\n明日は雨が降らない予定だよ(^^)\nまた明日の朝の最新の天気予報で雨が降りそうだったら教えるね！"
            end
          when /.*(明後日|あさって).*/
            per06to12 = doc.elements[xpath + 'info[3]/rainfallchance/period[2]l'].text
            per12to18 = doc.elements[xpath + 'info[3]/rainfallchance/period[3]l'].text
            per18to24 = doc.elements[xpath + 'info[3]/rainfallchance/period[4]l'].text
            if per06to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
              push =
                "明後日の天気だよね。\n何かあるのかな？\n明後日は雨が降りそう…\n当日の朝に雨が降りそうだったら教えるからね！"
            else
              push =
                "明後日の天気？\n気が早いねー！何かあるのかな。\n明後日は雨は降らない予定だよ(^^)\nまた当日の朝の最新の天気予報で雨が降りそうだったら教えるからね！"
            end
          when /.*(かわいい|可愛い|カワイイ|きれい|綺麗|キレイ|素敵|ステキ|すてき|面白い|おもしろい|ありがと|すごい|スゴイ|スゴい|好き|頑張|がんば|ガンバ).*/
            push =
              "ありがとう！！！\n優しい言葉をかけてくれるあなたはとても素敵です(^^)"
          when /.*(こんにちは|こんばんは|初めまして|はじめまして|おはよう).*/
            push =
              "こんにちは。\n声をかけてくれてありがとう\n今日があなたにとっていい日になりますように(^^)"
          else
            per06to12 = doc.elements[xpath + 'info/rainfallchance/period[2]l'].text
            per12to18 = doc.elements[xpath + 'info/rainfallchance/period[3]l'].text
            per18to24 = doc.elements[xpath + 'info/rainfallchance/period[4]l'].text
            if per06to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
              word =
                ["雨だけど元気出していこうね！",
                 "雨に負けずファイト！！",
                 "雨だけどああたの明るさでみんなを元気にしてあげて(^^)"].sample
              push =
                "今日の天気？\n今日は雨が降りそうだから傘があった方が安心だよ。\n　  6〜12時　#{per06to12}％\n　12〜18時　 #{per12to18}％\n　18〜24時　#{per18to24}％\n#{word}"
            else
              word =
                ["天気もいいから一駅歩いてみるのはどう？(^^)",
                 "今日会う人のいいところを見つけて是非その人に教えてあげて(^^)",
                 "素晴らしい一日になりますように(^^)",
                 "雨が降っちゃったらごめんね(><)"].sample
              push =
                "今日の天気？\n今日は雨は降らなさそうだよ。\n#{word}"
            end
          end
          # テキスト以外（画像等）のメッセージが送られた場合
        else
          push = "テキスト以外はわからないよ〜(；；)"
        end
        message = {
          type: 'text',
          text: push
        }
        client.reply_message(event['replyToken'], message)
        # LINEお友達追された場合（機能②）
      when Line::Bot::Event::Follow
        # 登録したユーザーのidをユーザーテーブルに格納
        line_id = event['source']['userId']
        User.create(line_id: line_id)

        Prefectures.find_by(name: )
        # ④userデータを登録するときにprefectureテーブルのnameカラムに対して都道府県名で検索

        INSERT INTO Users; Prefectures.new()
        # ⑤都道府県名を取得できたらPrefecturesテーブルのidをUsersテーブルに保存

        # LINEお友達解除された場合（機能③）
      when Line::Bot::Event::Unfollow
        # お友達解除したユーザーのデータをユーザーテーブルから削除
        line_id = event['source']['userId']
        User.find_by(line_id: line_id).destroy
      end
    }
    head :ok
  end

  private

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end

  # class LineClient
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
  # end
end