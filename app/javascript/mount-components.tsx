/**
 * mountComponents
 *
 * This code attempts to find all elements that contain a data-react-component
 * attribute, and then to mount components matching that name onto the page in
 * those locations. This code also parses any props contained in a data-props
 * attribute and passes those along to the component too.
 *
 * For example, a page containing:
 *
 *     <div data-react-component='App' data-props="{}"></div>
 *
 * Would have a component called `App` mounted into the location of that div
 * tag. This then allows us to intermix React components with our Rails
 * application, which can be particularly helpful if we have an older Rails app
 * that we’re enhancing with some newer React components.
 */
import React from "react";
import ReactDOM from "react-dom/client";

type Components = Record<string, React.ElementType>;

export default function mountComponents(components: Components): void {
  document.addEventListener("DOMContentLoaded", () => {
    const mountPoints = document.querySelectorAll("[data-react-component]");

    mountPoints.forEach((mountPoint) => {
      const { dataset } = mountPoint as HTMLElement;
      const componentName = dataset.reactComponent;
      if (componentName) {
        const Component = components[componentName];

        if (Component) {
          const props = JSON.parse(dataset.props as string);
          const root = ReactDOM.createRoot(mountPoint);
          root.render(<Component {...props} />);
        } else {
          console.warn(
            "WARNING: No component found for: ",
            dataset.reactComponent,
            components
          );
        }
      }
    });
  });
}
