# frozen_string_literal: true

require 'rails_helper'

module Keys
  RSpec.describe PatchesController, type: :controller do
    let(:valid_attributes) { attributes_for(:keys_patch) }
    let(:invalid_attributes) { attributes_for(:keys_patch, attack: 'bort') }
    let(:valid_session) { {} }

    describe 'GET #new' do
      it 'assigns a new patch as @patch' do
        get :new, params: {}, session: valid_session
        expect(assigns(:patch)).to be_a_new(VolcaShare::Keys::PatchViewModel)
      end
    end

    describe 'GET #show' do
      it 'assigns the requested patch as @patch' do
        patch = Patch.create!(valid_attributes)
        get :show, params: { id: patch.to_param }, session: valid_session
        expect(assigns(:patch)).to eq(patch)
      end
    end

    describe 'GET #edit' do
      context 'when user is logged in' do
        login_user

        context 'when patch belongs to current user' do
          let(:patch_to_edit) { @user.keys_patches.create!(valid_attributes) }

          before do
            get :edit,
                params: { slug: patch_to_edit.slug, user_slug: @user.slug },
                session: valid_session
          end

          it 'assigns the requested patch as @patch' do
            expect(assigns(:patch)).to(
              eq(VolcaShare::Keys::PatchViewModel.wrap(patch_to_edit))
            )
          end

          it 'renders edit page' do
            expect(response).to render_template('patches/edit')
          end
        end

        context 'when patch does not belong to current user' do
          let(:some_other_user) { create(:user) }
          let(:patch_to_edit) do
            some_other_user.keys_patches.create!(valid_attributes)
          end

          before do
            get :edit,
                params: {
                  slug: patch_to_edit.slug,
                  user_slug: some_other_user.slug
                },
                session: valid_session
          end

          it 'returns unauthorized status' do
            expect(response.status).to eq(401)
          end

          it 'redirects to show patch page' do
            expect(response).to render_template(:show)
          end
        end
      end

      context 'when user is not logged in' do
        let(:user) { create(:user) }
        let(:patch_to_edit) { user.keys_patches.create!(valid_attributes) }

        before do
          get :edit,
              params: { slug: patch_to_edit.slug, user_slug: user.slug },
              session: valid_session
        end

        it 'shows message to user' do
          expect(flash[:alert]).to(
            eq('You need to sign in or sign up before continuing.')
          )
        end

        it 'redirects to sign in / sign_up page' do
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    describe 'POST #create' do
      let(:params) { attributes_for(:keys_patch) }

      context 'when user is logged in' do
        login_user

        it 'creates a new patch' do
          expect do
            post :create, params: { patch: params }, session: valid_session
          end.to change { Patch.count }.by(1)
        end

        it 'redirects to user patch show page' do
          post :create, params: { patch: params }, session: valid_session
          expect(response).to redirect_to(user_keys_patch_path(User.first.slug, Patch.last.slug))
        end
      end

      context 'when user is not logged in' do
        it 'creates a new patch' do
          expect do
            post :create, params: { patch: params }, session: valid_session
          end.to change { Patch.count }.by(1)
        end

        it 'redirects to anonymous patch show page' do
          post :create, params: { patch: params }, session: valid_session
          expect(response).to redirect_to(keys_patch_path(Patch.last.id))
        end
      end

      context 'when parameters are invalid' do
        it 'does not create a patch' do
          expect do
            post(
              :create,
              params: { patch: invalid_attributes },
              session: valid_session
            )
          end.not_to change { Patch.count }
        end

        it 'redirects to edit path' do
          post(
            :create,
            params: { patch: invalid_attributes },
            session: valid_session
          )
          expect(response).to render_template('patches/new')
        end
      end
    end
  end
end
