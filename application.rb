require 'lotus/router'
require 'lotus/controller'
require 'lotus/view'
require 'lotus/model'
require 'lotus/model/adapters/sql_adapter'
require 'pathname'
require 'dotenv'
require 'sequel'
require 'reform'
require_relative 'lotus'

Dotenv.load

Lotus::Controller.handle_exceptions = false

ApplicationRoot = Pathname.new(__FILE__).dirname
Dir.glob(ApplicationRoot.join('app/*/*.rb')) { |file| require file }

Lotus::View.root = ApplicationRoot.join('app/templates')
Lotus::View.load!

mapper = Lotus::Model::Mapper.new do
  collection :rooms do
    entity Room

    attribute :id,          Integer
    attribute :name,        String
    attribute :description, String
  end
end

mapper.load!

adapter = Lotus::Model::Adapters::SqlAdapter.new(mapper, ENV.fetch('DATABASE_URL'))

RoomRepository.adapter = adapter

Application = Lotus::Application.new

require_relative 'config/routes'

Application.build_rack_app do
  use Rack::Static, :urls => ["/stylesheets"], :root => "public"

  run Application
end
