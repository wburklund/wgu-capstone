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
import { Button, Header, Form, Segment, Message } from 'semantic-ui-react';
import { Redirect } from 'react-router-dom';
import { login } from '../backend';

class Login extends React.Component {
    state = {}

    handleChange = (e) => {
        let mutation = {}
        mutation[e.target.name] = e.target.value

        this.setState(mutation)
    }

    handleSubmit = () => {
        login(this.state.accessKey).then(
            () => {
                this.props.handleLogin()
                this.setState({ authSuccess: true })
            },
            () => this.setState({ authError: true })
        )
    }

    render() {
        return (
            <div style={{ margin: 'auto', width: '500px' }}>
                <Header as='h2' color='blue'>
                    Enter Access Key
                </Header>
                <Form size='large' onSubmit={this.handleSubmit}>
                    <Segment>
                        <Form.Input fluid icon='lock' iconPosition='left' placeholder='Access Key' type='password' name='accessKey' onChange={this.handleChange} required />
                        <Button color='primary' fluid size='large'>Submit</Button>
                    </Segment>
                    {this.state.authError &&
                        <Message negative>
                            Incorrect access key.
                        </Message>
                    }
                </Form>
                {this.state.authSuccess && <Redirect to={"/scan"} />}
            </div>
        )
    }
}

export default Login;