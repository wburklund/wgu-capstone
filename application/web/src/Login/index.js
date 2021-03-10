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
import { GetCallerIdentityCommand, STSClient } from '@aws-sdk/client-sts';

class Login extends React.Component {
    state = {}

    handleChange = (e) => {
        let mutation = {}
        mutation[e.target.name] = e.target.value

        this.setState(mutation)
    }

    handleSubmit = (e) => {
        const creds = {
            accessKeyId: this.state.username,
            secretAccessKey: this.state.password
        }

        const sts = new STSClient({ region: 'us-east-2', credentials: creds })
        
        let command = new GetCallerIdentityCommand()
        sts.send(command).then(
            (data) => {
                console.log(data)
            },
            (error) => {
                console.log(error)
            }
        )
    }

    render() {
        return (
            <div style={{ margin: 'auto', width: '500px' }}>
                <Header as='h2' color='blue'>
                    Login to Helios
                </Header>
                <Form size='large' onSubmit={this.handleSubmit}>
                    <Segment>
                        <Form.Input fluid icon='user' iconPosition='left' placeholder='Username' name='username' onChange={this.handleChange} required />
                        <Form.Input fluid icon='lock' iconPosition='left' placeholder='Password' type='password' name='password' onChange={this.handleChange} required />
                        <Button color='primary' fluid size='large'>Submit</Button>
                    </Segment>
                </Form>
            </div>
        )
    }
}

export default Login;