module BlockStack
  class Header < Block

    def default_locals(custom = {})
      case custom[:model]
      when Class
        {
          title:      custom[:model].config.display_name.pluralize,
          subtitle:   custom[:model].config.tagline,
          background: custom[:model].config.background,
          thumbnail:  custom[:model].config.thumbnail,
          icon:       custom[:model].config.icon,
          color:      (custom[:model].config.header_color || :black),
          animated:   true
        }
      when Model
        {
          title:      custom[:model].title,
          subtitle:   custom[:model].tagline,
          background: custom[:model].background,
          thumbnail:  custom[:model].thumbnail,
          icon:       custom[:model].icon,
          color:      (custom[:model].config.header_color || :black),
          animated:   true
        }
      else
        {
          title:      '',
          subtitle:   nil,
          background: nil,
          thumbnail:  nil,
          icon:       nil,
          color:      :black,
          animated:   true
        }
      end
    end

  end
end
