# frozen_string_literal: true

module ActiveAdmin
  module Views
    module Pages
      # Initializes GON gem
      class Base < Arbre::HTML::Document
        alias original_build_head build_active_admin_head

        def build_active_admin_head
          original_build_head

          within head do
            text_node Gon::Base.render_data({})
          end
        end
      end
    end
  end
end
