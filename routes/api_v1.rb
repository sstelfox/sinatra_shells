
class Default::App
  namespace '/api/v1' do
    helpers ::ApiResponseHelper

    before do
      content_type :json
    end

    not_found do
      content_type :json
      response_wrapper({}, response.status, [env['sinatra.error'].message])
    end

    error do
      content_type :json
      response_wrapper({}, response.status, [env['sinatra.error'].message])
    end
  end
end

