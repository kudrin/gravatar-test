require 'spec_helper'

describe 'Gravatar API' do
  it 'On right HTTP responce return http gravatar url' do
    get '/gravatar/kudrin.alexander@gmail.com'
    expect(last_response.status).to eql(200)
    expect(last_response.body).to   eql('http://www.gravatar.com/avatar/8ae4f86ddc70bfdb8b6c8a2001f1ce7d.jpeg')
  end

  it 'On bad email return status 403 and empty boudy' do
    get '/gravatar/kudrin.alexandergmail.com'
    expect(last_response.status).to eql(422)
    expect(last_response.body).to   eql('')
  end

  it 'On bad request return 404' do
    get '/gravatar/'
    expect(last_response.status).to eql(404)
    expect(last_response.body).to   eql('')
  end
end
