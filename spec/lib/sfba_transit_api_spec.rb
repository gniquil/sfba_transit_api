require 'spec_helper'

describe SFBATransitAPI do
  it 'creates a valid client' do
    client = SFBATransitAPI.client "asdf"
    expect(client.connection.token).to eq "asdf"
  end
end
