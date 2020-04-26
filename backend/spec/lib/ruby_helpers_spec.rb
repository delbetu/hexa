require 'ruby_helpers'

module DummyPort
  extend Interface
  method :my_method_1
  method :my_method_2, key_args: {first: '<String>', second: '<Integer>'}
  # TODO: not supported yet
  # method(:my_method_3,
  #        key_args: { email: '<Email>', password: '<String>' },
  #        returns: { ok: '<Boolean>', result: '<PermissionEnum>' }
  #       )
end

class Dummy
  include DummyPort
  # def my_method_2(first:, second:)
  #   byebug
  #   'striii'
  # end
end

describe Dummy do
  it { is_expected.to respond_to(:my_method_1) }

  xit do
    is_expected.to respond_to(:my_method_2).with(2).arguments.and_keywords(:first, :second)
  end

  it do
    expect {
      subject.my_method_2
    }.to raise_error(StandardError, 'Must implement method my_method_2({:first=>"<String>", :second=>"<Integer>"})')
  end

  xit do
    expect {
      subject.my_method_3
    }.to raise_error(StandardError, 'Must implement method my_method_2({ email: <Email>, password: <String> }) => [<PermissionEnum>]')
  end
end
