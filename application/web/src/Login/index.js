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
import { Button, Header, Form, Segment } from 'semantic-ui-react';

const Login = () => (
    <div style={{ margin: 'auto', width: '500px' }}>
        <Header as='h2' color='blue'>
            Login to Helios
        </Header>
        <Form size='large'>
            <Segment>
                <Form.Input fluid icon='user' iconPosition='left' placeholder='Username' />
                <Form.Input fluid icon='lock' iconPosition='left' placeholder='Password' type='password' />
            </Segment>
            <Button color='primary' fluid size='large'>Submit</Button>
        </Form>
    </div>
)

export default Login;