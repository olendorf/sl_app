RSpec.shared_examples 'it is a transactable' do |model_name|
  
  it { should have_many(:transactions).
                class_name('Analyzable::Transaction').
                dependent(:nullify) }
                
                
  let(:user) { FactoryBot.create :active_user }
  let(:web_object) { FactoryBot.create model_name.to_sym, user_id: user.id }
 
  describe 'adding transactions' do
    context 'no splits' do
      it 'should add the transaction to the user' do
        web_object.transactions << FactoryBot.build(:transaction, amount: 100)
        expect(user.transactions.size).to eq 1
      end
    end
  end

  
end