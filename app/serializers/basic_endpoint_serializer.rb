#
# Endpoint serializer returning only basic information.
#
class BasicEndpointSerializer < ActiveModel::Serializer
  include Vphshare::Application.routes.mounted_helpers

  attributes :id, :name, :description, :endpoint_type, :url

  def url
    atmosphere.descriptor_api_v1_endpoint_url(object.id)
  end
end
