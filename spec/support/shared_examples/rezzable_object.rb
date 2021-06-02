# frozen_string_literal: true

RSpec.shared_examples 'a rezzable object' do |model_name, object_weight|
  let(:user) { FactoryBot.create :user }
  let(:web_object) { FactoryBot.create model_name.to_sym }
  describe '#object_weight' do
    it 'should return the correct weight' do
      expect(web_object.object_weight).to eq object_weight
    end
  end

  context "creating a #{model_name}" do
    describe 'updating object_count' do
      it 'should update the count when there is a user' do
        FactoryBot.create model_name.to_sym, user_id: user.id
        expect(user.reload.web_objects_count).to eq 1
      end
    end

    describe 'updating object_weight' do
      it 'should update the object weight correclty' do
        FactoryBot.create model_name.to_sym, user_id: user.id
        expect(user.reload.web_objects_weight).to eq object_weight
      end
    end
  end

  context "destroying a #{model_name}" do
    before(:each) do
      FactoryBot.create model_name.to_sym, user_id: user.id
      user.reload
    end
    describe 'updating object_count' do
      it 'should decrement the count' do
        user.web_objects.last.destroy
        expect(user.web_objects_count).to eq 0
      end
    end

    describe 'updating object_weight' do
      it 'should decrement the weight' do
        user.web_objects.last.destroy
        expect(user.web_objects_weight).to eq 0
      end
    end
  end
end
