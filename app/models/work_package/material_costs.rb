class WorkPackage
  class MaterialCosts < AbstractCosts
    def costs_model
      CostEntry
    end

    def filter_authorized(scope)
      view_cost_rates = Project.allowed_to_condition(user, :view_cost_rates, project: project)
      view_cost_entries = CostEntry.visible_condition(user, project)

      scope.where([view_cost_entries, view_cost_rates].join(' AND '))
    end
  end
end
