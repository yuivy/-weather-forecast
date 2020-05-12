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
      # binding.pry
      case event
        # メッセージが送信された場合の対応（機能①）
      when Line::Bot::Event::Message
        # binding.pry
        @message = event.message['text'].gsub(" ", "")
        case event.type
          # ユーザーからテキスト形式のメッセージが送られて来た場合
        when process_region  #MessageType::Textの場合の処理
          case @message #送信されたメッセージに応じて分岐させる

          when "北海道,東北"
            message = LineClient.second_reply_hokkaido_tohoku
            client.reply_message(event['replyToken'], message)
          when "関東"
            message = LineClient.second_reply_kanto
            client.reply_message(event['replyToken'], message)
          when "北陸,甲信越"
            message = LineClient.second_reply_hokuriku_koushinetsu
            client.reply_message(event['replyToken'], message)
          when "東海,関西"
            message = LineClient.second_reply_tokai_kansai
            client.reply_message(event['replyToken'], message)
          when "中国,四国"
            message = LineClient.second_reply_chugoku_shikoku
            client.reply_message(event['replyToken'], message)
          when "九州,沖縄"
            message = LineClient.second_reply_kyusyu_okinawa
            client.reply_message(event['replyToken'], message)

          # Prefectureモデルに該当するメッセージの場合に反応する
          when *prefectures.pluck(:name)
            prefecture = Prefecture.find_by(name: @message)
            message = LineClient.third_reply(prefecture.name)
            client.reply_message(event['replyToken'], message) 

            line_id = event['source']['userId']
            prefecture = Prefecture.find_by(name: @message)

            user = User.find_by(line_id: line_id)

            user.update(prefecture_id: prefecture.id) if prefecture.present? && user.present?
          else #reply_free(input)メソッド切る #ユーザーが自由入力した時の処理
            # binding.pry
            message = LineClient.first_reply
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
          when tomorrow(input)
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
          when day_after_tomorrow(input)
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
          when praise(input)
            push =
              "ありがとう！！！\n優しい言葉をかけてくれるあなたはとても素敵です(^^)"
          when is_greetig(input)
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
        # binding.pry
        # 地域を聞く質問
        message = LineClient::first_reply
        client.reply_message(event['replyToken'], message)

      when Line::Bot::Event::Unfollow
        # binding.pry
        # お友達解除したユーザーのデータをユーザーテーブルから削除
        line_id = event['source']['userId']
        User.find_by(line_id: line_id)&.destroy
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

  def tomorrow(message)
    /.*(明日|あした).*/ === message
  end

  def day_after_tomorrow(message)
    /.*(明後日|あさって).*/ === message
  end

  def praise(message)
    /.*(かわいい|可愛い|カワイイ|きれい|綺麗|キレイ|素敵|ステキ|すてき|面白い|おもしろい|ありがと|すごい|スゴイ|スゴい|好き|頑張|がんば|ガンバ).*/ === message
  end

  def is_greetig(message)
    /.*(こんにちは|こんばんは|初めまして|はじめまして|おはよう).*/ === message
  end

  def process_region
    Line::Bot::Event::MessageType::Text
  end
end