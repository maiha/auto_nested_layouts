require File.dirname(__FILE__) + '/test_helper'

class ApplicationController < ActionController::Base
end

class TopController < ApplicationController
end

class Top2Controller < ApplicationController
end

module Admin
  class TopController < ApplicationController
  end

  module Top
    class Admin::Top::MenuController < ApplicationController
    end
  end
end

class UserController < ApplicationController
end

module User
  module Frames
    class TopController < ApplicationController
    end
  end
end

class AutoNestedLayoutsTest < Test::Unit::TestCase
  # Replace this with your real tests.

  def layouts_for(controller)
    controller.new.send :guess_nested_layouts
  end

  def test_level1
    assert_equal %w( /layout /top/layout ), layouts_for(TopController)
  end

  def test_level1_without_2nd
    assert_equal %w( /layout ), layouts_for(Top2Controller)
  end

  def test_level2
    assert_equal %w( /layout /admin/layout /admin/top/layout ), layouts_for(Admin::TopController)
  end

  def test_level3
    assert_equal %w( /layout /admin/layout /admin/top/layout /admin/top/menu/layout ), layouts_for(Admin::Top::MenuController)
  end

  def test_level3_without_2nd
    assert_equal %w( /layout /user/layout /user/frames/top/layout ), layouts_for(User::Frames::TopController)
  end
end
