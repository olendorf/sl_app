# frozen_string_literal: true

RSpec.shared_examples 'it has a rezzable SL request behavior' do |model_name, namespace|
  let(:user) { FactoryBot.create :user }
  let(:owner) { FactoryBot.create :owner }
  let(:web_object) {
    web_object = FactoryBot.build model_name.to_sym, user_id: user.id
    web_object.save
    web_object
  }

  let(:uri_regex) do
    %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}\?
       auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
  end

  before(:each) do
    login_as(owner, scope: :user) if namespace.to_s == 'admin'
    login_as(user, scope: :user) if namespace.to_s == 'my'
  end

  scenario 'User deletes a the object' do
    stub = stub_request(:delete, uri_regex)
           .to_return(status: 200, body: '', headers: {})

    visit send("#{namespace}_#{model_name}_path", web_object)
    click_on "Delete #{model_name.to_s.titleize}"
    expect(page).to have_text(/#{model_name.to_s.titleize} was successfully destroyed\./i)
    expect(stub).to have_been_requested
  end

  scenario 'User deletes a the object but there is an error' do
    stub_request(:delete, uri_regex).to_return(body: 'foo', status: 400)

    visit send("#{namespace}_#{model_name}_path", web_object)
    click_on "Delete #{model_name.to_s.titleize}"
    expect(page).to have_text('There was an error deleting the inworld object: foo')
  end

  scenario 'User updates the object' do
    stub = stub_request(:put, uri_regex)
           .to_return(status: 200, body: '', headers: {})

    visit send("edit_#{namespace}_#{model_name}_path", web_object)
    fill_in "#{model_name.to_s.titleize} name", with: 'foo'
    fill_in 'Description', with: 'bar'
    button_name = model_name.to_s.split('_').join(' ')
    button_name[0] = button_name[0].capitalize
    click_on "Update #{button_name}"
    expect(page).to have_text(/#{model_name.to_s.titleize} was successfully updated\./i)
    expect(stub).to have_been_requested
  end

  scenario 'User updates the object and there is an error' do
    stub_request(:put, uri_regex)
      .to_return(body: 'foo', status: 400)

    visit send("edit_#{namespace}_#{model_name}_path", web_object)
    fill_in "#{model_name.to_s.titleize} name", with: 'foo'
    fill_in 'Description', with: 'bar'
    button_name = model_name.to_s.split('_').join(' ')
    button_name[0] = button_name[0].capitalize
    click_on "Update #{button_name}"
    expect(page).to have_text('There was an error updating the inworld object: foo')
  end
end
