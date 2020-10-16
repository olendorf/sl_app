class Api::V1::AbstractWebObjectsController < Api::V1::ApiController
  def create
    http_x = request.headers.select do |key, value| 
      key.to_s.match(/\AHTTP_X[a-zA-Z0-9_]*\z/)
    end
    pp http_x
    # puts params
    # puts atts
    object_type = request.path.split('/')[2..-1].map {
      |item| item.classify 
    }.join('::').constantize
    new_object = object_type.create(atts)
    render json:  {
                    data: {api_key: new_object.api_key}, 
                    msg: 'Created'    
                  }, status: :created
  end
  
  
  private
  
  def atts
    {
      object_key: request.headers['HTTP_X_SECONDLIFE_OBJECT_KEY'],
      object_name: request.headers['HTTP_X_SECONDLIFE_OBJECT_NAME'],
      region: extract_region_name,
      position: format_position,
      user_id: User.find_by_avatar_key(
        request.headers['HTTP_X_SECONDLIFE_OWNER_KEY']).id,
      url: params['url']
    }.merge(JSON.parse(request.raw_post))
  end

  def extract_region_name
    region_regex = /(?<name>[a-zA-Z0-9 ]+) ?\(?/
    matches = request.headers['HTTP_X_SECONDLIFE_REGION'].match(region_regex)
    matches[:name]
  end
  
  def format_position
    pos_regex = /\((?<x>[0-9\.]+), (?<y>[0-9\.]+), (?<z>[0-9\.]+)\)/
    matches = request.headers['HTTP_X_SECONDLIFE_LOCAL_POSITION'].match(pos_regex)
    { x: matches[:x].to_f, y: matches[:y].to_f, z: matches[:z].to_f }.to_json
  end
end
