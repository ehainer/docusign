require 'spec_helper'

describe User do

  it 'has an envelopes association' do
    t = User.reflect_on_association(:envelopes)
    expect(t.macro).to eq(:has_many)
  end

  it 'has a templates association' do
    t = User.reflect_on_association(:templates)
    expect(t.macro).to eq(:has_many)
  end

end