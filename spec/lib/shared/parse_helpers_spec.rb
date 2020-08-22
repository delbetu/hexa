require 'spec_helper'
require 'shared/parse_helpers'

describe ParseHelpers do
  subject { Object.new.extend(ParseHelpers) }

  test 'parse_name' do
    expect {
      subject.parse_name("na"*200)
    }.to raise_error(EndUserError, 'Name too long. 200 characters max.')
  end

  test 'parse_email' do
    expect {
      subject.parse_email("some@email")
    }.to raise_error(EndUserError, /email/)
  end

  test 'parse_roles' do
    expect {
      subject.parse_roles('non-existing-role')
    }.to raise_error(EndUserError, /role/i)

    expect(subject.parse_roles('hr')).to eq(['hr'])
  end
end
