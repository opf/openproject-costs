Setting.default_projects_modules += ['costs_module']

OpenProject::Costs::DefaultData.load! unless Rails.env.test?
