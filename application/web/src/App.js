/*
  WGU Capstone Project
  Copyright (C) 2021 Will Burklund

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU Affero General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU Affero General Public License for more details.

  You should have received a copy of the GNU Affero General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import './App.css';
import { Switch, Route, Redirect } from 'react-router-dom'
import Login from './Login'
import Scan from './Scan'
import React from 'react';

class App extends React.Component {
  setAccessKey = (accessKey) => this.setState({'accessKey': accessKey});

  render() {
    return (
      <div className="App">
        <Switch>
          <Route exact path="/">
            <Redirect to="/login" />
          </Route>
          <Route path="/login">
            <Login setAccessKey={this.setAccessKey} />
          </Route>
          <Route path="/scan">
            <Scan accessKey={this.state?.accessKey} />
          </Route>
        </Switch>
      </div>
    );
  }
}

export default App;
