class Admin::VideosController < Admin::AdminController
  def index
    @videos = Video.all
  end

  def new
    @video = Video.new
  end

  def create
    video_url = params[:video_url]
    video_info = Vimeo.get_video_info(video_url, width: 960)
    @video = Video.new

    case video_info.code
    when 404
      flash[:error] = "Sorry. That video cannot be found"
      render :new
    when 500...600
      flash[:error] = "Sorry. Something went wrong while trying to grab the video info. Please try again."
      render :new
    when 200
      @video = Video.new
      @video.vimeo_id = video_info['video_id']
      @video.title = video_info['title']
      @video.description = video_info['description']
      @video.video_url = video_url
      @video.thumbnail_url = video_info['thumbnail_url']
      @video.embed_code = video_info['html']
      @video.duration = video_info['duration']

      if @video.save
        flash[:success] = 'Your video has been successfully saved.'
        redirect_to admin_videos_path
      else
        flash[:error] = @video.errors.full_messages.join('<br/>')
        render :new
      end
    end
  end

  def show
    @video = Video.find(params[:id])
  end

  def destroy
    @video = Video.find(params[:id])
    if @video.destroy
      flash[:success] = 'Your video has been successfully deleted.'
    else
      flash[:error] = 'There was a problem deleting your video.'
    end
    redirect_to update_videos_admin_videos_path
  end

  def update_videos
    @videos = Video.all
  end

  def update_all
    Video.update(params[:videos].keys, params[:videos].values)

    flash[:success] = "Your videos have been successfully updated."
    redirect_to update_videos_admin_videos_path
  end

  def refresh
    @video = Video.find(params[:id])
    video_info = Vimeo.get_video_info(@video.video_url, width: 960)

    case video_info.code
    when 500...600
      flash[:error] = "Sorry. Something went wrong while trying to grab the video info. Please try again."
    when 200
      @video.title = video_info['title']
      @video.description = video_info['description']
      @video.thumbnail_url = video_info['thumbnail_url']
      @video.embed_code = video_info['html']
      @video.duration = video_info['duration']

      if @video.save
        flash[:success] = 'Your video has been successfully saved.'
      else
        flash[:error] = @video.errors.full_messages.join('<br/>')
      end
    end
    redirect_to admin_video_path(@video)
  end
end