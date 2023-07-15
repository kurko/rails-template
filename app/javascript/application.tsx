/*
 * If you're using esbuild/importmaps/stimulus
 */
// import "./controllers"

/*
 * For React, uncomment the following lines to use React
 */
import React from "react";
import mountComponents from "./mount-components";
import SampleComponent from "./components/SampleComponent";

const App = () => <h1>Hello from React!</h1>;

/*
 * ! Until https://github.com/evanw/esbuild/pull/2508 is merged, we need to
 *   manually import the components we want to use. !
 *
 * mountComponents will automatically 
 */
mountComponents({
  App,
  SampleComponent
});

