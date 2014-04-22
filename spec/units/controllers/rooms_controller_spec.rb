require 'spec_helper'

class RoomStub
  def self.new() end
end

class RoomFormStub
  def self.new() end
end

class RoomRepositaryStub
  def self.all() end
  def self.persist(entity) end
end

describe RoomsController::Index do
  let(:room) { Room.new(name: "Foo", description: "Bar") }
  let(:rooms) { [room] }
  let(:action) { described_class.new(repository: RoomRepositaryStub) }

  before do
    allow(RoomRepositaryStub).to receive(:all) { rooms }
  end

  it 'should expose rooms obtained from repository' do
    action.call({})
    expect(action.exposures[:rooms]).to eq(rooms)
  end
end

describe RoomsController::Create do
  let(:room) { Room.new }
  let(:params) { { room: {
      name: "foo",
      description: "bar"
    } } }
  let(:action) { described_class.new(repository: RoomRepositaryStub, entity_class: RoomStub) }

  before do
    allow(RoomStub).to receive(:new) { room }
    allow(RoomRepositaryStub).to receive(:persist).with(room)
  end

  it 'should pass the params to room' do
    action.call(params)
    expect(room.name).to eq('foo')
    expect(room.description).to eq('bar')
  end

  it 'should save the room' do
    action.call(params)
    expect(RoomRepositaryStub).to have_received(:persist).with(room)
  end

  it 'should redirect to the rooms index' do
    response = action.call(params)
    expect(response.fetch(0)).to eq(302)
    expect(response.fetch(1).fetch('Location')).to eq('/rooms')
  end

  describe 'given invalid room' do
    let(:room_form) { RoomForm.new(room) }
    let(:action) { described_class.new(repository: RoomRepositaryStub, entity_class: RoomStub, form_class: RoomFormStub) }

    before do
      allow(RoomFormStub).to receive(:new) { room_form }
      allow(room_form).to receive(:validate) { false }
    end

    it 'should set status to 422' do
      response = action.call(params)
      expect(response.fetch(0)).to eq(422)
    end
  end
end
