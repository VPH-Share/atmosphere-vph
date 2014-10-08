RSpec::Matchers.define :owned_payload_eq do |expected|
  match do |actual|
    actual['name'] == expected.name &&
    actual['payload'] == expected.payload &&
    actual['owners'].size == ids(expected).size
  end

  def ids (expected)
    @names ||= expected.users.collect do |user|
      user.id
    end
  end
end