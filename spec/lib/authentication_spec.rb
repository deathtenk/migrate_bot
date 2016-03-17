require "authenticate"

RSpec.describe Authenticate do
  let(:client) do
    double(:client)
  end

  let(:username) do
    "fake_username"
  end

  let(:password) do
    "fake_password"
  end

  before do
    allow(subject).
      to receive(:call).
      with(username,password).
      and_return(client)
  end

  it "should return a client" do
    expect(Authenticate.call(username,password)).to eq(client)
  end
end
