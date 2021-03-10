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

import React from 'react';
import { Card } from 'semantic-ui-react';

const Login = () => (
    <React.Fragment>
        <Card>
            <Card.Content>
                <Card.Header>Login</Card.Header>
                <Card.Meta>
                    <span>Example meta text</span>
                </Card.Meta>
                <Card.Description>
                    This is a Semantic UI React example.
                </Card.Description>
            </Card.Content>
        </Card>
    </React.Fragment>
)

export default Login;