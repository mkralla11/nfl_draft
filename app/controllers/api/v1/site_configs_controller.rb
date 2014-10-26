module Api
  module V1
    class SiteConfigsController < ApplicationController
      before_action :set_site_config, only: [:show, :edit, :update, :destroy]

      # GET /site_configs
      def index
        @site_configs = Ownership.all
      end

      # GET /site_configs/1
      def show
      end

      # GET /site_configs/new
      def new
        @site_config = Ownership.new
      end

      # GET /site_configs/1/edit
      def edit
      end

      # POST /site_configs
      def create
        @site_config = Ownership.new(site_config_params)

        if @site_config.save
          redirect_to @site_config, notice: 'Ownership was successfully created.'
        else
          render :new
        end
      end

      # PATCH/PUT /site_configs/1
      def update
        if @site_config.update(site_config_params)
          redirect_to @site_config, notice: 'Ownership was successfully updated.'
        else
          render :edit
        end
      end

      # DELETE /site_configs/1
      def destroy
        @site_config.destroy
        redirect_to site_configs_url, notice: 'Ownership was successfully destroyed.'
      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_site_config
          @site_config = Ownership.find(params[:id])
        end

        # Only allow a trusted parameter "white list" through.
        def site_config_params
          params.require(:site_config).permit(:team_id, :player_id, :round, :pick)
        end
    end
  end
end