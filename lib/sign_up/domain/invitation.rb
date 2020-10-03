class Invitation
  attr_reader :id, :uuid, :status, :email, :roles

  TRANSITIONS = {
    pending: [ :pending, :rejected, :confirmed ],
    confirmed: [ :confirmed ],
    rejected: [ :rejected ]
  }

  STATUSES = %i( pending rejected confirmed )

  def initialize(id:, uuid:, status: 'pending', email: ,roles:)
    @id = id
    @uuid = uuid
    @status = status || 'pending'
    @email = email
    @roles =roles
  end

  def status=(new_status)
    assert(
      valid_statuses?(new_status),
      "Status must be one of #{STATUSES.join(', ')}"
    )
    assert(
      valid_transition?(status, new_status),
      "Invitation cannot move from #{status} to #{new_status}"
    )
    @status = new_status
  end

  def to_h
    {
      id: id,
      uuid: uuid,
      status: status,
      email: email,
      roles: roles
    }
  end

  private

  def valid_statuses?(s)
    STATUSES.include?(s.to_sym)
  end

  def valid_transition?(from, to)
    TRANSITIONS[from.to_sym].include?(to.to_sym)
  end
end
