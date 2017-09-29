#-- encoding: UTF-8

#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2015 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.

require 'spec_helper'
require 'rack/test'

describe "POST /api/v3/queries/form", type: :request do
  include API::V3::Utilities::PathHelper

  let(:path) { api_v3_paths.create_query_form }
  let(:user) { FactoryGirl.create(:admin) }
  let!(:project) { FactoryGirl.create(:project_with_types, enabled_module_names: ["costs_module", "work_package_tracking"]) }
  let!(:project_2) { FactoryGirl.create(:project_with_types, enabled_module_names: ["costs_module", "work_package_tracking"]) }

  let(:parameters) do
    {
      name: "default",
      _links: {
        project: {
          href: "/api/v3/projects/#{project.id}"
        }
      }
    }
  end

  let(:project_id) { project.id }

  before do
    login_as(user)

    header "Content-Type", "application/json"
  end

  def filter_values_link_for(json, filter_name)
    json["_embedded"]["schema"]["_embedded"]["filtersSchemas"]["_embedded"]["elements"]
      .select { |a| a["filter"]["_embedded"]["allowedValues"][0]["id"] == filter_name }
      .map { |e|
        e["_dependencies"].map { |d|
          d["dependencies"].values.reject(&:empty?).map { |v|
            v.dig "values", "_links", "allowedValues", "href"
          }
        }
      }
      .flatten.compact.first
  end

  it 'should return different budget filter value links for each project' do
    post path, parameters.to_json
    values_link_1 = filter_values_link_for JSON.parse(last_response.body), "costObject"

    params = parameters.dup
    params[:_links][:project][:href] = "/api/v3/projects/#{project_2.id}"

    post path, params.to_json
    values_link_2 = filter_values_link_for JSON.parse(last_response.body), "costObject"

    expect(values_link_1).not_to eq(values_link_2)

    expect(values_link_1).to eq "/api/v3/projects/#{project.id}/budgets"
    expect(values_link_2).to eq "/api/v3/projects/#{project_2.id}/budgets"
  end
end
