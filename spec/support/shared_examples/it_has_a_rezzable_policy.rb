RSpec.shared_examples 'it has a rezzable policy' do |model_name|
   let(:active_user) { FactoryBot.create :active_user }

  let(:inactive_user) { FactoryBot.create :inactive_user }

  let(:owner) { FactoryBot.create :owner }

  let(:web_object) { FactoryBot.build model_name.to_sym }

  subject { described_class }

  permissions :show?, :destroy? do
    context 'user is active' do
      it 'grants permission to the user' do
        expect(subject).to permit(active_user, web_object)
      end
    end

    context 'user is inactive' do
      it 'grants permission to the user ' do
        expect(subject).to permit(inactive_user, web_object)
      end
    end

    it 'grants permission to an owner' do
      expect(subject).to permit owner, web_object
    end
  end

  permissions :update? do
    context 'user is active' do
      it 'grants permission to the user' do
        expect(subject).to permit(active_user, web_object)
      end
    end

    context 'user is inactive' do
      it 'denies permission to the user ' do
        expect(subject).to_not permit(inactive_user, web_object)
      end
    end

    it 'grants permission to an owner' do
      expect(subject).to permit owner, web_object
    end
  end

  permissions :create? do
    it 'grants permission to an owner' do
      expect(subject).to permit owner, web_object
    end

    context 'user is inactive' do
      it 'denies permission to the user' do
        expect(subject).to_not permit(inactive_user, web_object)
      end
    end

    context 'user is active' do
      context 'user has enough reserve object weight' do
        it 'grants permission to the user' do
          expect(subject).to permit(active_user, web_object.class)
        end
      end

      # context 'user does not have enough reserve object weight' do
      #   before(:each) do
      #     web_object.valid?
      #     (100 / web_object.weight).round.times do |i|
      #       active_user.web_objects << FactoryBot.build(
      #         model_name, object_name: "#{model_name}_#{i}"
      #       )
      #     end
      #   end
      #   it 'denies permission to the user' do
      #     expect(subject).to_not permit(active_user, web_object)
      #   end
      # end
    end
  end
end