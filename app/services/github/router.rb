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

    def installation_page_url(installation_id, github_entity)
      if github_entity.data["type"] == "Organization"
        GITHUB_HOST + "organizations/#{github_entity.data['login']}/settings/installations/#{installation_id}"
      else
        GITHUB_HOST + "settings/installations/#{installation_id}"
      end
    end
  end
end
