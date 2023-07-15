module ReactHelper
  # This renders the following (with "App" as param):
  #
  #   <div data-react-component='App' data-props="{}"></div>
  #
  # The Javascript side will look for the component with the same name
  # and render it in the div.
  def render_react_component(component_name, props = {})
    tag.div(
      '',
      data: {
        react_component: component_name,
        props: props
      }
    )
  end
end
