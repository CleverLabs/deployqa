# frozen_string_literal: true

module Github
  class Router
    GITHUB_HOST = "https://github.com/"

    def install_url
      GITHUB_HOST + "apps/#{ENV['GITHUB_APP_NAME']}"
    end

    def additional_installation_url
      GITHUB_HOST + "apps/#{ENV['GITHUB_APP_NAME']}/installations/new"
    end

    def page_url(page_id)
      GITHUB_HOST + page_id
    end
  end
end
