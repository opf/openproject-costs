require_dependency 'timelog_controller'

module OpenProject::Costs::Patches::TimelogControllerPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable

      alias_method_chain :find_optional_project, :own
    end
  end

  module InstanceMethods

    def find_optional_project_with_own
      if !params[:issue_id].blank?
        @issue = Issue.find(params[:issue_id])
        @project = @issue.project
      elsif !params[:project_id].blank?
        @project = Project.find(params[:project_id])
      end
      deny_access unless User.current.allowed_to?(:view_time_entries, @project, :global => true) ||
                         User.current.allowed_to?(:view_own_time_entries, @project, :global => true)
    end
  end
end

TimelogController.send(:include, OpenProject::Costs::Patches::TimelogControllerPatch)
