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
    events.each { |event|
      case event
        # メッセージが送信された場合の対応（機能①）
      when Line::Bot::Event::Message
        @message = event.message['text'].gsub(" ", "")
        case
          # ユーザーからテキスト形式のメッセージが送られて来た場合
        when region?(@message)
          message = LineClient.second_reply(@message)
          client.reply_message(event['replyToken'], message)
        # Prefectureモデルに該当するメッセージの場合に反応する
        when prefecture?(@message)
          prefecture = Prefecture.find_by(name: @message)
          message = LineClient.third_reply(prefecture.name)
          client.reply_message(event['replyToken'], message) 

          line_id = event['source']['userId']
          user = User.find_by(line_id: line_id)

          user.update(prefecture_id: prefecture.id) if prefecture.present? && user.present?

        else #ユーザーが自由入力した時の処理
          line_id = event['source']['userId']
          user = User.find_by(line_id: line_id)
          # event.message['text']：ユーザーから送られたメッセージ
          input = event.message['text']
          url  = "https://www.drk7.jp/weather/xml/" + user.prefecture.id.to_s + ".xml"
          xml  = open( url ).read.toutf8
          doc = REXML::Document.new(xml)
          xpath = user.prefecture.area
          # 当日朝のメッセージの送信の下限値は20％としているが、明日・明後日雨が降るかどうかの下限値は30％としている
          min_per = 30
          case input

          when *ConstractGroup.tomorrow then
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
          when *ConstractGroup.day_after_tomorrow then
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
          when *ConstractGroup.praise then
            push = "ありがとう！！\n優しい言葉をかけてくれるあなたはとても素敵です(⁎˃ᴗ˂⁎)"

          when *ConstractGroup.greeting then
            push = "こんにちは。\n声をかけてくれてありがとう！\n今日があなたにとっていい日になりますように(*^^*)"
          else
            per06to12 = doc.elements[xpath + 'info/rainfallchance/period[2]l'].text
            per12to18 = doc.elements[xpath + 'info/rainfallchance/period[3]l'].text
            per18to24 = doc.elements[xpath + 'info/rainfallchance/period[4]l'].text
            if per06to12.to_i >= min_per || per12to18.to_i >= min_per || per18to24.to_i >= min_per
              word =
                ["雨だけど元気出していこうね！",
                 "雨に負けずファイト(*ﾟ▽ﾟ)ﾉ",
                 "雨だけどあなたの明るさでみんなを元気にしてあげて(๑•ω-๑)♥"].sample
              push =
                "今日の天気？\n今日は雨が降りそうだから傘があった方が安心だよ。\n　  6〜12時　#{per06to12}％\n　12〜18時　 #{per12to18}％\n　18〜24時　#{per18to24}％\n#{word}"
            else
              word =
                ["天気もいいから出かけてみるのはどう？(*´ｰ`*)",
                 "今日会う人のいいところを見つけて是非その人に教えてあげて(◦ˉ ˘ ˉ◦)",
                 "素晴らしい一日になりますように(*•ω•*)",
                 "雨が降っちゃったらごめんね(´тωт`)｡ﾟ"].sample
              push =
                "今日の天気？\n今日は雨は降らなさそうだよ！\n#{word}"
            end
          end
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
        # 地域を聞く質問
        message = LineClient::first_reply
        client.reply_message(event['replyToken'], message)

      when Line::Bot::Event::Unfollow
        # お友達解除したユーザーのデータをユーザーテーブルから削除
        line_id = event['source']['userId']
        User.find_by(line_id: line_id)&.destroy

      # テキスト以外（画像等）のメッセージが送られた場合
      else
        push = "テキスト以外はわからないよ( ᵕ_ᵕ̩̩ )"
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

  def region?(message)
    LineClient::REGIONS.include?(message)
  end

  def prefecture?(message)
    Prefecture.all.pluck(:name).include?(message)
  end
end