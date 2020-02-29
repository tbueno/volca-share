# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Keys patch index page', type: :feature do
  let(:user) { create(:user) }

  it 'can be accessed by link in header' do
    visit root_path
    click_link('Keys')
    within '.dropdown-menu.keys' do
      page.find(:link, 'Browse').click
    end
    expect(current_path).to eq(keys_patches_path)
  end

  context 'when user is logged in' do
    it 'allows user to delete their own patches', js: true do
      create(:keys_patch, user_id: user.id)

      login
      visit keys_patches_path

      accept_confirm { click_button('Delete') }

      expect(page).to have_content('No patches to show.')
    end

    it 'links to the edit patch page', :js do
      patch = create(:keys_patch, user_id: user.id)

      login
      visit keys_patches_path

      page.find(:css, '.edit').click

      expect(page).to have_content('Edit patch')
    end
  end

  context 'when user is not logged in' do
    it 'shows anonymous patches' do
      patch = create(:keys_patch)

      visit keys_patches_path

      expect(page).to have_content(patch.name)
    end

    it 'does not show secret patches' do
      patch1 = create(:keys_patch, user_id: user.id)
      patch2 = create(:keys_patch, secret: true, user_id: user.id)

      visit keys_patches_path

      expect(page).to have_content(patch1.name)
      expect(page).not_to have_content(patch2.name)
    end
  end

  describe 'pagination' do
    let(:first_patch) do
      create(
        :keys_patch,
        user_id: user.id,
        notes: '',
        audio_sample: '',
        tags: []
      )
    end

    let(:last_patch) { create(:keys_patch, user_id: user.id) }

    before do
      first_patch
      20.times { create(:keys_patch, user_id: user.id, audio_sample: '') }
      last_patch

      visit keys_patches_path
    end

    describe 'first page' do
      it 'shows most recent patches first' do
        expect(page).to have_content(last_patch.name)
      end

      it 'does not show patches older than newest 20' do
        expect(page).not_to have_content(first_patch.name)
      end

      it 'shows the pagination controls' do
        expect(page).to have_selector('.pagination')
      end

      it 'shows 20 patches per page' do
        expect(page).to have_selector('.patch-holder', count: 20)
      end
    end

    describe 'second page' do
      before { click_link '2' }

      it 'doesn\'t show newest 20 patches' do
        expect(page).not_to have_content(last_patch.name)
      end

      it 'shows oldest patch' do
        expect(page).to have_content(first_patch.name)
      end

      it 'show the pagination controls' do
        expect(page).to have_selector('.pagination')
        expect(page).to have_link('1')
      end

      it 'shows remaining patches' do
        expect(page).to have_selector('.patch-holder', count: 2)
      end
    end
  end
end