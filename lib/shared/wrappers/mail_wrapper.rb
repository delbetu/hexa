# Wrapping the mail-gem allows to easy switch to another gem in the future
class MailWrapper
  def initialize(from:, to:, subject:, body:)
    @from = from
    @to = to
    @subject = subject
    @body = body
  end

  def deliver!
    mail = Mail.new
    mail.from = @from
    mail.to = @to
    mail.subject = @subject
    mail.body = @body
    mail.header['Content-Type'] = 'text/html; charset=UTF-8'
    mail.deliver!
  end
end
