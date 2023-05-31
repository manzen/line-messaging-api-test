class Api::V1::LineController < ApplicationController
  protect_from_forgery except: :callback

  def callback
    client = Line::Bot::Client.new do |config|
      config.channel_id = Rails.application.credentials.dig(:channel_id)
      config.channel_secret = Rails.application.credentials.dig(:channel_secret)
      config.channel_token = Rails.application.credentials.dig(:channel_token)
    end

    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    return head :bad_request unless client.validate_signature(body, signature)

    events = client.parse_events_from(body)
    events.each do |event|
      message = case event
                when Line::Bot::Event::Message
                  case event.type
                  when Line::Bot::Event::MessageType::Text
                    response_messeage(event)
                  end
                else
                  { type: 'text', text: 'Please send the text' }
                end
      client.reply_message(event['replyToken'], message)
    end
    head :ok
  end

  ## このmethodを要件に合わせて修正する
  def response_messeage(event)
    ## OpenAIの処理
    client = OpenAI::Client.new(access_token: ENV["CHATGPT_API_KEY"])
    response = client.chat(
      parameters: {
          model: "gpt-3.5-turbo",
          messages: [{ role: "user", content: event.message['text'] }],
      })
    chats = response.dig("choices", 0, "message", "content")
    { type: 'text', text: chats }
  end
end
