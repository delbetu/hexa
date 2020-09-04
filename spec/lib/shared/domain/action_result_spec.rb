require 'spec_helper'
require 'shared/domain/action_result'

describe do
  it do
    s = ActionSuccess(name: 'Bruce', age: 54)
    expect(s.success?).to eq(true)
    expect(s.errors).to eq([])
    expect(s.id).to eq('-')
    expect(s.name).to eq('Bruce')
    expect(s.age).to eq(54)
  end

  it do
    s = ActionSuccess(id: "someId", name: 'Bruce', age: 54)
    expect(s.id).to eq("someId")
  end

  it do
    s = ActionError(errors: ['Some Error'])
    expect(s.success?).to eq(false)
    expect(s.errors).to eq(['Some Error'])
    expect(s.id).to eq('-')
  end
end
