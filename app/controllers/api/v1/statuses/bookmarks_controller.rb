# frozen_string_literal: true

class Api::V1::Statuses::BookmarksController < Api::V1::Statuses::BaseController
  before_action -> { doorkeeper_authorize! :write, :'write:bookmarks' }
  before_action :require_user!
  skip_before_action :set_status, only: [:destroy]

  def create
    bookmark = current_account.bookmarks.find_or_initialize_by(status: @status)
    bookmark.update!(bookmark_params)
    render json: @status, serializer: REST::StatusSerializer
  end

  def destroy
    bookmark = current_account.bookmarks.find_by(status_id: params[:status_id])

    if bookmark
      @status = bookmark.status
    else
      @status = Status.find(params[:status_id])
      authorize @status, :show?
    end

    bookmark&.destroy!

    render json: @status, serializer: REST::StatusSerializer, relationships: StatusRelationshipsPresenter.new([@status], current_account.id, bookmarks_map: { @status.id => false })
  rescue ActiveRecord::RecordNotFound, Mastodon::NotPermittedError
    not_found
  end

  private

  def bookmark_params
    params.permit(:folder_id)
  end
end
