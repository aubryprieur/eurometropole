# frozen_string_literal: true

class SlackNotificationJob < ApplicationJob
  queue_as :default

  def perform(event_type, details)
    webhook_url = ENV["SLACK_WEBHOOK_URL"]
    return if webhook_url.blank?

    text = case event_type
           when "new_user"
             "👤 *Nouveau compte* : #{details['name']} (#{details['email']})"
           when "new_proposal"
             "💡 *Nouvelle idée* : #{details['title']}\nPar #{details['author']} — #{details['url']}"
           when "new_comment"
             "💬 *Nouveau commentaire* par #{details['author']}\nSur : #{details['commentable']}\n#{details['body']&.truncate(200)}"
           else
             return
           end

    payload = { text: text, unfurl_links: false }

    require "net/http"
    uri = URI(webhook_url)
    Net::HTTP.post(uri, payload.to_json, "Content-Type" => "application/json")
  rescue StandardError => e
    Rails.logger.error("[SlackNotification] #{e.message}")
  end
end
