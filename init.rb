
######################################################################
### Auto Nested Layout
ActionController::Base.class_eval do
  class_inheritable_array :nested_layouts
  self.nested_layouts = []

  unless respond_to?(:find_filter)
    def self.find_filter(name)
      filter_chain.find(name)
    end
  end

  class << self
    def nested_layout(*files)
      find_filter(:render_with_nested_layouts) or
        after_filter :render_with_nested_layouts
      self.nested_layouts ||= [] # I don't know why this code is needed
      self.nested_layouts = self.nested_layouts + files
      layout false
    end
  end

private
  def guard_from_nested_layouts
    return true if @before_filter_chain_aborted
    return true if @performed_redirect
    return true if request.xhr?
    return true if !action_has_layout?
    return false
  end

  def guess_nested_layouts
    relative_paths = controller_path.split('/')
    relative_paths.unshift ''  # stands for "app/views"

    layouts = []
    pushed  = ''
    relative_paths.each do |dir|
      pushed << "#{dir}/"
      real_path = (Pathname(RAILS_ROOT) + "app/views").to_s + pushed
      layouts << pushed + "layout" unless Dir["#{real_path}_layout.*"].blank?
    end

    return layouts
  end

  def render_with_nested_layouts
    return true if guard_from_nested_layouts

    layouts = self.class.nested_layouts
    layouts = guess_nested_layouts if layouts.blank?

    logger.debug "Rendering nested layouts %s" % layouts.inspect

    layouts.reverse.each do |layout|
      content_for_layout = response.body
      erase_render_results
      add_variables_to_assigns
      @template.instance_variable_set("@content_for_layout", content_for_layout)
      render :partial=>layout
    end
  end
end

