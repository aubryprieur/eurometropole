# frozen_string_literal: true

Rails.application.config.to_prepare do
  # Nouveau compte
  Decidim::User.class_eval do
    after_create_commit :notify_slack_new_user

    private

    def notify_slack_new_user
      return if deleted? || blocked?

      SlackNotificationJob.perform_later("new_user", {
        "name" => name,
        "email" => email
      })
    end
  end

  # Nouvelle idée/proposition
  Decidim::Proposals::Proposal.class_eval do
    after_create_commit :notify_slack_new_proposal

    private

    def notify_slack_new_proposal
      SlackNotificationJob.perform_later("new_proposal", {
        "title" => title.values.first.to_s.truncate(100),
        "author" => authors.first&.name || "Anonyme",
        "url" => Decidim::ResourceLocatorPresenter.new(self).url
      })
    end
  end

  # Nouveau commentaire
  Decidim::Comments::Comment.class_eval do
    after_create_commit :notify_slack_new_comment

    private

    def notify_slack_new_comment
      SlackNotificationJob.perform_later("new_comment", {
        "author" => author&.name || "Anonyme",
        "commentable" => commentable&.try(:title)&.values&.first.to_s.truncate(80),
        "body" => body.values.first.to_s
      })
    end
  end
end
