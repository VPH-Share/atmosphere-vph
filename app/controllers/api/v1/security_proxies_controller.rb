module Api
  module V1
    class SecurityProxiesController < Atmosphere::Api::ApplicationController
      before_action :find_by_name, only: :payload
      load_and_authorize_resource :security_proxy, class: 'SecurityProxy'

      respond_to :json

      def index
        respond_with @security_proxies.where(filter).order(:id)
      end

      def show
        respond_with @security_proxy
      end

      def create
        log_user_action "create new security proxy with following params #{params}"
        @security_proxy.save!
        render json: @security_proxy, serializer: SecurityProxySerializer, status: :created
        log_user_action "security proxy created: #{@security_proxy.to_json}"
      end

      def update
        log_user_action "update security proxy #{@security_proxy.id} with following params #{params}"
        @security_proxy.update_attributes!(security_proxy_params)
        render json: @security_proxy, serializer: SecurityProxySerializer
        log_user_action "security proxy updated: #{@security_proxy.to_json}"
      end

      def destroy
        log_user_action "destroy security proxy #{@security_proxy.id}"
        if @security_proxy.destroy
          render json: {}
          log_user_action "security proxy #{@security_proxy.id} destroyed"
        else
          render_error @security_proxy
        end
      end

      def payload
        render plain: @security_proxy.payload
      end

      private

      def security_proxy_params
        init_owners params.require(:security_proxy).permit(:name, :payload, owners: [])
      end

      def init_owners(sp_params)
        sp_params[:users] = sp_params[:owners].blank? ? [current_user] : Atmosphere::User.where(id: sp_params[:owners]) if current_user

        sp_params.delete :owners
        sp_params
      end

      def find_by_name
        @security_proxy = model_class.find_by(name: params[:name])
        raise ActiveRecord::RecordNotFound if @security_proxy.blank?
        @security_proxy
      end
    end
  end
end
