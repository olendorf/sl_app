# frozen_string_literal: true

RSpec.shared_examples 'it has an owner rezzable SL request behavior' do |model_name, _namespace|
  let(:user) { FactoryBot.create :user }
  let(:owner) { FactoryBot.create :owner }
  let(:web_object) {
    web_object = FactoryBot.build model_name.to_sym, user_id: owner.id
    web_object.save
    web_object
  }

  let(:uri_regex) do
    %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}\?
       auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
  end

  before(:each) do
    login_as(owner, scope: :user)
  end

  scenario 'User deletes a the object' do
    stub = stub_request(:delete, uri_regex)
           .to_return(status: 200, body: '', headers: {})

    visit send("admin_#{model_name}_path", web_object)
    click_on "Delete #{model_name.to_s.titleize}"
    expect(page).to have_text("#{model_name.to_s.titleize} was successfully destroyed.")
    expect(stub).to have_been_requested
  end

  scenario 'User updates the object' do
    stub = stub_request(:put, uri_regex)
           .with(body: /{"object_name":"foo","description":"bar"(,"server_id":"")?}/)
           .to_return(status: 200, body: '', headers: {})

    visit send("edit_admin_#{model_name}_path", web_object)
    fill_in "#{model_name.to_s.titleize} name", with: 'foo'
    fill_in 'Description', with: 'bar'
    click_on "Update #{model_name.to_s.titleize}"
    expect(page).to have_text("#{model_name.to_s.titleize} was successfully updated.")
    expect(stub).to have_been_requested
  end
end
