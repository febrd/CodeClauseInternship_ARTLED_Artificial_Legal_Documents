defmodule LegalDocWeb.Router do
  use LegalDocWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LegalDocWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LegalDocWeb do
    pipe_through :browser

    get "/", PageController, :home
    #resources "/documents", DocumentController
     live "/documents", DocumentLive.Index, :index
    # get "/documents", DocumentController, :index
     get "/documents/new", DocumentController, :new
     get "/documents/:id", DocumentController, :show
     get "/documents/:id/edit", DocumentController, :edit
     post "/documents", DocumentController, :create
     patch "/documents/:id", DocumentController, :update
     put "/documents/:id", DocumentController, :update
    #live "/documents/new", DocumentLive.Index, :new
    #live "/documents/:id/edit", DocumentLive.Index, :edit

    #live "/documents/:id", DocumentLive.Show, :show
    #live "/documents/:id/show/edit", DocumentLive.Show, :edit



  end

  # Other scopes may use custom stacks.
  # scope "/api", LegalDocWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:legal_doc, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: LegalDocWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
