class WorkPackage
  class LaborCosts < AbstractCosts
    def costs_model
      TimeEntry
    end

    def filter_authorized(scope)
      view_hourly_rates = %{
        (#{Project.allowed_to_condition(user, :view_hourly_rates, project: project)} OR
        (#{Project.allowed_to_condition(user, :view_own_hourly_rate, project: project)} AND
        #{TimeEntry.table_name}.user_id = #{user.id}))
      }
      view_time_entries = TimeEntry.visible_condition(user, project: project)

      scope
        .where([view_time_entries, view_hourly_rates].join(' AND '))
    end
  end
end
