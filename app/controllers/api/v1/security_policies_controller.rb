module Api
  module V1
    class SecurityPoliciesController < Atmosphere::Api::ApplicationController
      before_action :find_by_name, only: :payload
      load_and_authorize_resource :security_policy

      respond_to :json

      def index
        respond_with @security_policies.where(filter).order(:id)
      end

      def show
        respond_with @security_policy
      end

      def create
        log_user_action "create new security policy with following params #{params}"
        @security_policy.save!
        render json: @security_policy, status: :created
        log_user_action "security policy created: #{@security_policy.to_json}"
      end

      def update
        log_user_action "update security policy #{@security_policy.id} with following params #{params}"
        @security_policy.update_attributes!(security_policy_params)
        render json: @security_policy
        log_user_action "security policy updated: #{@security_policy.to_json}"
      end

      def destroy
        log_user_action "destroy security policy #{@security_policy.id}"
        if @security_policy.destroy
          render json: {}
          log_user_action "security policy #{@security_policy.id} destroyed"
        else
          render_error @security_policy
        end
      end

      def payload
        render plain: @security_policy.payload
      end

      private

      def security_policy_params
        init_owners params.require(:security_policy).permit(:name, :payload, owners: [])
      end

      def init_owners(sp_params)
        sp_params[:users] = sp_params[:owners].blank? ? [current_user] : Atmosphere::User.where(id: sp_params[:owners]) if current_user

        sp_params.delete :owners
        sp_params
      end

      def find_by_name
        @security_policy = model_class.find_by(name: params[:name])
        raise ActiveRecord::RecordNotFound if @security_policy.blank?
        @security_policy
      end
    end
  end
end
