# frozen_string_literal: true

require 'rspec'
require 'bosh/template/test'

describe 'promtail config/config.yml.erb' do
  let(:release_dir) { File.join(File.dirname(__FILE__), '../..') }
  let(:release) { Bosh::Template::Test::ReleaseDir.new(release_dir) }
  let(:job) { release.job('promtail') }
  let(:template) { job.template('config/config.yml') }

  let(:properties) do
    {
      'promtail' => {
        'loki' => {
          'server' => {
            'http_listen_address' => 'loki.example.com',
            'http_listen_port' => 3100
          },
          'external_labels' => {}
        }
      }
    }
  end

  let(:rendered) { YAML.safe_load(template.render(properties)) }

  context 'when promtail.loki.tls is true' do
    before { properties['promtail']['loki']['tls'] = true }

    it 'uses https in the loki client url' do
      expect(rendered['clients'][0]['url']).to eq('https://loki.example.com:3100/loki/api/v1/push')
    end
  end

  context 'when promtail.loki.tls is false' do
    before { properties['promtail']['loki']['tls'] = false }

    it 'uses http in the loki client url' do
      expect(rendered['clients'][0]['url']).to eq('http://loki.example.com:3100/loki/api/v1/push')
    end
  end
end
