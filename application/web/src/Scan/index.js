import React from 'react';
import { Button, Header, Icon, Segment, Grid, Input } from 'semantic-ui-react';

class Scan extends React.Component {
  render() {
    return (
      <Grid style={{ width: '100%', height: '100%' }}>
        <Grid.Column>
          <Segment placeholder>
            <Header icon>
              <Icon name='pdf file outline' />
              Please upload a chest X-ray image.
            </Header>
            <Button as='label' primary htmlFor='fileInput'>Select Image</Button>
            <Input ref={this.fileInputRef} type='file' id='fileInput' style={{ display: 'none' }} onChange={this.fileChange} />
          </Segment>
        </Grid.Column>
      </Grid>
    );
  }
}

export default Scan;
