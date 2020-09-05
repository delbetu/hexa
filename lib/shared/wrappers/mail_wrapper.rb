# Wrapping the mail-gem allows to easy switch to another gem in the future
class MailWrapper
  def initialize(from:, to:, subject:, body:)
    @from = from
    @to = to
    @subject = subject
    @body = body
  end

  def deliver!
    Pony.mail(
      from: @from,
      to: @to,
      subject: @subject,
      html_body: @body,
    )
  end
end
