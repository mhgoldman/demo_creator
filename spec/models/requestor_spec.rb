require 'rails_helper'

RSpec.describe Requestor, type: :model do
  context '.get_skytap_url' do
    it "retrieves existing skytap url if there is one" do
      requestor = Requestor.create(email: 'esteban.colberto@skytap.com', skytap_url: "https://cloud.skytap.com/users/1234")
      expect(requestor.get_skytap_url).to eq("https://cloud.skytap.com/users/1234")
    end

    it "creates a new skytap user if skytap url missing" do
      requestor = Requestor.create(email: 'esteban.colberto@skytap.com')
      
      VCR.use_cassette("create_skytap_user", decode_compressed_response: true) do
        url = requestor.get_skytap_url
        expect(url).to eq("https://cloud.skytap.com/users/113450")
      end
    end
  end
end
