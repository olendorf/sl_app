RSpec.shared_examples 'it is a transactable' do |model_name|
  
  it { should have_many(:transactions).
                class_name('Analyzable::Transaction').
                dependent(:nullify) }
                
                
  let(:user) { FactoryBot.create :active_user }
  let(:server) { FactoryBot.create :server, user_id: user.id }
  let(:web_object) { FactoryBot.create model_name.to_sym, user_id: user.id, server_id: server.id }
  
  let(:uri_regex) do
    %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}/give_money\?
       auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
  end
  
  
 
  describe 'adding transactions' do
    context 'no splits' do
      it 'should add the transaction to the user' do
        web_object.transactions << FactoryBot.build(:transaction, amount: 100)
        expect(user.transactions.size).to eq 1
      end
    end
    
    context 'splits' do 
      before(:each) {
        @stub = stub_request(:put, uri_regex)
               .with(body: /{"avatar_name":"[a-zA-Z0-9 ]*","avatar_key":[-a-f0-9]*,amount":[0-9]+}/)
               .to_return(status: 200, body: '', headers: {})
      }
      it 'should add the transactions to the user' do 
        user.splits << FactoryBot.build(:split)
        web_object.splits << FactoryBot.build(:split)
        expect {
          web_object.transactions << FactoryBot.build(:transaction, amount: 100)
        }.to change{ user.transactions.size }.by(3)
      end
    end
  end

  
end