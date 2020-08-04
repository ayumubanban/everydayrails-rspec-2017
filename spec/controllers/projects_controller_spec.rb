require 'rails_helper'

RSpec.describe ProjectsController, type: :controller do
  describe '#index' do
    # 認証済みのユーザーとして
    context 'as an authenticated user' do
      before do
        @user = FactoryBot.create(:user)
      end

      # 正常にレスポンスを返すこと
      it 'responds successfully' do
        sign_in @user
        get :index
        expect(response).to be_success
      end

      # 200レスポンスを返すこと
      it 'returns a 200 response' do
        sign_in @user
        get :index
        expect(response).to have_http_status '200'
      end
    end

    # ゲストとして
    context 'as a guest' do
      # 302レスポンスを返すこと
      it 'returns a 302 response' do
        get :index
        expect(response).to have_http_status '302'
      end

      # サインイン画面にリダイレクトすること
      it 'redirects to the sign-in page' do
        get :index
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe '#show' do
    # 認可されたユーザーとして
    context 'as an authorized user' do
      before do
        @user = FactoryBot.create(:user)
        @project = FactoryBot.create(:project, owner: @user)
      end

      # 正常にレスポンスを返すこと
      it 'responds successfully' do
        sign_in @user
        get :show, params: {
          id: @project.id
        }
        expect(response).to be_success
      end
    end

    # 認可されていないユーザーとして
    context 'as an unauthorized user' do
      before do
        @user = FactoryBot.create(:user)
        other_user = FactoryBot.create(:user)
        @project = FactoryBot.create(:project, owner: other_user)
      end

      # ダッシュボードにリダイレクトすること
      it 'redirects to the dashboard' do
        sign_in @user
        get :show, params: {
          id: @project.id
        }
        expect(response).to redirect_to root_url
      end
    end
  end

  describe '#create' do
    context 'as an authenticated user' do
      before do
        @user = FactoryBot.create(:user)
      end

      context 'with valid attributes' do
        it 'adds a project' do
          project_params = FactoryBot.attributes_for(:project)
          sign_in @user
          expect {
            post :create, params: {
              project: project_params
            }
          }.to change(@user.projects, :count).by(1)
        end
      end

      context 'with invalid attributes' do
        it 'does not add a project' do
          project_params = FactoryBot.attributes_for(:project, :invalid)
          sign_in @user
          expect {
            post :create, params: {
              project: project_params
            }
          }.to_not change(@user.projects, :count)
        end
      end

      it 'adds a project' do
        project_params = FactoryBot.attributes_for(:project)
        sign_in @user
        expect {
          post :create, params: {
            project: project_params
          }
        }.to change(@user.projects, :count).by(1)
      end
    end

    context 'as a guest' do
      it 'returns a 302 response' do
        project_params = FactoryBot.attributes_for(:project)
        post :create, params: {
          project: project_params
        }
        expect(response).to have_http_status '302'
      end

      it 'redirects to the sign-in page' do
        project_params = FactoryBot.attributes_for(:project)
        post :create, params: {
          project: project_params
        }
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe '#update' do
    context 'as an authorized user' do
      before do
        @user = FactoryBot.create(:user)
        @project = FactoryBot.create(:project, owner: @user)
      end

      it 'updates a project' do
        project_params = FactoryBot.attributes_for(:project, name: 'New Project Name')
        sign_in @user
        patch :update, params: {
          id: @project.id,
          project: project_params
        }
        # p84 reload メソッドを使うのはデータベース上の値を読み込むためです。こうしないと、メモリに保存された値が再利用されてしまい、値の変更が反映されません。
        expect(@project.reload.name).to eq 'New Project Name'
      end
    end

    context 'as an unauthorized user' do
      before do
        @user = FactoryBot.create(:user)
        other_user = FactoryBot.create(:user)
        @project = FactoryBot.create(:project, owner: other_user, name: 'Same Old Name')
      end

      it 'does not update the project' do
        project_params = FactoryBot.attributes_for(:project, name: 'New Name')
        sign_in @user
        patch :update, params: {
          id: @project.id,
          project: project_params
        }
        expect(@project.reload.name).to eq 'Same Old Name'
      end

      it 'redirects to the dashboard' do
        project_params = FactoryBot.attributes_for(:project)
        sign_in @user
        patch :update, params: {
          id: @project.id,
          project: project_params
        }
        expect(response).to redirect_to root_url
      end
    end

    context 'as a guest' do
      before do
        @project = FactoryBot.create(:project)
      end

      it 'returns 302 response' do
        project_params = FactoryBot.attributes_for(:project)
        patch :update, params: {
          id: @project.id,
          project: project_params
        }
        expect(response).to have_http_status '302'
      end

      it 'redirects to the sign-in page' do
        project_params = FactoryBot.attributes_for(:project)
        patch :update, params: {
          id: @project.id,
          project: project_params
        }
        expect(response).to redirect_to '/users/sign_in'
      end
    end
  end

  describe '#destroy' do
    context 'as an authorized user' do
      before do
        @user = FactoryBot.create(:user)
        @project = FactoryBot.create(:project, owner: @user)
      end

      it 'deletes a project' do
        sign_in @user
        expect {
          delete :destroy, params: {
            id: @project.id
          }
        }.to change(@user.projects, :count).by(-1)
      end
    end

    context 'as an unauthorized user' do
      before do
        @user = FactoryBot.create(:user)
        other_user = FactoryBot.create(:user)
        @project = FactoryBot.create(:project, owner: other_user)
      end

      it 'does not delete the project' do
        sign_in @user
        expect {
          delete :destroy, params: {
            id: @project.id
          }
        }.to_not change(Project, :count)
      end

      it 'redirects to the dashboard' do
        sign_in @user
        delete :destroy, params: {
          id: @project.id
        }
        expect(response).to redirect_to root_url
      end
    end

    context 'as a guest' do
      before do
        @project = FactoryBot.create(:project)
      end

      it 'returns a 302 response' do
        delete :destroy, params: {
          id: @project.id
        }
        expect(response).to have_http_status '302'
      end

      it 'redirects to the sign-in page' do
        delete :destroy, params: {
          id: @project.id
        }
        expect(response).to redirect_to '/users/sign_in'
      end

      it 'does not delete the project' do
        expect {
          delete :destroy, params: {
            id: @project.id
          }
        }.to_not change(Project, :count)
      end
    end
  end
end
