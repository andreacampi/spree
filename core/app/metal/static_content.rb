class StaticContent
  def initialize(app)
    @app = app
  end
  
  def call(env)
    status, headers, body = @app.call(env)
    
    if status == 404 && url = applicable(env['PATH_INFO'])
      begin
        [200, { }, [ContentController.new.handle(url)]]
      rescue ActionView::MissingTemplate
        [status, headers, body]
      end
    else
      [status, headers, body]
    end
  end
  
  def applicable(path)
    (path =~ /^\/([^.]+)$/ ? $1 : nil)
  end
end

class ContentController < ActionController::Metal
  include AbstractController::Rendering
  
  # XXX is this right?
  append_view_path Rails.root.join("core", "app", "views")
  append_view_path Rails.root.join("app", "views")
  
  def handle(path)
    render :action => path
  end
end
