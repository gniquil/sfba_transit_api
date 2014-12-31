require 'spec_helper'

module SFBATransitAPI
  describe Connection do
    let(:token) { "asdfqwer" }

    let(:connection) { Connection.new token }

    it "initiates correctly" do
      expect(connection.token).to eq token
      expect(connection.path_prefix).to eq "/Transit2.0"
    end

    it "converts camelizes params" do
      expect(connection.options_to_params({:route_idf => 1, "another_test" => 2})).to eq({ "routeIDF" => 1,"anotherTest" => 2 })
    end

    it "makes the right call to api endpoint" do
      response = double("Response", status: 200, body: "<RTT></RTT>")

      allow(connection).to receive(:request).and_return(response)

      connection.get(:get_routes_for_agency, agency_name: "BART")

      expect(connection).to have_received(:request).with(
        "/Transit2.0/GetRoutesForAgency.aspx",
        {"token" => token, "agencyName" => "BART"}
      )
    end

    it "should raise error if response code is not 200" do
      response = double("Response", status: 300, body: "<RTT></RTT>")

      allow(connection).to receive(:request).and_return(response)

      expect {
        connection.get(:get_routes_for_agency, agency_name: "BART")
      }.to raise_exception(ResponseException, "Server responded with 300")
    end

    it "should raise error if response was a transitError" do
      response = double("Response", status: 200, body: "<transitServiceError>Invalid parameter count</transitServiceError>")

      allow(connection).to receive(:request).and_return(response)

      expect {
        connection.get(:get_routes_for_agency, agency_name: "BART")
      }.to raise_exception(ResponseException, "Invalid parameter count")
    end
  end
end
