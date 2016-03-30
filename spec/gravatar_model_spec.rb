require 'spec_helper'

describe 'Gravatar Avatare' do
  let(:email){'john.doe@gmail.com'}
  subject {Gravatar::Avatar.new(email)}

  describe 'attributes' do
    it 'Can not be initialize with bad email' do
      expect { subject.email = 'foo@bar' }.to raise_error(ArgumentError)
    end

    it 'Can not be initialize with bad scheme' do
      expect { subject.scheme = 'ftp' }.to raise_error(ArgumentError)
    end

    it 'Can not be initialize with bad extension' do
      expect { subject.scheme = '.mp3' }.to raise_error(ArgumentError)
    end
  end

  describe 'url' do
    let(:base_url){'www.gravatar.com/avatar/e13743a7f1db7f4246badd6fd6ff54ff'}

    it 'return gravatar url' do
      expect(subject.url).to eql "http://#{base_url}.jpeg"
    end

    context 'https scheme' do
      before{ subject.scheme = 'https'}

      it 'return gravatar url' do
        expect(subject.url).to eql "https://#{base_url}.jpeg"
      end
    end

    context 'custom extension' do
      before{ subject.extension = '.png'}

      it 'return gravatar url' do
        expect(subject.url).to eql "http://#{base_url}.png"
      end
    end
  end
end
