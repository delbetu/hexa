import React, { Component } from "react";
import ReactDom from "react-dom";
import { BrowserRouter, Switch, Route, Link } from "react-router-dom";
import { Provider } from "react-redux";
import Numbers from "./components/numbers";
import Ping from "./components/ping";
import SignIn from "./components/sign_in";
import store from "./store";
import { addNumberAction } from "./actions";

store.subscribe(() => console.log(store.getState()));

ReactDom.render(
  <Provider store={store}>
    <BrowserRouter>
      <div>
        <nav>
          <ul>
            <li>
              <Link to="/numbers">Numbers</Link>
            </li>
            <li>
              <Link to="/ping">Ping</Link>
            </li>
            <li>
              <Link to="/sign_in">Sign In</Link>
            </li>
          </ul>
        </nav>

        <Switch>
          <Route path="/numbers">
            <Numbers />
          </Route>
          <Route path="/ping">
            <Ping />
          </Route>
          <Route path="/sign_in">
            <SignIn />
          </Route>
        </Switch>
      </div>
    </BrowserRouter>
  </Provider>,
  document.getElementById("main-content")
);
