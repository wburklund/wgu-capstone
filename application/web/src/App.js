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

import { Switch, Link, Route, Redirect } from 'react-router-dom'
import { Menu, Grid } from 'semantic-ui-react';
import Login from './Login';
import Report from './Report'
import Scan from './Scan';
import React from 'react';
import { ReactComponent as Athena } from './athena.svg'
import { getAccessKey, resetAccessKey } from './backend'

class App extends React.Component {
  handleLogin() {
    this.forceUpdate()
  }

  handleLogout() {
    resetAccessKey();
    this.forceUpdate();
  }

  render() {
    return (
      <div className="App">
        <Grid style={{ width: '100vw' }}>
          <Grid.Row style={{ width: '100vw', height: '95vh', paddingTop: 0, paddingBottom: 0 }}>
            {getAccessKey() &&
              <span style={{ position: 'relative' }}>
                <Menu size="large" className="fixed" style={{ height: '52px' }}>
                  <Athena style={{ width: '50px', height: '50px', position: 'absolute', left: '50vw', transform: 'translate(-50%, 0)' }} />
                  <Menu className="left">
                    <Link className="item" to="/scan">Scan</Link>
                    <Link className="item" to="/report">Report</Link>
                  </Menu>
                  <Menu className="right">
                    <a className="item" href="mailto:waburklund@gmail.com">Contact</a>
                    <Link className="item" to="/" onClick={() => this.handleLogout()}>Logout</Link>
                  </Menu>
                </Menu>
              </span>
            }
            <Switch>
              <Route path="/login">
                <Login handleLogin={() => this.handleLogin()} />
              </Route>
              {getAccessKey() &&
                <>
                  <Route path="/scan">
                    <Scan />
                  </Route>
                  <Route path="/report">
                    <Report />
                  </Route>
                </>
              }
              <Route>
                <Redirect to="/login" />
              </Route>
            </Switch>

          </Grid.Row>
          <Grid.Row centered>
            <span>
              Athena icon made by <a href="https://thenounproject.com/pxLens/" title="pxLens">pxLens</a>
              &nbsp;—&nbsp;
              X-ray icon made by <a href="https://www.flaticon.com/authors/icon-pond" title="Icon Pond">Icon Pond</a>
            </span>
          </Grid.Row>
        </Grid>
      </div>
    );
  }
}

export default App;
