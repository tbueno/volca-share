require 'rails_helper'

RSpec.describe 'User profile page', type: :feature, js: true do
  let(:user) { FactoryBot.create(:user, username: 'arly.lowe') }

  context 'when user is logged in' do
    it 'can be accessed via the top navigation' do
      user = FactoryBot.create(:user)
      login(user)
      click_link 'My Patches'
      expect(current_path).to eq(user_path(user.slug))
    end
  end

  it 'shows patch previews in iframe' do
    FactoryBot.create(:patch, user_id: user.id, secret: false)
    visit user_path(user.slug)
    first('.speaker').click
    expect(page).to have_selector('#audio-preview-modal')
  end

  it 'shows user created patches' do
    patch1 = FactoryBot.create(:patch, user_id: user.id, secret: false)
    patch2 = FactoryBot.create(:patch, user_id: user.id, secret: true)

    visit user_path(user.slug)
    expect(page).to have_selector 'h1', text: "Patches by #{user.username}"
    expect(page).to have_title("Patches by #{user.username} | VolcaShare")
    expect(page).to have_content(patch1.name)
    expect(page).not_to have_content(patch2.name)

    visit patches_path
    click_link user.username
    expect(page).to have_title("Patches by #{user.username} | VolcaShare")
    expect(page).to have_content(patch1.name)
    expect(page).not_to have_content(patch2.name)

    visit patch_path(patch1.slug)
    click_link user.username
    expect(page).to have_title("Patches by #{user.username} | VolcaShare")
    expect(page).to have_content(patch1.name)
    expect(page).not_to have_content(patch2.name)
  end

  scenario 'logged in user can see their secret patches' do
    patch1 = FactoryBot.create(:patch, secret: false, user_id: user.id)
    patch2 = FactoryBot.create(:patch, secret: true, user_id: user.id)

    login

    visit user_path(user.slug)
    expect(page).to have_content(patch1.name)
    expect(page).to have_content(patch2.name)
  end
end
