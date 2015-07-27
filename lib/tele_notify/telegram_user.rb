require 'rest-client'

module TeleNotify
  class TelegramUser < ::ActiveRecord::Base

    validates_presence_of :telegram_id
    validates_uniqueness_of :telegram_id

    def self.configure_token(token)
      if token =~ /^[0-9]+:[\w-]+$/
        @token = token
        @url = "https://api.telegram.org/bot" + token + "/"
      else
        raise "Invalid token."
      end
    end

    def self.get_updates
      response = JSON.parse(RestClient.get(@url + "getUpdates"), { symbolize_names: true })
      puts response
      if response[:ok]
        updates = response[:result]
        updates.each do |update|
          self.create( { telegram_id: update[:message][:from][:id], first_name: update[:message][:from][:first_name] } )
        end
      end
    end

    def self.send_message
      TeleNotify::TelegramUser.all.each do |user|
        RestClient.post(@url + "sendMessage", chat_id: user.telegram_id, text: "Test")
      end
    end

  end

end
