require 'spec_helper'

describe Docusign::Data do

  let(:data) { Docusign::Data.new({ arr: [1, 2, 3], arr2: [[4,5,6]], key1: '123', key2: 'String', key3: '2016-04-12 03:44:21', key4: 'true', key5: 'false', key6: '28.4', nested: { key: 'Is Nested' } }) }

  it 'can correctly parse given string data' do
    expect(data.key1).to eq(123)
    expect(data.key1).to be_a(Integer)
    expect(data.key2).to eq('String')
    expect(data.key2).to be_a(String)
    expect(data.key3).to be_a(DateTime)
    expect(data.key4).to eq(true)
    expect(data.key4).to be_a(true.class)
    expect(data.key5).to eq(false)
    expect(data.key5).to be_a(false.class)
    expect(data.key6).to eq(28.4)
    expect(data.key6).to be_a(Float)
  end

  it 'can extract nested values' do
    expect(data.nested.key).to eq('Is Nested')
  end

  it 'can return a default value for keys that do not exist' do
    expect(data.missing('stuff')).to eq('stuff')
  end

  it 'will not intercept non-read method calls' do
    expect { data.special_key = 2 }.to raise_error(NoMethodError)
  end

  it 'can return proper key values when the value is an array' do
    expect(data.arr).to eq([1,2,3])
    expect(data.arr2).to eq([[4,5,6]])
  end

end
