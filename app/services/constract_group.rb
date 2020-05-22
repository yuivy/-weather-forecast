class ConstractGroup
  def self.tomorrow
    [/.*(明日|あした).*/]
  end

  def self.day_after_tomorrow
    [/.*(明後日|あさって).*/]
  end

  def self.praise
    [/.*(かわいい|すき|ファイト|がんば|すご|ヤバイ|ありがと).*/]
  end

  def self.greeting
    [/.*(おはよう|こんにちは|こんばんは|おやすみ).*/]
  end
end